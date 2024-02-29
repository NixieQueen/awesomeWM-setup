-- This widget is for switching the performance profile using TLP. It relies on the following commands:
-- pkexec for getting polkit authority
-- tlp bat / tlp ac / tlp start for switching performance types (manual / manual / auto)
-- This widget is then used in a module like toppanel to make it easily accessable to the user!
local function performance_button_creator(button_text)
  local button = wibox.widget {
    id = "font_colour",
    widget = wibox.container.background,
    forced_width = dpi(150),
    bg = beautiful.performancewidget_bg_normal,
    fg = beautiful.performancewidget_font_colour_off,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(20))
    end,
    {
      widget = clickable_container,
      {
        widget = wibox.container.margin,
        left = dpi(2),
        right = dpi(2),
        {
          id = "text_block",
          widget = wibox.widget.textbox,
          halign = "center",
          valign = "center",
          text = button_text,
          font = beautiful.performancewidget_font
        },
      },
    }
  }
  button.button_text = button_text
  return button
end

-- The actual creator!
local function performance_switch_creator()
  local auto_button = performance_button_creator("Auto")
  local bat_button = performance_button_creator("Battery")
  local ac_button = performance_button_creator("AC")

  local selector_widget = wibox.widget {
    widget = wibox.container.background,
    forced_height = dpi(40),
    forced_width = dpi(20),
    bg = beautiful.performancewidget_selector_bg,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(20))
    end,
  }
  selector_widget.point = {x=0,y=0}
  local selector_layout = wibox.widget {
    layout = wibox.layout.manual,
    forced_width = dpi(20),
  }
  selector_layout:add(selector_widget)
  local selector_animation = rubato.timed {
    intro = 0.5,
    duration = 1.5,
    rate = 60,
    easing = rubato.quadratic,
    subscribed = function(pos, delta, goal)
      selector_layout:move_widget(selector_widget, {x = 0, y = pos * (dpi(172) / 2) - (dpi(40) / 2 * pos)})
    end
  }
  local selector_animation_height = rubato.timed {
    intro = 0.5,
    duration = 1.5,
    rate = 60,
    easing = rubato.quadratic,
    subscribed = function(pos)
      selector_widget.forced_height = math.max(math.cos(pos) * 12 + 28, 20)
    end
  }

  local function update_switch()
    auto_button:get_children_by_id("font_colour")[1].fg = beautiful.performancewidget_font_colour_off
    bat_button:get_children_by_id("font_colour")[1].fg = beautiful.performancewidget_font_colour_off
    ac_button:get_children_by_id("font_colour")[1].fg = beautiful.performancewidget_font_colour_off
    awful.spawn.easy_async_with_shell(
      [[tlp-stat -s | grep Mode | awk '{print $3$4}']],
      function(stdout)
        local stdout = tostring(stdout):gsub("\n", "")
        if (stdout == "AC" or stdout == "battery") then
          selector_animation.target = 0
          auto_button:get_children_by_id("font_colour")[1].fg = beautiful.performancewidget_font_colour
          auto_button:get_children_by_id("text_block")[1].text = auto_button.button_text .. " (" .. stdout .. ")"
        elseif (stdout == "battery(manual)" or stdout == "battery(persistent)") then
          selector_animation.target = 1
          bat_button:get_children_by_id("font_colour")[1].fg = beautiful.performancewidget_font_colour
        elseif (stdout == "AC(manual)" or stdout == "AC(persistent)") then
          selector_animation.target = 2
          ac_button:get_children_by_id("font_colour")[1].fg = beautiful.performancewidget_font_colour
        else
          naughty.notification({text="Performance switcher was returned an unexpected value!"})
        end
        selector_animation_height.target = selector_animation_height.target + 2 * math.pi
      end
    )
  end

  auto_button:connect_signal("button::release", function()
    awful.spawn.easy_async_with_shell(
      [[pkexec tlp start]],
      function(stdout)
        update_switch()
      end
    )
  end)

  bat_button:connect_signal("button::release", function()
    awful.spawn.easy_async_with_shell(
      [[pkexec tlp bat]],
      function(stdout)
        update_switch()
      end
    )
  end)

  ac_button:connect_signal("button::release", function()
    awful.spawn.easy_async_with_shell(
      [[pkexec tlp ac]],
      function(stdout)
        update_switch()
      end
    )
  end)

  local performance_widget = awful.popup {
    screen = s,
    visible = false,
    --width = dpi(300),
    ontop = true,
    --height = dpi(500),
    --hide_on_right_click = true,
    bg = beautiful.performancewidget_bg,
    preferred_positions = 'bottom',
    preferred_anchors = 'middle',
    --placement = function(cr)
    --	awful.placement.top(cr,{honor_workarea=true})
    --end,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(20))
    end,
    widget = {},
  }
  local performance_widget = interactive_popup(performance_widget, 2)

  performance_widget : setup {
    layout = wibox.layout.fixed.horizontal,
    spacing = dpi(5),
    {
      widget = wibox.container.margin,
      top = dpi(14),
      bottom = dpi(14),
      forced_height = dpi(200),
      {
        widget = wibox.container.background,
        bg = beautiful.performancewidget_bg_normal,
        shape = function(cr, width, height)
          gears.shape.rounded_rect(cr, width, height, dpi(20))
        end,
        selector_layout,
      }
    },
    {
      layout = wibox.layout.flex.vertical,
      spacing = dpi(3),
      auto_button,
      bat_button,
      ac_button,
    }
                             }
  update_switch()
  return performance_widget
end
return performance_switch_creator
