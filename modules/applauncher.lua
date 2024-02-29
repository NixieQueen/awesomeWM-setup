-- This script is for the applauncher! It reads from /usr/share/applications and accordingly assigns icons with appicon.lua
-- It is a replacement for rofi, but both can be used ^w^

-- Variables used for storing the selected apps and the selected screen
local selected_apps = {}
local selected_screen = screen[1]

-- A function for constructing the app buttons
local function build_app_button(desktopname, appname, iconname, exec)
  local contentBar
  if config.applauncher_name then
    contentBar = wibox.widget {
      fill_space = false,
      layout = wibox.layout.fixed.vertical,
      {
        layout = wibox.container.place,
        halign = "center",
        {
          appicon(iconname, false, false),
          margins = dpi(5),
          forced_height = dpi(90),
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
            markup = appname,
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
        appicon(iconname, false, false),
        margins = dpi(12),
        widget = wibox.container.margin,
      },
    }
  end

  local template = wibox.widget {
    id = 'appbackground',
    forced_width = dpi(140),
    forced_height = dpi(140),
    widget = wibox.container.background,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(20))
    end,
    fg = beautiful.applauncher_text_colour,
    bg = beautiful.applauncher_bg_normal,
    {
      widget = clickable_container,
      contentBar,
    }
  }

  template.desktopname = desktopname

  template:connect_signal("button::release", function(content, lx, ly, button)
    if button == 1 then
      -- Figure out if the button is already pressed
      local in_selected = false
      local placement = 0
      for selected_index,app in ipairs(selected_apps) do
        if (app.desktopname == desktopname) and (app.appname == appname) and (app.exec == exec) then
          in_selected = true
          placement = selected_index
          break
        end
      end
      if in_selected then
        table.remove(selected_apps,placement)
        template.bg = beautiful.applauncher_bg_normal
      else
        table.insert(selected_apps, {desktopname = desktopname, appname = appname, exec = exec, template = template})
        template.bg = beautiful.applauncher_selected_field
      end
    elseif button == 3 then
      awful.spawn(exec, {screen = selected_screen, role="nya"})
      awesome.emit_signal("module::applauncher:hide")
      --awful.spawn.with_shell(exec)
      --template:activate{context='applauncher', action='mouse_move'}
    end
  end)
  return template
end

local known_names = {}

local function grab_app_details(desktopname, grid) -- This inserts the newly created app in the given list
  local file_path
  if gfs.file_readable("/usr/share/applications/" .. desktopname) then
    file_path = "/usr/share/applications/" .. desktopname
  end
  if gfs.file_readable(string.gsub(gfs.get_xdg_config_home(),".config/","") .. ".local/share/applications/" .. desktopname) then
    file_path = string.gsub(gfs.get_xdg_config_home(),".config/","") .. ".local/share/applications/" .. desktopname
  end

  if file_path then
    -- make the app details
    local app = {appname = 'nil', iconname = 'nil', exec = 'nil'}
    --for line in string.gmatch(stdout, "([^\n]+)") do
    for line in io.lines(file_path) do
      local linedetail = {}
      for line_type in string.gmatch(line, "([^=]+)") do
        table.insert(linedetail, line_type)
      end
      if not (app.appname == 'nil' or app.iconname == 'nil' or app.exec == 'nil') then
        break
      end
      if linedetail[1] == "Name" then
        app.appname = tostring(linedetail[2])
      elseif linedetail[1] == "Icon" then
        app.iconname = tostring(linedetail[2])
      elseif linedetail[1] == "Exec" then
        --app.exec = tostring(linedetail[2]):gsub("%%U", string.gsub(gfs.get_xdg_config_home(),".config/",""))
        app.exec = tostring(linedetail[2]):gsub("%%U", ""):gsub("%%u", ""):gsub("%%F", "")
      end
    end
    local passed = true
    for _,known_app in ipairs(known_names) do
      if known_app.appname == app.appname and known_app.iconname == app.iconname and known_app.exec == app.exec then
        passed = false
      end
    end
    if passed then
      table.insert(known_names, {appname = app.appname, iconname = app.iconname, exec = app.exec})
      table.insert(grid, build_app_button(desktopname, app.appname, app.iconname, app.exec))
      --grid:add(build_app_button(desktopname, app.appname, app.iconname, app.exec))
    end
  end
end

