-- The following script manages monitors and aligns them from left (primary) to right.
-- I would not recommend using this in combination with arandr or similar programs.
-- All of this is handled with xrandr
local recent_read = ""

local function run_screen_command(newscreens, off_screens, config)
  local command
  if config then
    command = "xrandr --output " .. newscreens[1] .. " --primary --pos " .. config[1]
  else
    command = "xrandr --output " .. newscreens[1] .. " --primary"
  end
  for i,newscreen in ipairs(newscreens) do
    if not (i == 1) then
      if config then
        if not config[i] then
          command = command .. " --output " .. newscreen .. " --auto --right-of " .. newscreens[i-1]
        else
          command = command .. " --output " .. newscreen .. " --auto --pos " .. config[i]
        end
      else
        command = command .. " --output " .. newscreen .. " --auto --right-of " .. newscreens[i-1]
      end
    end
  end

  for i,off_screen in ipairs(off_screens) do
    command = command .. " --output " .. off_screen .. " --off"
  end
  awful.spawn.easy_async_with_shell(
    command,
    function()
      awesome.emit_signal("module::dynamic_background:screen_refresh")
    end
  )
end

local function read_screen_setup(newscreens, off_screens, config_name)
  local config = {}
  local config_command = [[cat ~/.config/awesome/configs/screensetup/]] .. config_name .. [[.conf]]
  awful.spawn.easy_async_with_shell(
    config_command,
    function(stdout)
      for screenconfig in string.gmatch(stdout, "([^\n]+)") do
        local keys = {}
        for key in string.gmatch(screenconfig, "([^: ]+)") do
          table.insert(keys, key)
        end
        table.insert(config, keys[2])
      end
      run_screen_command(newscreens, off_screens, config)
      awesome.emit_signal("module::dynamic_background:screen_refresh")
    end
  )
end

local function read_screen_data()
  awful.spawn.easy_async_with_shell(
    [[xrandr | grep "connected" | awk '{printf "%s|%s|%s\n", $1, $2, $3}']],
    --[[watch -n 1 -t "xrandr | grep "connected" | awk '{printf \"%s|%s|%s\n\", \$1, \$2, \$3}'"]]
    function(stdout)
      if not (stdout == recent_read) then
        recent_read = stdout
        local newrecent_screens = {}
        local disrecent_screens = {}
        for newscreen in string.gmatch(stdout, "([^\n]+)") do
          local newscreen_string = {}
          for str in string.gmatch(newscreen, "([^|]+)") do
            table.insert(newscreen_string, str)
          end

          if newscreen_string[3] == "primary" then
            table.insert(newrecent_screens, 1, newscreen_string[1])
          else
            if newscreen_string[2] == "connected" then
              table.insert(newrecent_screens, newscreen_string[1])
            else
              table.insert(disrecent_screens, newscreen_string[1])
            end
          end
        end
        read_screen_setup(newrecent_screens, disrecent_screens, "1mon")
      end
    end
  )
end

local function screen_widget_creator(max_width, max_height, spacing_amount)
  local max_width = max_width or dpi(1000)
  local max_height = max_height or dpi(300)
  local spacing_amount = spacing or dpi(10)
  local screencount = screen:count()

  local screens_widget = wibox.widget {
    layout = wibox.container.place,
    {
      id = 'screenlayout',
      layout = wibox.layout.fixed.horizontal,
      spacing = spacing_amount,
    }
  }

  for s in screen do
    local stack_screen_widget = wibox.widget {
      layout = wibox.layout.stack,
      {
        widget = clickable_container
      },
      {
        layout = wibox.container.place,
        halign = "right",
        valign = "top",
        {
          layout = wibox.container.margin,
          left = dpi(10),
          top = dpi(8),
          right = dpi(10),
          bottom = dpi(8),
          {
            layout = wibox.container.background,
            shape = function(cr, width, height)
              gears.shape.rounded_rect(cr, width, height, dpi(10))
            end,
            bg = beautiful.applauncher_index_bg,
            fg = beautiful.applauncher_text_colour,
            forced_width = dpi(35),
            forced_height = dpi(50),
            {
              layout = wibox.container.place,
              {
                widget = wibox.widget.textbox,
                markup = s.index,
                font = beautiful.sysboldfont .. dpi(40),
              }
            }
          }
        }
      }
    }

    local screen_widget = wibox.widget {
      layout = wibox.container.background,
      bg = beautiful.background,
      border_color = beautiful.transparent,
      border_width = dpi(5),
      shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, dpi(20))
      end,
      forced_height = max_height,
      width = math.min(max_width / screencount - spacing_amount * (screencount-1), dpi(400)),
      stack_screen_widget,
    }

    screen_widget:connect_signal("button::press", function(self, lx, ly, button)
      if button == 1 then
        for _,screen_button in ipairs(screens_widget:get_children_by_id("screenlayout")[1].children) do
          screen_button.border_color = beautiful.transparent
        end
        self.border_color = beautiful.applauncher_selected_field
        selected_screen = s
      end
    end)

    local screenshot = awful.screenshot {screen = s}
    screenshot:refresh()
    stack_screen_widget:insert(1,screenshot.content_widget)
    screens_widget:get_children_by_id("screenlayout")[1]:add(screen_widget)
  end
  return screens_widget
end

local function screenmanager()
  local screenmanager = awful.popup {
    widget = {},
    screen = screen.primary,
    visible = true,
    ontop = true,
    type = 'notification',
    width = dpi(500),
    height = dpi(300),
    bg = beautiful.background,
    fg = beautiful.fg_normal,
    placement = awful.placement.centered,
    preferred_anchors = 'middle',
    preferred_positions = {'left', 'right', 'top', 'bottom'}
  }
end

awesome.connect_signal("utils::screenmanager:update", read_screen_data)
awful.spawn.with_shell(gfs.get_configuration_dir() .. "/utils/launch_screenudev.sh")
