-- This tool is meant for handling various screenshot usecases.
-- A simple 'screen', rectangle select and timer
-- ctrl dictates a 'screen' screenshot, shift decides timer
local function save_screenshot(selected_screen, interactive, timer)
  local screenshot
  if not interactive then
    screenshot = awful.screenshot(
      {
        directory = beautiful.screenshot_folder,
        prefix = beautiful.screenshot_prefix,
        date_format = beautiful.screenshot_date_format,
        screen = selected_screen,
        auto_save_delay = timer or 0.01
      }
    )
  else
     screenshot = awful.screenshot(
      {
        directory = beautiful.screenshot_folder,
        prefix = beautiful.screenshot_prefix,
        date_format = beautiful.screenshot_date_format,
        cursor = "crosshair",
        interactive = true,
        auto_save_delay = timer or 0.01
      }
    )
  end

  local function notify()
    naughty.notification(
      {
        title = screenshot.file_name,
        message = "Screenshot saved!",
        icon = screenshot.surface,
        icon_size = dpi(128)
      }
    )
    awful.spawn.easy_async_with_shell("xclip -selection clipboard -t image/png "..beautiful.screenshot_folder.."'"..screenshot.file_name.."'")
  end
  screenshot:connect_signal("file::saved", notify)
  return screenshot
end

awesome.connect_signal("module::screenshottool:take_screenshot", function(args)
    save_screenshot(args.selected_screen, args.interactive, args.timer)
end)