local function index_builder(button_index, tabs, apps)
  local button
  if not (button_index == 1) then
    button = wibox.widget {
      shape = gears.shape.circle,
      forced_height = dpi(40),
      forced_width = dpi(40),
      widget = clickable_container,
      {
        id = "buttonbg",
        bg = beautiful.primary_off,
        widget = wibox.container.background,
      }
    }
  else
    button = wibox.widget {
      shape = gears.shape.circle,
      forced_height = dpi(40),
      forced_width = dpi(40),
      widget = clickable_container,
      {
        id = "buttonbg",
        bg = beautiful.primary,
        widget = wibox.container.background,
      }
    }
  end
  button:connect_signal("button::release", function()
    for _, tab in ipairs(tabs.children) do
      tab:get_children_by_id("buttonbg")[1].bg = beautiful.primary_off
    end
    button:get_children_by_id("buttonbg")[1].bg = beautiful.primary
    local stackwidget = apps
    local targetgrid
    for _, grid in ipairs(stackwidget.children) do
      if grid:get_children_by_id("appgrid" .. tostring(button_index))[1] then
        targetgrid = grid
        break
      end
    end
    stackwidget:raise_widget(targetgrid)
  end)
  return button
end

local function generate_apps(verify, searchterm)
  local tabs = wibox.widget {
    id = 'tabs',
    layout = wibox.layout.fixed.horizontal,
    spacing = dpi(5),
    forced_height = dpi(30)
  }

  local apps = wibox.widget {
    id = "appsgui",
    layout = wibox.layout.stack,
    top_only = true,
  }

  local apps_container = wibox.widget {
    layout = wibox.container.background,
    bg = beautiful.background,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(30))
    end,
    {
      layout = wibox.container.margin,
      margins = dpi(10),
      {
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(5),
        {
          layout = wibox.container.place,
          apps,
        },
        {
          layout = wibox.container.place,
          tabs
        }
      }
    }
  }

  local grid_index = 0
  local current_grid
  local all_apps = {}

  awful.spawn.easy_async_with_shell(
    "ls /usr/share/applications && ls ~/.local/share/applications",
    --"ls ~/.local/share/applications",
    function(stdout)
      local desktopnames = {}
      if searchterm then
        for desktop_app in string.gmatch(stdout, "([^\n]+)") do
          local desktoptypes = {}
          for desktoptype in string.gmatch(desktop_app, "([^.]+)") do
            table.insert(desktoptypes, desktoptype)
          end
          if desktoptypes[#desktoptypes] == "desktop" then
            if string.find(string.lower(desktop_app), string.lower(searchterm)) then
              table.insert(desktopnames, desktop_app)
            end
          end
        end
      else
        for desktop_app in string.gmatch(stdout, "([^\n]+)") do
          local desktoptypes = {}
          for desktoptype in string.gmatch(desktop_app, "([^.]+)") do
            table.insert(desktoptypes, desktoptype)
          end
          if desktoptypes[#desktoptypes] == "desktop" then
            table.insert(desktopnames, desktop_app)
          end
        end
      end

      -- At this point we've figured out all the names of the desktopfiles. The next part is to find the details and build the containers
      if verify then
        for desktopindex, desktopname in ipairs(desktopnames) do
          local verifiedapp = "nil"
          for _, app in ipairs(verify) do
            if desktopname == app.desktopname then
              verifiedapp = app
              break
            end
          end
          if verifiedapp == "nil" then
            grab_app_details(desktopname, all_apps)
          else
            table.insert(all_apps, verifiedapp)
          end
        end
      else
        for desktopindex, desktopname in ipairs(desktopnames) do
          grab_app_details(desktopname, all_apps)
        end
      end

      -- Build the container with the gathered apps
      for foundappindex, foundapp in ipairs(all_apps) do
        if math.fmod(foundappindex-1, 30) == 0 then
          grid_index = grid_index + 1
          apps:add(
            wibox.widget {
              id = "appgrid" .. tostring(grid_index),
              layout = wibox.layout.grid,
              horizontal_spacing = dpi(10),
              vertical_spacing = dpi(10),
              forced_num_cols = 10,
            }
          )
          current_grid = apps.children[grid_index]
          tabs:get_children_by_id("tabs")[1]:add(index_builder(grid_index, tabs, apps))
        end
        current_grid:add(foundapp)
      end
    end
  )
  return {apps_container = apps_container, apps = all_apps}
end

local apps = generate_apps()

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

local function search_button_creator()
  local search_font = beautiful.sysboldfont .. dpi(20)
  local search_button = wibox.widget {
    widget = wibox.widget.textbox,
    font = search_font,
    bg = beautiful.transparent,
    fg = beautiful.applauncher_search_colour_off,
    markup = "Search~"
  }
  local search_button_container = wibox.widget {
    layout = wibox.container.background,
    fg = beautiful.applauncher_search_colour_off,
    forced_height = dpi(60),
    forced_width = dpi(400),
    bg = beautiful.background,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(20))
    end,
    {
      widget = clickable_container,
      {
        layout = wibox.container.place,
        search_button,
      }
    }
  }

  local prompt_running = false
  local prompt_input -- This variable stores the found input
  local prompt_cooldown = gears.timer {
    timeout=.35, -- User preference, this should be managable
    single_shot=true,
    callback = function()
      if not (prompt_input == "") then
        search_button.markup = prompt_input
        local searchresults = generate_apps(apps.apps, prompt_input).apps_container
        awesome.emit_signal("module::applauncher:update", searchresults)
      else
        search_button.markup = "Search~"
        --search_button_container.fg = beautiful.applauncher_search_colour_off
        awesome.emit_signal("module::applauncher:update")
      end
    end,
  }
  local prompt = awful.keygrabber {
    stop_key = {"Return"},
    stop_callback = function()
      prompt_cooldown:again()
      prompt_running = false
      search_button_container.fg = beautiful.applauncher_search_colour_off
      --awesome.emit_signal("module::applauncher:hide")
    end,
    start_callback = function() prompt_running = true end,
    keypressed_callback = function(self, mod, key, event)
      if key == "BackSpace" then
        prompt_input = prompt_input:sub(1, -2)
      elseif key == "Escape" then
        awesome.emit_signal("module::applauncher:hide")
      elseif not (key == "Super_L" or key == "Super_R" or key == "Control_L" or key == "Control_R" or key == "Shift_L" or key == "Shift_R" or key == "Alt_L" or key == "Alt_R") then
        prompt_input = prompt_input .. key
      end
      search_button.markup = prompt_input
      prompt_cooldown:again()
    end
  }

  search_button_container:connect_signal("module::applauncher:start_prompt", function()
    if (not prompt_running) then
      --search_button.markup = ""
      prompt_input = ""
      search_button_container.fg = beautiful.applauncher_search_colour
      prompt:start()
    end
  end)

  search_button_container:connect_signal("module::applauncher:stop_prompt", function()
    prompt_cooldown:stop()
    prompt:stop()
    search_button.markup = "Search~"
    prompt_input = ""
  end)

  search_button_container:connect_signal("button::release", function(self, lx, ly, button, mods)
    if button == 1 then
      search_button_container:emit_signal("module::applauncher:start_prompt")

    elseif button == 3 then
      search_button_container:emit_signal("module::applauncher:stop_prompt")
      search_button_container.fg = beautiful.applauncher_search_colour_off
      awesome.emit_signal("module::applauncher:update")
    end
  end)

  return search_button_container
end

local function accept_button_creator()
  local accept_button = wibox.widget {
    layout = wibox.container.background,
    forced_height = dpi(60),
    forced_width = dpi(60),
    bg = beautiful.background,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(20))
    end,
    {
      widget = clickable_container,
      {
        layout = wibox.container.place,
        halign = "center",
        {
          margins = dpi(5),
          --forced_height = dpi(90),
          widget = wibox.container.margin,
          {
            widget = wibox.widget.imagebox,
            resize = true,
            image = icons.checkbox,
          }
        }
      }
    }
  }

  accept_button:connect_signal("button::press", function(self, lx, ly, button)
    if button == 1 then
      for _,app in ipairs(selected_apps) do
        awful.spawn(app.exec, {screen = selected_screen})
      end
      awesome.emit_signal("module::applauncher:hide")
    end
  end)

  return accept_button
