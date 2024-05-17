-- Taskbar setup, this is very experimental so it might break!

-- First set up task widget

-- What type of taskbar should be made!
-- Options: floating, dock & unity. Defaults to floating
-- Creator for widgets that include the app
local taskboot_creator = function(taskname)
	local contentBar
	if config.taskbar_name then
		contentBar = wibox.widget {
			fill_space = false,
			layout = wibox.layout.fixed.vertical,
			{
				layout = wibox.container.place,
				halign = "center",
				{
					appicon(taskname, false, false),
					margins = dpi(5),
					forced_height = dpi(50),
					widget = wibox.container.margin,
				},
			},
			{
				layout = wibox.container.place,
				halign = "center",
				{
					{
						id = 'text',
						widget = wibox.widget.textbox,
						font = beautiful.sysboldfont .. dpi(14),
						markup = taskname,
					},
					id = 'textmargin',
					left = dpi(2),
					right = dpi(2),
					widget = wibox.container.margin,
				},
			},
		}
	else
		contentBar = wibox.widget {
			layout = wibox.container.place,
			halign = "center",
			{
				appicon(taskname, false, false),
				margins = dpi(12),
				widget = wibox.container.margin,
			},
		}
	end

	local template = wibox.widget {
		id = 'taskbackground',
		forced_width = dpi(80),
		forced_height = dpi(80),
		widget = wibox.container.background,
		shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, dpi(20))
		end,
		fg = beautiful.taskbar_text_colour,
		bg = beautiful.taskbar_bg_normal,
		{
			widget = clickable_container,
			contentBar,
		}
	}

	template.taskname = taskname

	template:connect_signal("button::release", function(content, lx, ly, button)
		if button == 1 then
			awful.spawn(taskname, {screen = mouse.screen})
		end
	end)
	return template
end

-- Get the right colour for the application
local get_bg = function(task)
	if task.minimized then
		local task_bg = beautiful.taskbar_bg_minimize
		local task_fg = beautiful.taskbar_fg_off
		return {task_bg = task_bg, task_fg = task_fg}
	elseif task.ontop then
		local task_bg = beautiful.taskbar_bg_focus
		local task_fg = beautiful.taskbar_fg
		return {task_bg = task_bg, task_fg = task_fg}
	else
		local task_bg = beautiful.taskbar_bg_normal
		local task_fg = beautiful.taskbar_fg_normal
		return {task_bg = task_bg, task_fg = task_fg}
	end

	return {task_bg = task_bg, task_fg = task_fg}
end

