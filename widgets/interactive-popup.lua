-- This file contains some functions to generalize all interactive notifications ( calendar, volume, systray )
-- and make behaviour similar.
-- This should be called with an already existing popup as argument.
local function generate_interactive_popup(popup, timed)
  local timed = timed or 5
  local timeout_timer = gears.timer {
    timeout = timed,
    single_shot = true,
    callback = function()
      popup:emit_signal("widget::interactive-popup:hide")
    end
  }

  popup:connect_signal("mouse::enter", function()
    timeout_timer:stop()
  end)

  popup:connect_signal("mouse::leave", function()
    timeout_timer:again()
  end)

  popup:connect_signal("widget::interactive-popup:show", function()
    popup.visible = true
    timeout_timer:again()
  end)

  popup:connect_signal("widget::interactive-popup:hide", function()
    popup.visible = false
  end)

  return popup
end
return generate_interactive_popup