end

local screenwidget = screen_widget_creator()
local search_button = search_button_creator()
local accept_button = accept_button_creator()


local function applauncher_creator(s)
  local applauncher = wibox {
    ontop = true,
    width = s.geometry.width,
    height = s.geometry.height,
    x = s.geometry.x,
    y = s.geometry.y,
    visible = false,
    screen = s,
    type = 'splash',
    bg = beautiful.background,
  }

  return applauncher
end

--mouse.screen.applauncher = applauncher_creator(mouse.screen)

awesome.connect_signal("module::applauncher:update", function(search_apps)
  for s in screen do
    s.applauncher : setup {
      layout = wibox.container.background,
      {
        layout = wibox.container.place
        {
          layout = wibox.layout.fixed.vertical,
          forced_width = dpi(1510),
          spacing = dpi(55),
          screenwidget,
          {
            layout = wibox.container.place,
            {
              layout = wibox.layout.fixed.horizontal,
              spacing = dpi(10),
              search_button,
              accept_button,
            },
          },
          search_apps or apps.apps_container
        }
      }
                          }
  end
end)

screen.connect_signal("request::desktop_decoration", function(s)
    s.applauncher = applauncher_creator(s)
end)

awesome.connect_signal("module::applauncher:show", function(s)
    for other_s in screen do
      other_s.applauncher.visible = false
    end
    s.applauncher.visible = true
    apps = generate_apps(apps.apps)
    screenwidget = screen_widget_creator()
    awesome.emit_signal("module::applauncher:update")
    search_button:emit_signal("module::applauncher:start_prompt")
end)

awesome.connect_signal("module::applauncher:hide", function()
    for selected_index,app in ipairs(selected_apps) do
      app.template.bg = beautiful.applauncher_bg_normal
    end
    selected_screen = screen[1]
    selected_apps = {}
    search_button:emit_signal("module::applauncher:stop_prompt")
    for s in screen do
      s.applauncher.visible = false
    end
end)
