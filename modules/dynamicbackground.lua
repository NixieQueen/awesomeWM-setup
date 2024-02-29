-- A lua for setting up a dynamic background

-- Getting what sort of background should be used based on given parameters
-- This is heavily reliant on some important parts such as month-based backgrounds and time-based backgrounds
-- Therefor please refer to the config for changing this behaviour
local background_config = {
	dynamic = true,
	stretch = false,
	season_based = false,
	hour_based = true,
	weather_based = false,
	city = 'Leiden',
	current_background = beautiful.wallpaper.default,
}

local season_based = function(month)
	-- autumn
	if month >= 9 and month <= 11 then
		return 'autumn_'
	-- winter
	elseif month == 12 or month <= 2 then
		return 'winter_'
	-- spring
	elseif month >= 3 and month <= 5 then
		return 'spring_'
	else
		-- summer :3c
		return ''
	end
end

local time_based = function(hour)
	-- evening
	if hour >= 20 and hour <= 24 then
		return 'evening'
	-- night
	elseif hour == 24 or hour <= 5 then
		return 'night'
	-- morning
	elseif hour >= 6 and hour <= 12 then
		return 'morning'
	else
		-- afternoon
		return 'afternoon'
	end
end

local weather_based = function(weather)
	local weather = string.lower(weather)
	if string.find(weather, 'drizzle') or string.find(weather, 'rain') then
		return '_rain'
	elseif string.find(weather, 'thunderstorm') then
		return '_thunder'
	elseif string.find(weather, 'snow') then
		return '_snow'
	else
		return ''
	end
end

local build_background_type = function(time, month, weather)
	return season_based(month) .. time_based(time) .. weather_based(weather)
end

local get_background = function(time, month, weather)
	if background_config.dynamic then
		return build_background_type(time, month, weather)
	else
		return 'afternoon'
	end
end

local startGif = function(giffile, s)
	if not (s == "none") then
		local gif = gifcontainer(giffile, 1506,2256)
		gears.timer {
			autostart = true,
			timeout = 0.2,
		callback = function() s.gif_wallpaper = awful.wallpaper {screen = s, widget = gif} end
		}
		gif:emit_signal("widget::gif:start_loop")
	else
		local geo = screen[1].geometry
		geo.x2 = geo.x + geo.width
		geo.y2 = geo.y + geo.height
		for s in screen do
			local geo2 = s.geometry
			geo.x = math.min(geo.x, geo2.x)
			geo.y = math.min(geo.y, geo2.y)
			geo.x2 = math.max(geo.x2, geo2.x + geo2.width)
			geo.y2 = math.max(geo.y2, geo2.y + geo2.height)
		end
		local gif = gifcontainer(giffile, geo.x2 - geo.x, geo.y2 - geo.y)
		gif_wallpaper = awful.wallpaper {
			screens = screen,
			widget = gif,
		}
		gif:emit_signal("widget::gif:start_loop")
	end
end

local stopGif = function()
	if gif_wallpaper or screen[1].gif_wallpaper then
		if not background_config.stretch then
			for s in screen do
				s.gif_wallpaper.widget:emit_signal("widget::gif:stop_loop")
				s.gif_wallpaper = {}
			end
		else
			gif_wallpaper.widget:emit_signal("widget::gif:stop_loop")
			gif_wallpaper = {}
		end
	end
end

local change_background = function(background)
	if not (beautiful.wallpaper[background] == background_config.current_background) then
		background_config.current_background = beautiful.wallpaper[background]
		if beautiful.wallpaper[background] then
			stopGif()
			if background_config.stretch then
				if string.find(beautiful.wallpaper[background], ".gif") then
					startGif(beautiful.wallpaper[background],"none")
				else
					gears.wallpaper.maximized(beautiful.wallpaper[background])
				end
			else
				if string.find(beautiful.wallpaper[background], ".gif") then
					for s in screen do
						startGif(beautiful.wallpaper[background], s)
					end
				else
					for s in screen do
						gears.wallpaper.maximized(beautiful.wallpaper[background],s)
					end
				end
			end
		else
			if background_config.stretch then
				gears.wallpaper.maximized(beautiful.wallpaper.default)
			else
				for s in screen do
					gears.wallpaper.maximized(beautiful.wallpaper.default,s)
				end
			end
		end
	end
end

-- Update the background! This uses a workaround so it is slightly limited in function :(
local weather_command = [[weather-Cli get ]] .. background_config.city .. [[ | grep 'Weather Condition: ' | awk '{$1=$2=""; print substr($0,3)}']]
local update_background = function()
	local hour = 99
	local month = 99
	local weather = 'n/a'

	if background_config.hour_based then
		hour = tonumber(os.date("%H"))
	end
	if background_config.season_based then
		month = tonumber(os.date("%m"))
	end
	if background_config.weather_based then
		awful.spawn.easy_async_with_shell(
			weather_command,
			function(stdout)
				change_background(get_background(hour,month,stdout))
			end
		)
	else
		change_background(get_background(hour,month,weather))
	end
end

--change_background('afternoon')
update_background()
gears.timer {
	timeout = 3600,
	autostart = true,
	callback_now = true,
	callback = update_background
}
-- Changes!! Make this whole thing be on a timer (60 minutes of delay!) and change the whole thing to a wibox background that can accept gifs!
-- It now is! :3c
