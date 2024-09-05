-- Alttab setup, this is very experimental so it might break!
-- Every time you press alt-tab it should remake the alttab menu
-- First set up task widget

-- Get the right colour for the application
local get_bg = function(task)
	if task.minimized then
		local task_bg = beautiful.alttab_bg_minimize
		local task_fg = beautiful.primary_off
		return {task_bg = task_bg, task_fg = task_fg}
	elseif task.ontop then
		local task_bg = beautiful.alttab_bg_focus
		local task_fg = beautiful.alttab_fg_focus
		return {task_bg = task_bg, task_fg = task_fg}
	else
		local task_bg = beautiful.alttab_bg_normal
		local task_fg = beautiful.primary
		return {task_bg = task_bg, task_fg = task_fg}
	end

	return {task_bg = task_bg, task_fg = task_fg}
end

local taskwidget_creator = function(tasklist)
	local task = tasklist[1]
	local taskcolours = get_bg(task)

	local template = wibox.widget {
		id = 'taskbackground',
		forced_width = dpi(120),
		forced_height = dpi(120),
		widget = wibox.container.background,
		shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, dpi(20))
		end,
		fg = taskcolours.task_fg,
		bg = taskcolours.task_bg,
		{
			fill_space = false,
			layout = wibox.layout.fixed.vertical,
			{
				layout = wibox.layout.align.horizontal,
				expand = 'none',
				nil,
				{
					appicon(string.lower(task.class or task.name), true, task),
					margins = dpi(5),
					forced_height = dpi(80),
					widget = wibox.container.margin,
				},
				nil,
			},
			{
				layout = wibox.layout.align.horizontal,
				expand = 'none',
				nil,
				{
					{
						id = 'text',
						widget = wibox.widget.textbox,
						font = beautiful.sysboldfont .. dpi(18),
						markup = string.lower(task.class or task.name),
					},
					id = 'textmargin',
					left = dpi(2),
					right = dpi(2),
					widget = wibox.container.margin,
				},
				nil,
			},
			{
				layout = wibox.layout.align.horizontal,
				expand = 'none',
				nil,
				{
					id = 'taskselector',
					layout = wibox.layout.fixed.horizontal,
					spacing = dpi(3),
				},
				nil,
			},
		},
	}

	template.tasklist = tasklist
	template.task_index = 0

	template.cycle_item = function()
		if not (template.task_index == 0) then
			template:get_children_by_id("taskselector")[1]:get_all_children()[template.task_index].bg = beautiful.secondary_off
		end
		if template.task_index < #template.tasklist then
			template.task_index = template.task_index + 1
		else
			template.task_index = 0
			return false
		end
		template:get_children_by_id("taskselector")[1]:get_all_children()[template.task_index].bg = beautiful.secondary
		return true
	end

	add_tasklist = function()
		local size = dpi((80 - 3 * (#template.tasklist - 1)) / #template.tasklist)
		local count = 0
		for _,item in ipairs(template.tasklist) do
			count = count + 1
			template:get_children_by_id("taskselector")[1]:add(
				{
					id = "task" .. tostring(count),
					widget = wibox.container.background,
					bg = beautiful.secondary_off,
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

	template:connect_signal("module::alttab:raise", function()
		raise_task = template.tasklist[template.task_index]
		raise_task.first_tag:view_only()
		raise_task:activate { context = 'taskbar_raise', raise = true } end
	)
	template:connect_signal("module::alttab:fix_bg", function()
		template.bg = get_bg(task).task_bg end
	)
	return template
end

local alttab_creator = function(s)
	s.alttab_items = {indexpoint = 0}
	s.alttab_tasks = {}

	s.alttab = awful.popup {
		widget = {}, -- include nothing, this is purely for functionality
		screen = s,
		visible = false,
		ontop = true,
		type = 'notification',
		width = dpi(500),
		height = dpi(150),
		bg = beautiful.alttab_bg,
		fg = beautiful.fg_normal,
		placement = awful.placement.centered,
		preferred_anchors = 'middle',
		preferred_positions = {'left', 'right', 'top', 'bottom'}
	}
	
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

	local cycle_tasklist = function()
		local tablelength = #s.alttab_tasklist
		-- Cycle the tasklist here!
		if s.alttab_items.indexpoint < tablelength then
			s.alttab_items.indexpoint = s.alttab_items.indexpoint + 1
		else
			s.alttab_items.indexpoint = 1
		end
		if s.alttab_items.indexpoint == 1 then
			s.alttab_tasklist[tablelength]:emit_signal("module::alttab:fix_bg")
		else
			s.alttab_tasklist[s.alttab_items.indexpoint - 1]:emit_signal("module::alttab:fix_bg")
		end
		s.alttab_tasklist[s.alttab_items.indexpoint].bg = '#6a6a6a'
	end

	s.alttab_grabber = awful.keygrabber {
		auto_start = true,
		stop_event = 'release',
		mask_event_callback = true,
		keybindings = {
			awful.key {
				modifiers = {},
				key = 'Escape',
				on_press = function(self)
					self:stop()
					awesome.emit_signal("module::alttab:hide")
				end
			}
		},
		keypressed_callback = function(self, mod, key, command)
			if key == 'Tab' then
				if #s.alttab_tasklist == 0 then
					return
				end
				if not (s.alttab_items.indexpoint == 0) then
					if not s.alttab_tasklist[s.alttab_items.indexpoint].cycle_item() then
						cycle_tasklist()
						s.alttab_tasklist[s.alttab_items.indexpoint].cycle_item()
					end
				else
					cycle_tasklist()
					s.alttab_tasklist[s.alttab_items.indexpoint].cycle_item()
				end
			end
		end,
		keyreleased_callback = function(self, mod, key, command)
			if key == 'Alt_L' then
				-- The alttab button is released, end alttab here
				self:stop()
				awesome.emit_signal("module::alttab:hide")
				-- Raise window!!!
				if #s.alttab_tasklist > 0 and s.alttab_items.indexpoint > 0 then
					s.alttab_tasklist[s.alttab_items.indexpoint]:emit_signal("module::alttab:raise")
				end
			end
		end
	}

	s.alttab:connect_signal("module::alttab:update", function()
		s.alttab_items.indexpoint = 0
		s.alttab_tasks = {}
		s.alttab_tasklist = {widget = wibox.layout.fixed.horizontal, spacing = dpi(7)} -- doing it this way is sorta sketch, may break in future updates

		local tasklist_temp = {}
		for _, task in ipairs(client.get()) do
			-- Make & append task widgets
			if tasklist_temp[task.class or task.name] then
				table.insert(tasklist_temp[task.class or task.name], task)
			else
				tasklist_temp[task.class or task.name] = {task}
			--table.insert(s.alttab_tasks, {task})
			end
		end

		for taskname in pairs(tasklist_temp) do
			table.insert(s.alttab_tasklist, taskwidget_creator(tasklist_temp[taskname]))
		end

		-- This is kinda stupid, might work though!
		s.alttab : setup {
			layout = wibox.layout.align.horizontal,
			expand = 'none',
			nil,
			{
				layout = wibox.layout.align.vertical,
				expand = 'none',
				nil,
				{
					widget = wibox.container.background,
					bg = beautiful.alttab_client_bg,
					fg = beautiful.primary,
					shape = function(cr, width, height)
						gears.shape.rounded_rect(cr, width, height, dpi(25))
					end,
					{
						widget = wibox.container.margin,
						margins = dpi(7),
						s.alttab_tasklist,
					},
				},
				nil,
			},
			nil,
		}
	end)
end

screen.connect_signal("request::desktop_decoration", function(s)
	alttab_creator(s)
end)

awesome.connect_signal("module::alttab:hide", function()
	for s in screen do
		s.alttab.visible = false
	end
end)

awesome.connect_signal("module::alttab:show", function()
	awesome.emit_signal("module::alttab:hide")
	local focused_s = awful.screen.focused()
	--focused_s.alttab_apps = update_alttab(focused_s)
	focused_s.alttab:emit_signal("module::alttab:update")
	focused_s.alttab.visible = true
	focused_s.alttab_grabber:start()
end)
