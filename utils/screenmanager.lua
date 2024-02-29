-- The following script manages monitors and aligns them from left (primary) to right.
-- I would not recommend using this in combination with arandr or similar programs.
-- All of this is handled with xrandr
local recent_read = ""
local recent_screens = {}

local function run_screen_command(newscreens, off_screens)
  local command = "xrandr --output " .. newscreens[1] .. " --primary"
  for i,newscreen in ipairs(newscreens) do
    if not (i == 1) then
      command = command .. " --output " .. newscreen .. " --auto --right-of " .. newscreens[i-1]
    end
  end

  for i,off_screen in ipairs(off_screens) do
    command = command .. " --output " .. off_screen .. " --off"
  end
  awful.spawn.easy_async_with_shell(command, function() end)
end

local function read_screen_data()
  awful.spawn.easy_async_with_shell(
    [[xrandr | grep "connected" | awk '{printf "%s-%s-%s\n", $1, $2, $3}']],
    function(stdout)
      if not (stdout == recent_read) then
        recent_read = stdout
        local newrecent_screens = {}
        local disrecent_screens = {}
        for newscreen in string.gmatch(stdout, "([^\n]+)") do
          local newscreen_string = {}
          for str in string.gmatch(newscreen, "([^-]+)") do
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
        recent_screens = newrecent_screens
        run_screen_command(recent_screens, disrecent_screens)
      end
    end
  )
end

gears.timer {
  timeout = 1,
  autostart = true,
  call_now = true,
  callback = read_screen_data
}
