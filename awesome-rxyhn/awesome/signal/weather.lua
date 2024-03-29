-- Provides:
-- signal::weather
--      temperature (integer)
--      description (string)
--      icon_code (string)
local awful = require("awful")
local beautiful = require("beautiful")
local helpers = require("helpers")
local config = require("configuration.config")
local json = require("module.json")

-- Configuration
local key = config.widget.weather.key
local city_id = config.widget.weather.city_id
local units = "metric"

-- Don't update too often, because your requests might get blocked for 24 hours
local update_interval = 1200
local temp_file = "/tmp/awesomewm-signal-weather-" .. city_id .. "-" .. units

local sun_icon = ""
local moon_icon = ""
local dcloud_icon = ""
local ncloud_icon = ""
local cloud_icon = ""
local rain_icon = ""
local storm_icon = ""
local snow_icon = ""
local mist_icon = ""
local whatever_icon = ""

local weather_icons = {
	["01d"] = { icon = sun_icon, color = beautiful.xcolor3 },
	["01n"] = { icon = moon_icon, color = beautiful.xcolor4 },
	["02d"] = { icon = dcloud_icon, color = beautiful.xcolor3 },
	["02n"] = { icon = ncloud_icon, color = beautiful.xcolor6 },
	["03d"] = { icon = cloud_icon, color = beautiful.xforeground },
	["03n"] = { icon = cloud_icon, color = beautiful.xforeground },
	["04d"] = { icon = cloud_icon, color = beautiful.xforeground },
	["04n"] = { icon = cloud_icon, color = beautiful.xforeground },
	["09d"] = { icon = rain_icon, color = beautiful.xcolor4 },
	["09n"] = { icon = rain_icon, color = beautiful.xcolor4 },
	["10d"] = { icon = rain_icon, color = beautiful.xcolor4 },
	["10n"] = { icon = rain_icon, color = beautiful.xcolor4 },
	["11d"] = { icon = storm_icon, color = beautiful.xforeground },
	["11n"] = { icon = storm_icon, color = beautiful.xforeground },
	["13d"] = { icon = snow_icon, color = beautiful.xcolor6 },
	["13n"] = { icon = snow_icon, color = beautiful.xcolor6 },
	["40d"] = { icon = mist_icon, color = beautiful.xcolor5 },
	["40n"] = { icon = mist_icon, color = beautiful.xcolor5 },
	["50d"] = { icon = mist_icon, color = beautiful.xcolor5 },
	["50n"] = { icon = mist_icon, color = beautiful.xcolor5 },
	["_"] = { icon = whatever_icon, color = beautiful.xcolor2 },
}


local request_url = "http://api.openweathermap.org/data/2.5/weather?APPID=" .. key .. "&id=" .. city_id .. "&units=" .. units
local get_forecast_cmd = [[bash -c "curl -sf --show-error '%s'"]]

helpers.remote_watch(string.format(get_forecast_cmd, request_url), update_interval, temp_file, function(stdout)

	local icon
	local color
	local weather_icon

	local status, result = pcall(json.decode, stdout)
	
	if status == false then
	    -- remove temp_file to for
	    awful.spawn.with_shell("rm " .. temp_file)
	    icon = weather_icons["_"].icon
	    color = weather_icons["_"].color
	    weather_icon = helpers.colorize_text(icon, color)
	    awesome.emit_signal("signal::weather", 999, "weather unavailable", weather_icon)
	    return
	end

	local icon_code = result.weather[1].icon

	local description = result.weather[1].description:gsub("^%l", string.upper)
	local temperature = math.floor(result.main.temp)

	icon = weather_icons[icon_code].icon
	color = weather_icons[icon_code].color
	weather_icon = helpers.colorize_text(icon, color)
	awesome.emit_signal("signal::weather", tonumber(temperature), description, weather_icon)
end)
