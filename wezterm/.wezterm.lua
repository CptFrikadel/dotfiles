local wezterm = require('wezterm')

local config = wezterm.config_builder()
local act = wezterm.action

config.color_scheme = 'Catppuccin Frappe'
config.window_background_opacity = 0.95
config.hide_mouse_cursor_when_typing = false


config.wsl_domains = {
  {
    name = "Ubuntu",
    distribution = "Ubuntu",
    default_cwd = "~",
  }
}

config.default_prog = { 'C:/Program Files/nu/bin/nu.exe' }

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"


local sessionizer = wezterm.plugin.require "https://github.com/mikkasendke/sessionizer.wezterm"
local history = wezterm.plugin.require "https://github.com/mikkasendke/sessionizer-history.git" -- the most recent functionality moved to another plugin

local home_dir = wezterm.home_dir
local config_path = home_dir .. ("/dotfiles")

local schema = {
   options = {
      title = "My title",
      always_fuzzy = true,
      callback = history.Wrapper(sessionizer.DefaultCallback), -- tell history that we changed to another workspace
   },
   sessionizer.AllActiveWorkspaces {},
   config_path .. "/wezterm",
   config_path .. "/neovim/nvim",
   config_path,
   -- max_depth is counted against the ".git" entry fd matches, not the repo
   -- root it reports ({//} strips the last segment), so it must be one deeper
   -- than the deepest repo. Nested repos (BetaTool/*, stuff/AdventOfCode) sit
   -- at depth 2, so 3 is the minimum that finds them: depth 2 yields 11 repos,
   -- depth 3 yields all 18 -- the same set as the default 16, at 90ms vs 139ms.
   sessionizer.FdSearch { home_dir .. "/source/repos", include_submodules = false, max_depth = 3 },
}


package.path = wezterm.home_dir .. "/dotfiles/wezterm/?.lua;" .. package.path
local padding = require("padding")

config.leader = { key="a", mods="CTRL" }
config.keys = {
    { key = "a", mods = "LEADER|CTRL",  action=wezterm.action{SendString="\x01"}},
    { key = "-", mods = "LEADER",       action=padding.split("Bottom")},
    { key = "\\",mods = "LEADER",       action=padding.split("Right")},
    { key = "v", mods = "LEADER",       action=padding.split("Right")},
    { key = "o", mods = "LEADER",       action="TogglePaneZoomState" },
    { key = "z", mods = "LEADER",       action="TogglePaneZoomState" },
    { key = "c", mods = "LEADER",       action=wezterm.action{SpawnTab="CurrentPaneDomain"}},
    { key = "h", mods = "LEADER",       action=wezterm.action{ActivatePaneDirection="Left"}},
    { key = "j", mods = "LEADER",       action=wezterm.action{ActivatePaneDirection="Down"}},
    { key = "k", mods = "LEADER",       action=wezterm.action{ActivatePaneDirection="Up"}},
    { key = "l", mods = "LEADER",       action=wezterm.action{ActivatePaneDirection="Right"}},
    { key = "H", mods = "LEADER|SHIFT", action=wezterm.action{AdjustPaneSize={"Left", 5}}},
    { key = "J", mods = "LEADER|SHIFT", action=wezterm.action{AdjustPaneSize={"Down", 5}}},
    { key = "K", mods = "LEADER|SHIFT", action=wezterm.action{AdjustPaneSize={"Up", 5}}},
    { key = "L", mods = "LEADER|SHIFT", action=wezterm.action{AdjustPaneSize={"Right", 5}}},
    { key = "1", mods = "LEADER",       action=wezterm.action{ActivateTab=0}},
    { key = "2", mods = "LEADER",       action=wezterm.action{ActivateTab=1}},
    { key = "3", mods = "LEADER",       action=wezterm.action{ActivateTab=2}},
    { key = "4", mods = "LEADER",       action=wezterm.action{ActivateTab=3}},
    { key = "5", mods = "LEADER",       action=wezterm.action{ActivateTab=4}},
    { key = "6", mods = "LEADER",       action=wezterm.action{ActivateTab=5}},
    { key = "7", mods = "LEADER",       action=wezterm.action{ActivateTab=6}},
    { key = "8", mods = "LEADER",       action=wezterm.action{ActivateTab=7}},
    { key = "9", mods = "LEADER",       action=wezterm.action{ActivateTab=8}},
    { key = "&", mods = "LEADER|SHIFT", action=wezterm.action{CloseCurrentTab={confirm=true}}},
    { key = "d", mods = "LEADER",       action=wezterm.action{CloseCurrentPane={confirm=true}}},
    { key = "x", mods = "LEADER",       action=wezterm.action{CloseCurrentPane={confirm=true}}},
    { key = "p", mods = "LEADER",       action=wezterm.action{ActivateTabRelative=-1}},
    { key = "n", mods = "LEADER",       action=wezterm.action{ActivateTabRelative=1}},

    { key = "s", mods = "LEADER",       action=wezterm.action.ShowLauncherArgs{ flags = 'FUZZY|WORKSPACES'} },
    { key = "c", mods = "LEADER|SHIFT",       action=wezterm.action.ShowLauncherArgs{ flags = 'FUZZY|DOMAINS'} },

    { key = "[", mods = "LEADER",       action=wezterm.action.ActivateCopyMode },

    { key = 'q', mods = 'LEADER|CTRL', action = wezterm.action.QuitApplication },

    { key = 'z', mods = 'ALT', action = wezterm.action.EmitEvent "toggle-padding" },
    { key = 't', mods = 'ALT', action = wezterm.action.EmitEvent "toggle-transparency" },

    { key = 'r', mods = 'LEADER',
      action = act.ActivateKeyTable {
        name = 'resize_mode',
        one_shot = false,
      },
    },
    {
      key = 'R',
      mods = 'LEADER',
      action = act.PromptInputLine {
        description = wezterm.format {
          { Attribute = { Intensity = 'Bold' } },
          { Foreground = { AnsiColor = 'Fuchsia' } },
          { Text = 'Enter new workspace name' },
        },
        action = wezterm.action_callback(function(window, pane, line)
          -- An empty string if just hit enter
          -- Or the actual line of text they wrote
          if line then
            wezterm.mux.rename_workspace(
              wezterm.mux.get_active_workspace(),
              line
            )
          end
        end),
      },
    },
   { key = "s", mods = "ALT", action = sessionizer.show(schema) },
   { key = "m", mods = "ALT", action = history.switch_to_most_recent_workspace },
}

config.key_tables = {
  -- Defines the keys that are active in our resize-pane mode.
  -- Since we're likely to want to make multiple adjustments,
  -- we made the activation one_shot=false. We therefore need
  -- to define a key assignment for getting out of this mode.
  -- 'resize_pane' here corresponds to the name="resize_pane" in
  -- the key assignments above.
  resize_mode = {
    { key = 'LeftArrow', action = act.AdjustPaneSize { 'Left', 3 } },
    { key = 'h', action = act.AdjustPaneSize { 'Left', 3 } },

    { key = 'RightArrow', action = act.AdjustPaneSize { 'Right', 3 } },
    { key = 'l', action = act.AdjustPaneSize { 'Right', 3 } },

    { key = 'UpArrow', action = act.AdjustPaneSize { 'Up', 1 } },
    { key = 'k', action = act.AdjustPaneSize { 'Up', 1 } },

    { key = 'DownArrow', action = act.AdjustPaneSize { 'Down', 1 } },
    { key = 'j', action = act.AdjustPaneSize { 'Down', 1 } },

    -- Cancel the mode by pressing escape
    { key = 'Escape', action = 'PopKeyTable' },
  },
}



config.use_fancy_tab_bar = false

local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
  options = {
    theme = 'Catppuccin Mocha',
    -- tabline indexes its theme by the active key table name whenever that name
    -- ends in "_mode" (components/window/mode.lua). Our 'resize_mode' key table
    -- has no entry in the built-in theme, so every update-status tick threw
    -- "attempt to index a nil value (local 'colors')". Supply the missing mode.
    theme_overrides = {
      resize_mode = {
        a = { fg = '#1e1e2e', bg = '#f9e2af' },
        b = { fg = '#f9e2af', bg = '#313244' },
        c = { fg = '#cdd6f4', bg = '#1e1e2e' },
      },
    },
  },
  sections = {
    tabline_a = { 'mode' },
    tabline_b = { 'workspace' },
    tabline_c = { ' ' },
    tab_active = {
      'index',
      { 'zoomed', padding = 0 },
      { 'parent', padding = 0 },
      '/',
      { 'cwd', padding = { left = 0, right = 1 } },
    },
    tab_inactive = { 'index', { 'process', padding = { left = 0, right = 1 } } },
    tabline_x = { },
    tabline_y = { },
    tabline_z = { },
  },
})



wezterm.on("toggle-transparency", function(window)
  local overrides = window:get_config_overrides() or {}
  if overrides.window_background_opacity == 1.0 then
    overrides.window_background_opacity = nil
  else
    overrides.window_background_opacity = 1.0
  end
  window:set_config_overrides(overrides)
end);

return config
