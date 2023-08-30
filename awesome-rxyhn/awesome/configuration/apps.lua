local filesystem = require("gears.filesystem")
local config_dir = filesystem.get_configuration_dir()
local utils_dir = config_dir .. "utilities/"

return {
	-- Default Applications
	default = {
		-- Default terminal emulator
		terminal = "wezterm",
		-- Defalut music client
		music_player = "alacritty --class music -e ncmpcpp",
		-- Default text editor
		text_editor = "alacritty -e nvim",
		-- Default code editor
		code_editor = "alacritty -e nvim",
		-- Default web browser
		web_browser = "brave",
		-- Default file manager
		file_manager = "nautilus",
		-- Default network manager
		network_manager = "networkmanager_dmenu",
		-- Default bluetooth manager
		bluetooth_manager = "blueman-manager",
		-- Default power manager
		power_manager = "xfce4-power-manager",
		-- Default rofi global menu
		app_launcher = "rofi -no-lazy-grab -show drun -modi drun -theme " .. config_dir .. "configuration/rofi.rasi",
	},

	-- List of apps to start once on start-up
	run_on_start_up = {
		-- Compositor
		"picom -b --config " .. config_dir .. "/configuration/picom.conf",
		-- Network Manager applet
		"nm-applet",
		-- Blueman applet
		"blueman-applet",
		-- Music server
		"mpd",
		-- Playertctl support for mpd
		"mpDris2",
		-- Polkit and keyring
		"/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &",
		-- Keyboard map
		"/usr/bin/setxkbmap -option 'caps:swapescape'",
		-- Nextcloud
		"nextcloud --background",
		-- Libinput gestures
		"libinput-gestures-setup autostart start",
	},

	-- List of binaries/shell scripts that will execute for a certain task
	utils = {
		-- Fullscreen screenshot
		full_screenshot = utils_dir .. "screensht full",
		-- Area screenshot
		area_screenshot = utils_dir .. "screensht area",
		-- Color Picker
		color_picker = utils_dir .. "xcolor-pick",
	},
}
