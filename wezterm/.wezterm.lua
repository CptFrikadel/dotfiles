local wezterm = require('wezterm')

local config = wezterm.config_builder()
local act = wezterm.action

config.color_scheme = 'Catppuccin Frappe'
config.window_background_opacity = 0.95

config.default_prog = { 'C:/Users/Alexander/AppData/Local/Programs/nu/bin/nu.exe' }

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

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

    { key = "[", mods = "LEADER",       action=wezterm.action.ActivateCopyMode },

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
  }

  config.serial_ports = {
    {
      name = "ImpulseMotherBoard",
      port = "COM5",
      baud = 115200,
    }
  }

wezterm.on('update-right-status', function(window, pane)
  local is_zoomed = false
  local our_tab = pane:tab()
  if our_tab ~= nil then
      for _, pane_attributes in pairs(our_tab:panes_with_info()) do
          is_zoomed = pane_attributes['is_zoomed'] or is_zoomed
      end
  end

  local zoomed = ''
  if is_zoomed then
    zoomed = ' [ZOOMED]'
  end

  window:set_right_status(window:active_workspace() .. zoomed)
end)

local sessionizer = wezterm.plugin.require "https://github.com/mikkasendke/sessionizer.wezterm"
sessionizer.apply_to_config(config)

sessionizer.config.paths = "C:/Users/Alexander/source/repos"

return config
