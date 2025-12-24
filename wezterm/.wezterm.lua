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

config.default_prog = { 'C:/Users/Alexander/AppData/Local/Programs/nu/bin/nu.exe' }

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
   config_path .. "/wezterm",
   config_path .. "/neovim/nvim",
   config_path,
   sessionizer.FdSearch { home_dir .. "/source/repos", include_submodules = false },
}


config.leader = { key="a", mods="CTRL" }
config.keys = {
    { key = "a", mods = "LEADER|CTRL",  action=wezterm.action{SendString="\x01"}},
    { key = "-", mods = "LEADER",       action=wezterm.action{SplitVertical={domain="CurrentPaneDomain"}}},
    { key = "\\",mods = "LEADER",       action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}},
    { key = "-", mods = "LEADER",       action=wezterm.action{SplitVertical={domain="CurrentPaneDomain"}}},
    { key = "v", mods = "LEADER",       action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}},
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
    theme = 'Catppuccin Mocha'
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



local function recompute_padding(window, enabled)
  local window_dims = window:get_dimensions();
  local overrides = window:get_config_overrides() or {}

  if window_dims.pixel_width <= 1920 or not enabled then
    if not overrides.window_padding then
      -- not changing anything
      return;
    end
    overrides.window_padding = nil;
  else
    -- Use only the middle bit
    local new_padding = {
      left = (window_dims.pixel_width - 1920) / 2,
      right = (window_dims.pixel_width - 1920) / 2,
      top = 0,
      bottom = 0
    };
    if overrides.window_padding and new_padding.left == overrides.window_padding.left then
      -- padding is same, avoid triggering further changes
      return
    end
    overrides.window_padding = new_padding

  end
  window:set_config_overrides(overrides)
end

local padding_enabled = true;

wezterm.on("window-resized", function(window)
  recompute_padding(window, padding_enabled)
end);

wezterm.on("window-config-reloaded", function(window)
  recompute_padding(window, padding_enabled)
end);

wezterm.on("toggle-padding", function (window)
  padding_enabled = not padding_enabled
  recompute_padding(window, padding_enabled);
end);

return config
