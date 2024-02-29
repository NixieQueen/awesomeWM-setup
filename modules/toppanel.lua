-- Top panel for various widgets and a settings menu!
-- This should replace the one found in start.lua
-- Import time!
local batbar = dofile(config_dir .. "/widgets/toparcbar.lua")

-- Battery bar
local bat_top_bar_func = function()
  if config.battery then
    return batbar(
      gears.color.recolor_image(icons.battery, beautiful.primary),
      [[sh -c "echo $(upower -d | grep -m 1 percentage: | awk '{print substr($2, 1, length($2)-1)}')"]],
      dpi(20),
      dpi(10),
      beautiful.primary,
      beautiful.primary_off
    )
  else
    return batbar(
      gears.color.recolor_image(icons.memory, beautiful.primary),
      [[sh -c "echo $(nvidia-smi | grep % | awk '{print $13-1}')"]],
      dpi(20),
      dpi(20),
      beautiful.primary,
      beautiful.primary_off
    )
  end
end
local bat_top_bar = bat_top_bar_func()

local battery_icon_update = function()
  awful.spawn.easy_async_with_shell(
    [[sh -c "echo $(upower -d | grep -m 1 state | awk '{print $2}')"]], function(stdout)
      local state = stdout:match('[^\n]*')
      if state == 'discharging' then
        bat_top_bar:emit_signal("widget::bar:discharge_icon")
      end
      if state == 'charging' then
        bat_top_bar:emit_signal("widget::bar:charge_icon")
      end
    end
  )
end

local bat_command = function() bat_top_bar:emit_signal("widget::bar:refresh") if config.battery then battery_icon_update() end end
bat_command()
local bat_timer = gears.timer {timeout = 60, autostart = true, single_shot=false, callback = bat_command}

-- button builder
local button_builder = function(imagefile, callback)
  local button = wibox.widget {
    left = dpi(0),
    right = dpi(0),
    widget = wibox.container.margin,
    {
      shape = gears.shape.rounded_rect,
      forced_width = dpi(40),
      forced_height = dpi(40),
      widget = clickable_container,
      {
        bg = beautiful.transparent,
        widget = wibox.container.background,
        {
          margins = dpi(3),
          widget = wibox.container.margin,
          {
            image = imagefile,
            widget = wibox.widget.imagebox,
          },
        },
      },
    },
  }
  button:connect_signal("button::release", function()
    callback() end
  )
  return button
end

local systray_widget = systray()
local systray_dock_function = function()
    systray_widget:emit_signal("widget::systray:show")
end

-- The performance switch! Only called here because it is moved back and forth between monitors
local performance_switch = performance_switcher_widget()

