-- A widget-button for the compositor
local function create_button_picom(colour, sizeX, sizeY, font)
  local picom_button = widget_button(icons.picom, "Compositor", colour, sizeX, sizeY, font)


  picom_button:connect_signal("widget::widget_button:toggle_on", function()
    awful.spawn.with_shell("picom --animations -b")
  end)

  picom_button:connect_signal("widget::widget_button:toggle_off", function()
    awful.spawn.with_shell("killall picom")
  end)

  picom_button:connect_signal("widget::widget_button:settings_open", function()
    picom_button.forced_height = sizeY*4
  end)

  picom_button:connect_signal("widget::widget_button:settings_close", function()
    picom_button.forced_height = sizeY
  end)
  return picom_button
end

return create_button_picom
