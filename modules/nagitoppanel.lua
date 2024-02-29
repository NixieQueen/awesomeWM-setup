-- A top panel lua script for Nagi! This is visually based on the 'powerarrow' toppanel theme by romockee
-- https://github.com/romockee/powerarrow
-- Created by Nekoking

-- Imports, this is unnecesary in case of either a global use of functions or an all rc.lua script
--require("awful")
--require("wibox")
--require("beautiful")
--require("naughty")
--require("gears")

-- First various small details that need to be addressed
local config_dir = gears.filesystem.get_configuration_dir()
local icon_dir = config_dir .. "/tempicons/"
-- Including these theming options in order to make it look right
beautiful.bg_systray = "#555555" -- Main bar colour!
beautiful.systray_icon_spacing = dpi(1)
beautiful.systray_max_rows = 1
beautiful.fg_normal = "#dddddd"


-- Clickable container
local clickable_container = function(widget)
  local container = wibox.widget {
    widget,
    widget = wibox.container.background
  }
  local old_cursor, old_wibox

  container:connect_signal('mouse::enter', function()
    container.bg = beautiful.enter_event
    local w = mouse.current_wibox
    if w then
      old_cursor, old_wibox = w.cursor, w
      w.cursor = 'hand1'
    end
  end)

  container:connect_signal('mouse::leave', function()
    container.bg = beautiful.leave_event
    if old_wibox then
      old_wibox.cursor = old_cursor
      old_wibox = nil
    end
  end)

  container:connect_signal('button::press', function()
    container.bg = beautiful.press_event
  end)

  container:connect_signal('button::release', function()
    container.bg = beautiful.release_event
  end)
  return container
end

-- Updatable widget
local update_widget_creator = function(icon, text, callback)
  local icon_func = function(icon)
    if icon then
      local icon = wibox.widget {
        widget = wibox.widget.imagebox,
        image = icon,
        resize = true,
      }
      return icon
    else
      return nil
    end
  end
  local icon_widget = icon_func(icon)

  local text_func = function(text)
    if text then
      local text = wibox.widget {
        widget = wibox.widget.textbox,
        markup = "empty",
        font = beautiful.sysboldfont .. dpi(10),
      }
      return text
    else
      return nil
    end
  end
  local text_widget = text_func(text)

  local updatable = wibox.widget {
    layout = wibox.layout.align.vertical,
    expand = 'none',
    nil,
    {
      layout = wibox.layout.fixed.horizontal,
      spacing = dpi(3),
      icon_widget,
      {
        layout = wibox.layout.align.vertical,
        expand = 'none',
        nil,
        text_widget,
        nil,
      }
    },
    nil,
  }

  if text then
    updatable:connect_signal("widget::update", function()
      awful.spawn.easy_async_with_shell(
        text, function(stdout)
          text_widget.markup = tostring(stdout)
        end
      )
    end)
  end

  if callback then
    updatable:connect_signal("button::release", function()
        callback()
    end)
  end

  return updatable
end

-- Powerline widget creator
local powerline_widget_creator = function(colour, app, shape, inverse)
  local inverse = inverse or 1
  local powerline = wibox.widget {
    widget = wibox.container.background,
    bg = colour,
    shape = function(cr, width, height)
      gears.shape.transform(shape or gears.shape.powerline) : translate(0,0) (cr,width,height, inverse * -20)
    end,
    {
      layout = wibox.layout.align.horizontal,
      expand = 'none',
      nil,
      {
        widget = wibox.container.margin, -- Add a little margin between our app and the background shape
        left = dpi(25),
        right = dpi(26),
        top = dpi(2),
        bottom = dpi(2),
        app,
      },
      nil,
    }
  }
  return powerline
end

-- A function to combine two types of powerlines
local powerline_duo_creator = function(colour, app, app2)
  local powerline1 = powerline_widget_creator(colour, app, gears.shape.rectangular_tag, -1)
  local powerline2 = powerline_widget_creator(colour, app2, gears.shape.rectangular_tag)

  local duo = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    spacing = dpi(-42),
    powerline1,
    powerline2,
  }
  return duo
