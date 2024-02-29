-- Lock menu, covers everything and requires a password to unlock!

-- Add liblua_pam to cpath
package.cpath = package.cpath .. ";" .. "/usr/lib/lua-pam/?.so"

-- config stuff!
local lockConf = {
	clock = true,
	fallback = "neko",
	blur = true,
	bg_image = beautiful.lockbackground
}

-- Do not edit!
local input_password = nil
local lock_again = nil
local type_again = true
local locked_tag = nil

local profile_name = wibox.widget {
	--id = 'uname_text',
	markup = lockConf.fallback,
	font = beautiful.sysboldfont .. dpi(45),
	align = 'center',
	valign = 'center',
	widget = wibox.widget.textbox
}

local caps_text = wibox.widget {
	id = 'uname_text',
	markup = 'Caps Lock is on!',
	font = beautiful.sysboldfont .. dpi(45),
	align = 'center',
	valign = 'center',
	opacity = 0.0,
	widget = wibox.widget.textbox
}

local profile_picture = wibox.widget {
	{
		id = 'profile_image',
		image = beautiful.profile_pic,
		resize = true,
		forced_height = dpi(250),
		widget = wibox.widget.imagebox,
	},
	shape = gears.shape.circle,
	shape_border_width = beautiful.border_width * 3,
	shape_border_color = beautiful.border_color_active,
	forced_height = dpi(250),
	forced_width = dpi(250),
	widget = wibox.container.background
}
-- Update those widgets to properly follow the users stuff!
local update_profile_pic = function()
	awful.spawn.easy_async_with_shell(
		[[sh -c "$HOME/.config/awesome/utils/update-profile"]],
		function(stdout)
			profile_picture.profile_image:set_image(stdout:match('[^\n]*'))
			profile_picture.profile_image:emit_signal('widget::redraw_needed')
		end
	)
end

local update_profile_name = function()
	awful.spawn.easy_async_with_shell(
		[[sh -c 'printf "$(whoami)"']],
		function(stdout)
			stdout = stdout:sub(1,1):upper()..stdout:sub(2)
			profile_name:set_markup(stdout)
			profile_name:emit_signal('widget::redraw_needed')
		end)
end

update_profile_pic()
update_profile_name()

-- setting up some clock stuff
local clock_format = '<span font="' .. beautiful.sysboldfont .. dpi(60) .. '">%H:%M:%S</span>'
local time = wibox.widget.textclock(clock_format, 1)

local date_value = function()
	local ordinal = nil
	local date = os.date('%d')
	local day = os.date('%A')
	local month = os.date('%B')
	
	local first_digit = string.sub(date, 0, 1)
	local last_digit = string.sub(date, -1)
	if first_digit == '0' then
		date = last_digit
	end
	
	if last_digit == '1' and date ~= '11' then
		ordinal = 'st'
	elseif last_digit == '2' and date ~= '12' then
		ordinal = 'nd'
	elseif last_digit == '3' and date ~= '13' then
		ordinal = 'rd'
	else
		ordinal = 'th'
	end
	
	return date .. ordinal .. ' of ' .. month .. ', ' .. day
end

local date = wibox.widget {
	markup = date_value(),
	font = beautiful.sysboldfont .. dpi(60),
	align = 'center',
	valign = 'center',
	widget = wibox.widget.textbox
}

local circle_container = wibox.widget {
	bg = beautiful.transparent,
	forced_width = dpi(300),
	forced_height = dpi(300),
	shape = gears.shape.circle,
	widget = wibox.container.background
}

local locker_arc = wibox.widget {
	bg = beautiful.transparent,
	forced_width = dpi(300),
	forced_height = dpi(300),
	shape = function(cr, width, height)
		gears.shape.arc(cr, width, height, dpi(20), 0, (math.pi / 2), false, false)
	end,
	widget = wibox.container.background
}

local rotate_container = wibox.container.rotate()
local locker_widget = wibox.widget {
	{
		locker_arc,
		widget = rotate_container
	},
	layout = wibox.layout.fixed.vertical
}

local rotation_direction = {'north', 'west', 'south', 'east'}
local arc_color = {beautiful.primary,beautiful.secondary}

