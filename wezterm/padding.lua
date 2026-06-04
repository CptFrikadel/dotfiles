-- Per-tab padding via spacer panes. Instead of using window_padding
-- (which is window-level and reflows every tab on toggle), each padded
-- tab gets two side panes running a silent blocking process:
--   [ spacer | user pane | spacer ]
-- Splitting the tab kills the spacers; Alt+z (via the "toggle-padding"
-- event) toggles them manually.

local wezterm = require("wezterm")
local M = {}

-- The blocker process emits `\e[?25l` itself so the cursor stays hidden;
-- injecting from Lua races process startup and gets clobbered.
local SPACER_CMD = wezterm.target_triple:find("windows")
  and { "powershell", "-NoProfile", "-NoLogo", "-Command",
        "[Console]::Write([char]27 + '[?25l'); while($true){Start-Sleep 3600}" }
  or  { "sh", "-c", "printf '\\033[?25l'; exec sleep infinity" }

local TARGET_MAIN_WIDTH_PX = 2100
local SPACER_USER_VAR = "wezterm_spacer"

local WEZTERM_BIN = wezterm.executable_dir
  .. "/wezterm"
  .. (wezterm.target_triple:find("windows") and ".exe" or "")

local function mark_as_spacer(pane)
  -- OSC 1337 SetUserVar; "MQ==" is base64("1")
  pane:inject_output("\27]1337;SetUserVar=" .. SPACER_USER_VAR .. "=MQ==\7")
end

local function is_spacer(pane)
  return pane:get_user_vars()[SPACER_USER_VAR] == "1"
end

local function tab_user_panes(tab)
  local out = {}
  for _, p in ipairs(tab:panes()) do
    if not is_spacer(p) then table.insert(out, p) end
  end
  return out
end

local function tab_spacer_panes(tab)
  local out = {}
  for _, p in ipairs(tab:panes()) do
    if is_spacer(p) then table.insert(out, p) end
  end
  return out
end

-- Ctrl+C kills both the Linux `sleep` (SIGINT) and the powershell loop
-- (cancels Start-Sleep, exits the script). Async — pane closes when the
-- process actually exits.
local function close_spacers(tab)
  for _, p in ipairs(tab_spacer_panes(tab)) do
    p:send_text("\x03")
  end
end

local function spawn_spacers(window, tab)
  if #tab_spacer_panes(tab) > 0 then return end
  local users = tab_user_panes(tab)
  if #users ~= 1 then return end

  local dims = window:get_dimensions()
  if dims.pixel_width <= TARGET_MAIN_WIDTH_PX then return end

  local main = users[1]
  local total = dims.pixel_width
  local each = (total - TARGET_MAIN_WIDTH_PX) / 2

  local right_frac = each / total
  local right_spacer = main:split {
    direction = "Right",
    size = right_frac,
    args = SPACER_CMD,
  }
  mark_as_spacer(right_spacer)

  -- After the right split, main is now (total - each) wide; left spacer
  -- still wants to be `each` pixels, expressed as a fraction of that.
  local left_frac = each / (total - each)
  local left_spacer = main:split {
    direction = "Left",
    size = left_frac,
    args = SPACER_CMD,
  }
  mark_as_spacer(left_spacer)

  -- Splitting focuses the new spacer; pull focus back to main. Skip for
  -- background tabs (resize sweep) so we don't yank the user's view.
  if window:active_tab():tab_id() == tab:tab_id() then
    main:activate()
  end
end

-- Kill spacers via the wezterm CLI and block until done. Used before a
-- split so the split lands on the now-full-width main pane (wezterm's
-- reflow-on-close is asymmetric, so killing first keeps it centered).
local function kill_spacers_sync(tab)
  for _, p in ipairs(tab_spacer_panes(tab)) do
    wezterm.run_child_process { WEZTERM_BIN, "cli", "kill-pane", "--pane-id", tostring(p:pane_id()) }
  end
end

-- Returns a wezterm action: kill spacers synchronously, then split the
-- active pane 50/50 in `direction` ("Right", "Left", "Top", "Bottom").
function M.split(direction)
  return wezterm.action_callback(function(window, pane)
    kill_spacers_sync(window:active_tab())
    pane:split { direction = direction, size = 0.5, domain = "CurrentPaneDomain" }
  end)
end

-- Tabs we've already initialized — guards against auto-respawn after the
-- user manually closes spacers via the toggle event.
local initialized_tabs = {}

wezterm.on("update-status", function(window)
  -- Clear any stale window_padding override from older versions of this
  -- config — set_config_overrides values live on the window and persist
  -- across reloads, so reloading alone doesn't get rid of them.
  local overrides = window:get_config_overrides() or {}
  if overrides.window_padding then
    overrides.window_padding = nil
    window:set_config_overrides(overrides)
  end

  local tab = window:active_tab()
  if not tab then return end

  -- Auto-spawn spacers on first sight of a tab. Only mark as initialized
  -- once the window is actually wide enough; otherwise the initial poll
  -- (with the window still sizing up) would mark it forever.
  if not initialized_tabs[tab:tab_id()] then
    local dims = window:get_dimensions()
    if dims.pixel_width > TARGET_MAIN_WIDTH_PX
       and #tab_user_panes(tab) == 1
       and #tab_spacer_panes(tab) == 0 then
      initialized_tabs[tab:tab_id()] = true
      spawn_spacers(window, tab)
    end
  end

  -- Fallback orphan close (e.g. shell exit). Does NOT respawn.
  if #tab_user_panes(tab) == 0 and #tab_spacer_panes(tab) > 0 then
    close_spacers(tab)
  end
end)

wezterm.on("toggle-padding", function(window)
  local tab = window:active_tab()
  if #tab_spacer_panes(tab) > 0 then
    close_spacers(tab)
  else
    spawn_spacers(window, tab)
  end
  -- Manual toggle counts as initialization so update-status doesn't
  -- respawn after a manual close (or vice versa).
  initialized_tabs[tab:tab_id()] = true
end)

-- Spacers are real panes and don't reflow themselves, so a window resize
-- (e.g. undocking a laptop and dropping to a smaller screen) leaves the
-- padding stale. Re-evaluate every tab on resize: tear spacers down when
-- the window falls to/below the target width, and restore them when it
-- grows back. We only restore tabs we ourselves auto-disabled here, so a
-- manual toggle-off is never silently overridden.
local resize_disabled_tabs = {}

wezterm.on("window-resized", function(window)
  local dims = window:get_dimensions()
  local too_narrow = dims.pixel_width <= TARGET_MAIN_WIDTH_PX

  for _, tab in ipairs(window:mux_window():tabs()) do
    local id = tab:tab_id()
    if too_narrow then
      if #tab_spacer_panes(tab) > 0 then
        close_spacers(tab)
        resize_disabled_tabs[id] = true
      end
    elseif resize_disabled_tabs[id]
       and #tab_spacer_panes(tab) == 0
       and #tab_user_panes(tab) == 1 then
      resize_disabled_tabs[id] = nil
      spawn_spacers(window, tab)
    end
  end
end)

return M