end


-- Everything needs to be run on a per-screen basis
local toppanel_creator = function(s)
  -- The layoutbox, this handles the window layout
  local layoutbox = awful.widget.layoutbox {
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

  -- taglist!
  local workspacelist = awful.widget.taglist {
    screen = s,
    filter = awful.widget.taglist.filter.all,
    style = {
      --shape = gears.shape.circle,
      bg_focus = "#2d2d2d",
      fg_focus = "#51c9c5",
      bg_empty = "#2d2d2d",
      fg_empty = beautiful.fg_normal,
      font = beautiful.sysboldfont .. dpi(15),
    },
    layout = {
      spacing = dpi(15), -- Amount of space between tag numbers
      layout = wibox.layout.fixed.horizontal,
    },
    widget_template = {
      {
        id = 'text_role',
        widget = wibox.widget.textbox,
        --font = beautiful.sysfont .. dpi(15),
      },
      --fg = "#999999",
      --id = 'background_role',
      widget = wibox.container.background,
      create_callback = function(self, c3, index, objects)
        --self:get_children_by_id('index_role')[1].markup = '<b> ' ..c3.index.. ' </b>'
        self:connect_signal('mouse::enter', function()
          if self.fg ~= '#31a9a5' then
            self.backup     = self.fg
            self.has_backup = true
          end
          self.fg = '#31a9a5'
        end)
        self:connect_signal('mouse::leave', function()
          if self.has_backup then self.fg = self.backup end
        end)
      end,
      update_callback = function(self, c3, index, objects)
        --self:get_children_by_id('index_role')[1].markup = '<b> ' ..c3.index.. ' </b>'
      end,
    },
    buttons = {
      awful.button({ }, 1, function(t) t:view_only() end),
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


  -- These functions provide the 'widget' that makes up the icon and text. Colour is not a factor here
  local temperature = update_widget_creator(
    gears.color.recolor_image(icon_dir .. "temp.png", beautiful.fg_normal),
    [[sh -c "echo $(paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/' | grep "x86_pkg_temp" | awk '{print $2}')"]]
  )
  local disk = update_widget_creator(
    gears.color.recolor_image(icon_dir .. "hdd.png", beautiful.fg_normal),
    [[sh -c "echo $(df -h / | grep / | awk '{printf "%.1fGB", $3}')"]]
  )
  local cpu = update_widget_creator(
    gears.color.recolor_image(icon_dir .. "cpu.png", beautiful.fg_normal),
    [[sh -c "echo $(grep 'cpu MHz' /proc/cpuinfo | awk '{ghzsum+=$NF+0} END {printf "%.1f Ghz", ghzsum/NR/1000}')"]]
  )
  local cpu_usage = update_widget_creator(
    nil,
    [[top -bn1 | grep %Cpu | awk '{printf "%.1f%", $2}']]
  )
  local mem = update_widget_creator(
    gears.color.recolor_image(icon_dir .. "mem.png", beautiful.fg_normal),
    [[sh -c "echo $(free | grep Mem | awk '{printf "%.0f MB", ($2-$7)/1000-0.4}')"]]
  )
  local download = update_widget_creator(
    gears.color.recolor_image(icon_dir .. "download.png", beautiful.fg_normal),
    [[sh -c "echo $(echo $(cat /sys/class/net/enp4s0/statistics/tx_bytes) $(sh -c "sleep 1 && cat /sys/class/net/enp4s0/statistics/tx_bytes") | awk '{printf "%.2f MiB/s", ($2-$1)/10000}')"]]
  )
  local upload = update_widget_creator(
    gears.color.recolor_image(icon_dir .. "upload.png", beautiful.fg_normal),
    [[sh -c "echo $(echo $(cat /sys/class/net/enp4s0/statistics/rx_bytes) $(sh -c "sleep 1 && cat /sys/class/net/enp4s0/statistics/rx_bytes") | awk '{printf "%.2f MiB/s", ($2-$1)/10000}')"]]
  )

  -- Leave roughly .5 seconds between each timer here so the cpu doesn't have to 'spike' in activity to keep up.
  local temp_timer = gears.timer {timeout=.1, autostart = true, single_shot = true, callback = function() temperature:emit_signal("widget::update") end}
  local disk_timer = gears.timer {timeout=.6, autostart = true, single_shot = true, callback = function() disk:emit_signal("widget::update") end}
  local cpu_timer = gears.timer {timeout=1.1, autostart = true, single_shot = true, callback = function() cpu:emit_signal("widget::update") end}
  local cpu_usage_timer = gears.timer {timeout=1.1, autostart = true, single_shot = true, callback = function() cpu_usage:emit_signal("widget::update") end}
  local mem_timer = gears.timer {timeout=1.6, autostart = true, single_shot = true, callback = function() mem:emit_signal("widget::update") end}
  local download_timer = gears.timer {timeout=2.1, autostart = true, single_shot = true, callback = function() download:emit_signal("widget::update") end}
  local upload_timer = gears.timer {timeout=2.6, autostart = true, single_shot = true, callback = function() upload:emit_signal("widget::update") end}


  -- The function that updates everything on a regular interval
  local update_widgets = function()
    temp_timer:again()
    disk_timer:again()
    cpu_timer:again()
    cpu_usage_timer:again()
    mem_timer:again()
    download_timer:again()
    upload_timer:again()
    --temperature:emit_signal("widget::update")
    --temperature:emit_signal("widget::update")
  end
  local update_timer = gears.timer {
    timeout = 5,
    call_now = true,
    autostart = true,
    callback = update_widgets
  }

  local task = update_widget_creator(
    gears.color.recolor_image(icon_dir .. "task.png", beautiful.fg_normal)
  )
  local music = update_widget_creator(
    gears.color.recolor_image(icon_dir .. "music.png", beautiful.fg_normal)
  )
  local mail = update_widget_creator(
    gears.color.recolor_image(icon_dir .. "mail.png", beautiful.fg_normal)
  )
  local scissors = update_widget_creator(
    gears.color.recolor_image(icon_dir .. "scissors.png", beautiful.fg_normal)
  )

  -- General constructor for the top panel
  local toppanel = awful.wibar {
    position = 'top',
    screen = s,
    height = dpi(30), -- change this to whatever size you'd prefer, 40 is meant for  a 1440p screen
    type = 'splash', -- tells your compositor what type of object your toppanel is, change this if transparency & blur are concerns
    bg = "#2d2d2d", -- the general background colour
    widget = {
      layout = wibox.layout.align.horizontal,
      expand = 'none',
      {-- leftbound box (tags)
        widget = wibox.container.margin,
        left = dpi(20),
        {
          workspacelist,
          layout = wibox.layout.fixed.horizontal,
        },
      },
      nil, -- middlebound box (empty)
      {-- rightbound box (funny number thingies go here)
        -- everything in here has an assigned colour. Feel free to change these values as they work indepently from any other code
        powerline_widget_creator("#1e1f1f", scissors),
        powerline_widget_creator("#474a4a", mail),
        powerline_widget_creator("#1e1f1f", music),
        powerline_widget_creator("#474a4a", task),
        powerline_widget_creator("#878c8a", mem),
        powerline_duo_creator("#3f6b65", cpu, cpu_usage),
        powerline_widget_creator("#b35d40", disk),
        powerline_duo_creator("#8c8b77", upload, download),
        powerline_widget_creator("#502952", temperature),
        powerline_widget_creator(beautiful.bg_systray, wibox.widget.systray()),
        powerline_widget_creator("#363636", layoutbox),
        layout = wibox.layout.fixed.horizontal,
        spacing = dpi(-23),
      },
    }
  }
  return toppanel
end

-- Create a toppanel for every screen upon reaching 'desktop_decoration'
screen.connect_signal("request::desktop_decoration", function(s)
  s.toppanel = toppanel_creator(s)
end)