local toppanel_creator = function(s)
  -- Create every item that should be included in the panel
  local layoutbox = wibox.widget {
    shape = gears.shape.rounded_rect,
    forced_width = dpi(40),
    forced_height = dpi(40),
    widget = clickable_container,
    {
      widget = wibox.container.margin,
      margins = dpi(3),
      {
        widget = awful.widget.layoutbox,
        screen = s,
        buttons = {
          awful.button(
            {}, 1, function()
              awful.layout.inc(1) end
          ),
          awful.button(
            {}, 3, function()
              awful.layout.inc(-1) end
          ),
          awful.button(
            {}, 4, function()
              awful.layout.inc(-1) end
          ),
          awful.button(
            {}, 5, function()
              awful.layout.inc(1) end
          )
        }
      }
    }
  }

  s.toppanel_promptbox = awful.widget.prompt()

  local leftpanel_function = function()
    awesome.emit_signal("module::left_panel:show")
  end
  local leftpanel_button = button_builder(gears.color.recolor_image(icons.logout, beautiful.primary), leftpanel_function)

  local exitbutton_function = function()
    awesome.emit_signal("module::exit_screen:show")
  end
  local exitmenu_button = button_builder(gears.color.recolor_image(icons.shutdown, beautiful.primary), exitbutton_function)

  local clock_format = '<span font="' .. beautiful.sysboldfont .. dpi(20) .. '">%a %b %H:%M:%S</span>'

  local calendar_widget = calendar(s)

  local systray_dock = button_builder(gears.color.recolor_image(icons.cpu, beautiful.primary), systray_dock_function)

  local performancebutton_function = function()
    performance_switch:move_next_to(mouse.current_widget_geometry)
    performance_switch:emit_signal("widget::interactive-popup:show")
  end

  local performance_button = button_builder(gears.color.recolor_image(icons.cpu, beautiful.secondary), performancebutton_function)

  local clock = wibox.widget {
    widget = clickable_container,
    shape = gears.shape.rounded_rect,
    {
      widget = wibox.container.background,
      bg = beautiful.transparent,
      {
        widget = wibox.container.margin,
        left = dpi(2),
        right = dpi(2),
        {
          widget = wibox.widget.textclock(clock_format,1),
        },
      },
    },
  }

  clock:connect_signal("button::release", function()
    calendar_widget:move_next_to(mouse.current_widget_geometry)
    calendar_widget:emit_signal("widget::interactive-popup:show")
  end)

  -- taglist!
  s.workspacelist = awful.widget.taglist {
    screen = s,
    filter = awful.widget.taglist.filter.all,
    style = {
      shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, dpi(15))
      end
    },
    layout = {
      spacing = dpi(5),
      layout = wibox.layout.fixed.horizontal,
    },
    widget_template = {
      {
        {
          {
            {
              {
                {
                  id = 'index_role',
                  widget = wibox.widget.textbox,
                },
                margins = dpi(4),
                widget = wibox.container.margin,
              },
              bg = beautiful.primary_off .. "80",
              shape = gears.shape.circle,
              widget = wibox.container.background,
            },
            {
              {
                id = 'icon_role',
                widget = wibox.widget.imagebox,
              },
              margins = dpi(2),
              widget = wibox.container.margin,
            },
            {
              id = 'text_role',
              widget = wibox.widget.textbox,
            },
            layout = wibox.layout.fixed.horizontal,
          },
          left = dpi(18),
          right = dpi(18),
          widget = wibox.container.margin,
        },
        widget = clickable_container,
      },
      id = 'background_role',
      widget = wibox.container.background,
      create_callback = function(self, c3, index, objects)
        self:get_children_by_id('index_role')[1].markup = '<b> '..index..' </b>'
      end,
      update_callback = function(self, c3, index, objects)
        self:get_children_by_id('index_role')[1].markup = '<b> '..index..' </b>'
      end,
    },
    buttons = {
      awful.button({ }, 1, function(t)
          t:view_only()
          local first_client = t:clients()[1]
          if first_client then
            first_client:activate{context="taglist",raise=true}
          end
      end),
      awful.button({ 'Mod4' }, 1, function(t)
          if client.focus then
            client.focus:move_to_tag(t)
          end
      end),
      awful.button({ }, 3, awful.tag.viewtoggle),
      awful.button({ 'Mod4' }, 3, function(t)
          if client.focus then
            client.focus:toggle_tag(t)
          end
      end),
      awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
      awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end),
    }
  }

  local keyboardlayoutwidget = awful.widget.keyboardlayout()--{buttons = awful.button({  }, 1, function(self) self:next_layout() end)})
  keyboardlayoutwidget.widget.font = beautiful.keyboardlayoutwidget_font
  local keyboardlayoutbox = wibox.widget {
    widget = clickable_container,
    shape = gears.shape.rounded_rect,
    keyboardlayoutwidget,
  }
  keyboardlayoutbox:connect_signal("button::release", function()
    keyboardlayoutwidget:next_layout()
  end)

  -- Create the actual panel!
  local toppanel = awful.wibar {
    position = 'top',
    screen = s,
    height = dpi(50),
    type = 'dock',
    bg = beautiful.transparent,
    widget = {
      layout = wibox.container.margin,
      top = dpi(6),
      left = dpi(6),
      right = dpi(6),
      {
        layout = wibox.container.background,
        bg = beautiful.background,
        shape = function(cr, width, height)
          gears.shape.rounded_rect(cr, width, height, dpi(13))
        end,
        {
          layout = wibox.container.margin,
          margins = dpi(2),
          {
            layout = wibox.layout.align.horizontal,
            expand = 'none',
            {--leftbound
              layout = wibox.layout.fixed.horizontal,
              spacing = dpi(5),
              leftpanel_button,
              bat_top_bar,
              s.workspacelist,
              s.toppanel_promptbox,
            },
            {--middlebound
              layout = wibox.layout.fixed.horizontal,
              clock,
            },
            {--rightbound
              layout = wibox.layout.fixed.horizontal,
              keyboardlayoutbox,
              performance_button,
              systray_dock,
              layoutbox,
              exitmenu_button,
            },
          }
        }
      }
    }
  }
  --calendar_widget:move_next_to(toppanel)
  --calendar_widget.visible = false

  return toppanel
end

screen.connect_signal("request::desktop_decoration", function(s)
    s.toppanel = toppanel_creator(s)
end)