local taskwidget_creator = function(tasklist)
	local task = tasklist[1]
	local taskcolours = get_bg(task)

	local contentBar
	if config.taskbar_name then
		contentBar = wibox.widget {
			layout = wibox.layout.fixed.vertical,
			--forced_height = dpi(72),
			{
				layout = wibox.container.place,
				halign = "center",
				{
					appicon(string.lower(task.class or task.name), true, task),
					margins = dpi(5),
					forced_height = dpi(50),
					widget = wibox.container.margin,
				},
			},
			{
				layout = wibox.container.place,
				halign = "center",
				{
					{
						id = 'text',
						widget = wibox.widget.textbox,
						font = beautiful.sysboldfont .. dpi(14),
						markup = string.lower(string.sub(task.class or task.name,1,9)),
					},
					id = 'textmargin',
					left = dpi(2),
					right = dpi(2),
					widget = wibox.container.margin,
				},
			}
		}
	else
		contentBar = wibox.widget {
			layout = wibox.container.place,
			halign = "center",
			{
				appicon(string.lower(task.class or task.name), true, task),
				margins = dpi(12),
				widget = wibox.container.margin,
			},
		}
	end

	local template = wibox.widget {
		id = 'taskbackground',
		forced_width = dpi(80),
		forced_height = dpi(80),
		widget = wibox.container.background,
		shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, dpi(20))
		end,
		fg = taskcolours.taskbar_text_colour,
		bg = taskcolours.task_bg,
		{
			widget = clickable_container,
			{
				--			forced_height = dpi(80),
				layout = wibox.layout.grid,
				forced_num_cols = 1,
				homogeneous = false,
				expand = true,
				--			fill_space = true,
				contentBar,
				{
					layout = wibox.container.place,
					forced_height = dpi(8),
					valign = "center",
					{
						id = 'taskselector',
						layout = wibox.layout.fixed.horizontal,
						spacing = dpi(3),
					},
				},
			},
		}
	}

	template.tasklist = tasklist
	template.task_index = 0

	template.cycle_item = function()
		if not (template.task_index == 0) then
			template:get_children_by_id("taskselector")[1]:get_all_children()[template.task_index].bg = beautiful.taskbar_fg_off
		end
		if template.task_index < #template.tasklist then
			template.task_index = template.task_index + 1
		else
			template.task_index = 1
		end
		template:get_children_by_id("taskselector")[1]:get_all_children()[template.task_index].bg = beautiful.taskbar_fg
	end

	add_tasklist = function()
		local size = dpi((60 - 2 * (#template.tasklist - 1)) / #template.tasklist)
		local count = 0
		for _,item in ipairs(template.tasklist) do
			count = count + 1
			local taskbar_inc_colour = beautiful.taskbar_fg_off
			if item.active then
				taskbar_inc_colour = beautiful.taskbar_fg
			end
			template:get_children_by_id("taskselector")[1]:add(
				{
					id = "task" .. tostring(count),
					widget = wibox.container.background,
					bg = taskbar_inc_colour,
					forced_height = dpi(7),
					forced_width = size,
					shape = function(cr, width, height)
						gears.shape.rounded_rect(cr, width, height, dpi(5))
					end,
				}
			)
		end
	end

	add_tasklist()

	template:connect_signal("module::taskbar_indicator:update", function()
		for i,item in ipairs(template.tasklist) do
			if item.active then
				template:get_children_by_id("taskselector")[1]:get_all_children()[i].bg = beautiful.taskbar_fg
			else
				template:get_children_by_id("taskselector")[1]:get_all_children()[i].bg = beautiful.taskbar_fg_off
			end
		end
	end)

	template:connect_signal("button::release", function(content, lx, ly, button)
		if button == 1 then
			-- Put fancy code for pressing the thingy here! :3c
			template.cycle_item()
			template:emit_signal("module::taskbar:raise")
		elseif button == 3 then
			awful.spawn(string.lower(task.class or task.name), {screen = mouse.screen})
		end
	end)

	template:connect_signal("module::taskbar:raise", function()
		template.tasklist[template.task_index].first_tag:view_only()
		template.tasklist[template.task_index]:activate { context = 'taskbar_raise', raise = true } end
	)
	template:connect_signal("module::taskbar:fix_bg", function()
		template.bg = get_bg(task).task_bg end
	)
	return template
end

local taskbar_creator = function(s)
	s.taskbar_items = {indexpoint = 0}
	s.taskbar_tasks = {}

--	s.alttab = wibox {
--		screen = s,
--		visible = false,
--		ontop = true,
--		type = 'dock',
--		width = s.geometry.width, --dpi(500),
--		height = s.geometry.height, --dpi(150),
--		x = 0, --s.geometry.width / 2 - dpi(250),
--		y = 0, --s.geometry.height / 2 - dpi(75),
--		bg = beautiful.background,
--		fg = beautiful.fg_normal,
--		shape = function(cr, width, height)
--			gears.shape.rounded_rect(cr, width, height, dpi(20))
--		end
--	}

	--s.alttab_apps = update_alttab(s)

	s.bottombar = wibox.widget {
		widget = wibox.container.background,
		bg = beautiful.taskbar_fg,
		forced_height = dpi(10),
		--forced_width  = dpi(100),
	}

	if config.taskbar_type == 'floating' then
		s.taskbar = awful.popup {
			widget = {}, -- include nothing, this is purely for functionality
			screen = s,
			opacity = 0,
			visible = true,
			ontop = true,
			type = 'desktop',
			width = dpi(500),
			height = dpi(150),
			bg = beautiful.taskbar_background,
			fg = beautiful.taskbar_text_colour,
			placement = awful.placement.bottom,
			preferred_anchors = 'middle',
			preferred_positions = {'left', 'right', 'top', 'bottom'}
		}

		s.bottombar:connect_signal("mouse::enter", function()
									   s.taskbar.opacity = 1
									   s.taskbar.type = 'notification'
		end)

		s.taskbar:connect_signal("mouse::leave", function()
									 s.taskbar.opacity = 0
									 s.taskbar.type = 'desktop'
		end)
	elseif config.taskbar_type == 'dock' then
		s.taskbar = awful.wibar {
			position = 'bottom',
			screen = s,
			type = 'dock',
			bg = beautiful.transparent,
			height = dpi(90),
			widget = {}
		}
	elseif config.taskbar_type == 'unity' then
		s.taskbar = awful.wibar {
			position = 'left',
			screen = s,
			type = 'dock',
			bg = beautiful.transparent,
			width = dpi(85),
			widget = {}
		}
	end

	-- list of all apps that should be displayed (to launch)
	s.taskboot_list = {
		taskboot_creator('librewolf'),
		taskboot_creator('discord'),
		taskboot_creator('steam'),
		taskboot_creator('thunar'),
		taskboot_creator('emacs'),
		taskboot_creator('kitty'),
		taskboot_creator('pamac-manager')
	}


	s.taskbar:connect_signal("module::taskbar:update", function()
		s.taskbar_items.indexpoint = 0
		s.taskbar_tasks = {}
		if config.taskbar_type == 'unity' then
			s.taskbar_tasklist = {widget = wibox.layout.fixed.vertical, spacing = dpi(5)} -- doing it this way is sorta sketch, may break in future updates
		else
			s.taskbar_tasklist = {widget = wibox.layout.fixed.horizontal, spacing = dpi(5)}
		end

		local tasklist_temp = {}
		for _, task in ipairs(client.get()) do
			-- Make & append task widgets
			if ((task.class or task.name) and task.focusable and not task.skip_taskbar) then
				local tasktemp_name = string.lower(task.class or task.name)
				if tasklist_temp[tasktemp_name] then
					table.insert(tasklist_temp[tasktemp_name], task)
				else
					tasklist_temp[tasktemp_name] = {task}
					--table.insert(s.alttab_tasks, {task})
				end
			end
		end

		for i, taskboot in ipairs(s.taskboot_list) do
			if not (tasklist_temp[taskboot.taskname]) then
				table.insert(s.taskbar_tasklist, s.taskboot_list[i])
			end
		end

		s.taskbar_taskitems = {}
		for taskname in pairs(tasklist_temp) do
			local task = taskwidget_creator(tasklist_temp[taskname])
			table.insert(s.taskbar_tasklist, task)
			table.insert(s.taskbar_taskitems, task)
		end

		if config.taskbar_type == 'unity' then
			s.taskbar : setup {
				layout = wibox.layout.align.horizontal,
				expand = 'none',
				nil,
				{
					layout = wibox.container.margin,
					left = dpi(6),
					top = dpi(6),
					bottom = dpi(6),
					{
						widget = wibox.container.background,
						bg = beautiful.background,
						fg = beautiful.taskbar_text_colour,
						shape = function(cr, width, height)
							gears.shape.rounded_rect(cr, width, height, dpi(25))
						end,
						{
							widget = wibox.container.margin,
							margins = dpi(3),
							s.taskbar_tasklist,
						},
					},
				},
				nil,
			}
		elseif config.taskbar_type == 'dock' then
			s.taskbar : setup {
				widget = wibox.container.background,
				bg = beautiful.background,
				{
					layout = wibox.layout.align.horizontal,
					expand = 'none',
					nil,
					{
						layout = wibox.layout.align.vertical,
						expand = 'none',
						nil,
						{
							widget = wibox.container.background,
							bg = beautiful.transparent,
							fg = beautiful.taskbar_text_colour,
							shape = function(cr, width, height)
								gears.shape.rounded_rect(cr, width, height, dpi(25))
							end,
							{
								layout = wibox.layout.fixed.vertical,
								{
									widget = wibox.container.margin,
									margins = dpi(5),
									s.taskbar_tasklist,
								},
								s.bottombar,
							},
						},
						nil,
					},
					nil,
				}
			}
		else
			-- This is kinda stupid, might work though!
			s.taskbar : setup {
				layout = wibox.layout.align.horizontal,
				expand = 'none',
				nil,
				{
					layout = wibox.layout.align.vertical,
					expand = 'none',
					nil,
					{
						widget = wibox.container.background,
						bg = beautiful.transparent,
						fg = beautiful.taskbar_text_colour,
						shape = function(cr, width, height)
							gears.shape.rounded_rect(cr, width, height, dpi(25))
						end,
						{
							layout = wibox.layout.fixed.vertical,
							{
								widget = wibox.container.margin,
								margins = dpi(5),
								s.taskbar_tasklist,
							},
							s.bottombar,
						},
					},
					nil,
				},
				nil,
			}
		end
	end)
end

screen.connect_signal("request::desktop_decoration", function(s)
	taskbar_creator(s)
end)

awesome.connect_signal("module::taskbar:update", function()
	for s in screen do
		s.taskbar:emit_signal("module::taskbar:update")
	end
end)

awesome.connect_signal("module::taskbar:hide", function(s)
	s.taskbar.visible = false
end)

awesome.connect_signal("module::taskbar:show", function()
	for s in screen do
		s.taskbar:emit_signal("module::taskbar:update")
		s.taskbar.visible = true
		--focused_s.taskbar_grabber:start()
	end
end)

client.connect_signal("list", function(s)
	for s in screen do
		s.taskbar:emit_signal("module::taskbar:update")
	end
end)

client.connect_signal("focus", function()
	-- Make a new function that updates *just* the indicator highlight and nothing else!
	-- Make this not interfere with the order of tasks in the taskbar so as to not disrupt the stacking layout
	for s in screen do
		for _,task in ipairs(s.taskbar_taskitems) do
			task:emit_signal("module::taskbar_indicator:update")
		end
	end
end)

awesome.emit_signal("module::taskbar:show")
