--This widget is for checking whether or not an app already has an icon set by the user, in which case it should use that, or not in which case a default should be given
--This applies to multiple modules such as: alttab, taskbar & possibly top bar in the future! :3c
--Fun fact: Written on a train ride home at 23 pm :3c, as all good code should be
local home_path = string.gsub(gfs.get_xdg_config_home(),".config/","")
local get_icon_theme = function()
  return home_path .. ".icons/" .. io.popen("cat " .. home_path .. ".gtkrc-2.0 | grep 'icon-theme'"):read("*all"):gsub("gtk%-icon%-theme%-name=",""):gsub("\"",""):gsub("\n","") .. "/"
end
local icon_theme_path = get_icon_theme()

local create_imagebox = function(path)
  return {
    widget = wibox.widget.imagebox,
    resize = true,
    image = path,
  }
end

local search_app = function(name, existing)
  -- This searches, in order, if an icon can be found for the app!
  if gfs.file_readable(beautiful.app_path .. name .. '.svg') then
    return {exists = true, path = beautiful.app_path .. name .. '.svg'}
  end
  if gfs.file_readable(icon_theme_path .. "apps/scalable/" .. name .. ".svg") then
    return {exists = true, path = icon_theme_path .. "/apps/scalable/" .. name .. ".svg"}
  end
  if (not existing) then
    if gfs.file_readable(name) then
      return {exists = true, path = name}
    end
    for _, dir in ipairs(gfs.get_xdg_data_dirs()) do
      for _, prefix in ipairs({ "scalable/", "symbolic/", "1024x1024/", "512x512/", "384x384/", "256x256/", "192x192/", "128x128/", "96x96/", "72x72/", "64x64/", "48x48/", "36x36/", "32x32/", "" }) do
        for _, file_type in ipairs({ ".svg", ".svgz", ".png" }) do
          if gfs.file_readable(dir .. "icons/hicolor/" .. prefix .. "apps/" .. name .. file_type) then
            return {exists = true, path = dir .. "icons/hicolor/" .. prefix .. "/apps/" .. name .. file_type}
          end
        end
      end
    end
    for _, file_type in ipairs({ ".svg", ".png" }) do
      if gfs.file_readable("/usr/share/pixmaps/" .. name .. file_type) then
        return {exists = true, path = "/usr/share/pixmaps/" .. name .. file_type}
      end
    end
    for _, prefix in ipairs({ "256x256", "128x128", "64x64", "48x48", "32x32", "24x24", "16x16" }) do
      if gfs.file_readable(home_path .. ".local/share/icons/hicolor/" .. prefix .. "/apps/" .. name .. ".png") then
        return {exists = true, path = home_path .. ".local/share/icons/hicolor/" .. prefix .. "/apps/" .. name .. ".png"}
      end
    end
  end
  return {exists = false, path = 'nil'}
end

local get_app_image = function(name, existing, task)
  --The idea is to return either an image wibox including the custom/fallback icon
  --Or in case of an already existing app! Use awful.widget.clienticon!
  if (not name) then
    name = 'empty'
  end
  --name = string.lower(name)
  local appPath = search_app(name, existing)
  if appPath.exists then
    return create_imagebox(appPath.path)
  else
    if existing then
      return awful.widget.clienticon(task)
    else
      return create_imagebox(beautiful.app_path .. 'default.svg')
    end
  end
end

return get_app_image