-- time for the actual module!
local locker = function(s)
	local lockscreen = wibox {
		screen = s,
		visible = false,
		ontop = true,
		type = 'splash',
		width = s.geometry.width,
		height = s.geometry.height,
		bg = lockConf.bg_image,
		fg = beautiful.primary
	}
	
	local check_caps = function()
		awful.spawn.easy_async_with_shell(
			'xset q | grep Caps | cut -d: -f3 | cut -d0 -f1 | tr -d \' \'',
			function(stdout)
				if stdout:match('on') then
					caps_text.opacity = 1.0
				else
					caps_text.opacity = 0.0
				end
				caps_text:emit_signal('widget::redraw_needed')
			end)
	end
	
	local locker_arc_rotate = function()
		local direction = rotation_direction[math.random(#rotation_direction)]
		local color = arc_color[math.random(#arc_color)]
		
		rotate_container.direction = direction
		locker_arc.bg = color
		
		rotate_container:emit_signal('widget::redraw_needed')
		locker_arc:emit_signal('widget::redraw_needed')
		locker_widget:emit_signal('widget::redraw_needed')
	end
	
	-- When the login fails (lol get fucked idiot)
	local loginFailed = function()
		circle_container.bg = beautiful.system_red_dark .. "AA"
		gears.timer.start_new(1, function()
			circle_container.bg = beautiful.transparent
			type_again = true
		end)
	end
	
	-- When the login succeeds (VERY SUS!!!!)
	local loginSuccess = function()
		circle_container.bg = beautiful.system_green_dark .. "AA"
		gears.timer.start_new(1, function()
			for s in screen do
				s.taskbar.visible = true
				s.toppanel.visible = true
				if s.index == 1 then
					s.lockscreen.visible = false
				else
					s.lockscreen_extended.visible = false
				end
			end
			
			circle_container.bg = beautiful.transparent
			lock_again = true
			type_again = true
			-- Restore old tags???
			if locked_tag then
				locked_tag.selected = true
				locked_tag = nil
			end
			local c = awful.client.restore()
			if c then
				c:emit_signal('request::activate')
				c:raise()
			end
		end)
	end
	
	local password_grabber = awful.keygrabber {
		auto_start = true,
		stop_event = 'release',
		mask_event_callback = true,
		keybindings = {
			awful.key {
				modifiers = {'Mod1', 'Mod4', 'Shift', 'Control'},
				key = 'Return',
				on_press = function(self)
					if not type_again then
						return
					end
					self:stop()
					loginSuccess()
				end
			}
		},
		keypressed_callback = function(self, mod, key, command)
			if not type_again then
				return
			end
			
			if key == 'Escape' then
				input_password = nil
				return
			end
			
			if #key == 1 then
				locker_arc_rotate()
				if input_password == nil then
					input_password = key
					return
				end
				input_password = input_password .. key
			end
		end,
		keyreleased_callback = function(self, mod, key, command)
			locker_arc.bg = beautiful.transparent
			locker_arc:emit_signal('widget::redraw_needed')
			
			if key == 'Caps_Lock' then
				check_caps()
				return
			end
			if not type_again then
				return
			end
			
			if key == 'Return' then
				local authenticated = false
				if input_password ~= nil then
					local pam = require("liblua_pam")
					authenticated = pam:auth_current_user(input_password)
				end
				
				if authenticated then
					self:stop()
					loginSuccess()
				else
					loginFailed()
				end
				
				type_again = false
				input_password = nil
			end
		end
	}
	
	lockscreen : setup {
		layout = wibox.layout.align.vertical,
		expand = 'none',
		nil,
		{
			layout = wibox.layout.align.horizontal,
			expand = 'none',
			nil,
			{
				layout = wibox.layout.fixed.vertical,
				expand = 'none',
				spacing = dpi(40),
				{
					{
						layout = wibox.layout.align.horizontal,
						expand = 'none',
						nil,
						time,
						nil
					},
					{
						layout = wibox.layout.align.horizontal,
						expand = 'none',
						nil,
						date,
						nil
					},
					expand = 'none',
					layout = wibox.layout.fixed.vertical
				},
				{
					layout = wibox.layout.fixed.vertical,
					spacing = dpi(50),
					{
						circle_container,
						locker_widget,
						{
							layout = wibox.layout.align.vertical,
							expand = 'none',
							nil,
							{
								layout = wibox.layout.align.horizontal,
								expand = 'none',
								nil,
								profile_picture,
								nil
							},
							nil,
						},
						layout = wibox.layout.stack
					},
					profile_name,
					caps_text
				},
			},
			nil
		},
		nil
	}
	
	local show_lockscreen = function()
		if lock_again == true or lock_again == nil then
			time:emit_signal('widget::redraw_needed')
			check_caps()
			for s in screen do
				s.taskbar.visible = false
				s.toppanel.visible = false
				if s.index == 1 then
					s.lockscreen.visible = true
				else
					s.lockscreen_extended.visible = true
				end
			end
			
			gears.timer.start_new(0.5, function()
				password_grabber:start() end)
			
			lock_again = false
		end
	end
	
	local free_keygrab = function()
		awful.spawn.with_shell('kill -9 $(pgrep rofi)')
		local keygrabbing_instance = awful.keygrabber.current_instance
		if keygrabbing_instance then
			keygrabbing_instance:stop()
		end
		
		if client.focus then
			client.focus.minimized = true
		end
		for _, t in ipairs(mouse.screen.selected_tags) do
			locked_tag = t
			t.selected = false
		end
	end
	
	awesome.connect_signal('module::lockscreen:show', function()
		if lock_again == true or lock_again == nil then
			free_keygrab()
			show_lockscreen()
		end
	end)
	return lockscreen
end

-- This lockscreen is for the extra/multi monitor
local locker_ext = function(s)
	local extended_lockscreen = wibox {
		screen = s,
		visible = false,
		ontop = true,
		ontype = 'true',
		x = s.geometry.x,
		y = s.geometry.y,
		width = s.geometry.width,
		height = s.geometry.height,
		bg = beautiful.background,
		fg = beautiful.primary
	}
	return extended_lockscreen
end

local create_lock_screen = function(s)
	if s.index == 1 then
		s.lockscreen = locker(s)
	else
		s.lockscreen_extended = locker_ext(s)
	end
end

local check_lockscreen_visibility = function()
	focused = awful.screen.focused()
	if focused.lockscreen and focused.lockscreen.visible then
		return true
	end
	if focused.lockscreen_extended and focused.lockscreen_extended.visible then
		return true
	end
	return false
end

naughty.connect_signal('request::display', function(_)
	if check_lockscreen_visibility() then
		naughty.destroy_all_notifications(nil, 1)
	end
end)

screen.connect_signal('request::desktop_decoration', function(s)
	create_lock_screen(s)
end)

screen.connect_signal('removed', function(s)
	create_lock_screen(s)
end)
