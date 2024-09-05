-- This widget is for displaying the currently playing song,
-- as well as provide some amount of control with play/pause, skip and previous.
-- This entire widget relies on 'playerctl' so without it this widget won't work!
local function music_player_button(icon)
  local icon_box = wibox.widget {
    widget = wibox.widget.imagebox,
    image = gears.color.recolor_image(icon, beautiful.music_player_fg),
    resize_allowed = true,
  }

  local button = wibox.widget {
    layout = wibox.container.background,
    bg = beautiful.music_player_button_bg,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(10))
    end,
    {
      layout = clickable_container,
      {
        layout = wibox.container.margin,
        margins = dpi(5),
        icon_box
      }
    }
  }

  button.change_icon = function(newicon)
    newicon = gears.color.recolor_image(newicon, beautiful.music_player_fg)
    icon_box.image = newicon
  end
  return button
end
local function create_music_player(sizeX, sizeY)
  local album_path = ""
  local title = "song title"
  local album_name = "album"
  local artist = "artist"
  local playing_status = false
  local song_length = 60
  local song_position = 0

  local grab_player_info = [[playerctl status && echo $(playerctl position) && playerctl metadata]]

  local play_pause_button = music_player_button(icons.play_button)
  play_pause_button:connect_signal("button::release", function(content, lx, ly, button)
    if button == 1 then
      if playing_status then
        play_pause_button.change_icon(icons.pause_button)
        awful.spawn.with_shell("playerctl pause")
      else
        play_pause_button.change_icon(icons.play_button)
        awful.spawn.with_shell("playerctl play")
      end
      playing_status = not playing_status
    end
  end)

  local previous_button = music_player_button(icons.previous_button)
  previous_button:connect_signal("button::release", function(content, lx, ly, button)
    if button == 1 then
      awful.spawn.with_shell("playerctl previous")
    end
  end)

  local next_button = music_player_button(icons.next_button)
  next_button:connect_signal("button::release", function(content, lx, ly, button)
    if button == 1 then
      awful.spawn.with_shell("playerctl next")
    end
  end)


  local album_art = wibox.widget {
    widget = wibox.widget.imagebox,
    image = icons.logout,
    resize = true,
    clip_shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(20))
    end
  }

  local title_widget = wibox.widget {
    widget = wibox.widget.textbox,
    font = beautiful.music_player_title_font,
    text = title,
    valign = "center",
    halign = "left",
  }

  local album_name_widget = wibox.widget {
    widget = wibox.widget.textbox,
    font = beautiful.music_player_album_font,
    text = album_name,
    valign = "center",
    halign = "left",
  }

  local artist_widget = wibox.widget {
    widget = wibox.widget.textbox,
    font = beautiful.music_player_artist_font,
    text = artist,
    valign = "center",
    halign = "left",
  }

  local status_bar = wibox.widget {
    widget = wibox.widget.slider,
    value = song_position,
    minimum = 0,
    maximum = song_length,
    handle_shape = function(cr, width, height)
      gears.shape.circle(cr, width, height, dpi(12))
    end,
    handle_color = beautiful.music_player_fg,
    bar_shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(20))
    end,
    bar_color = beautiful.music_player_fg_off,
    bar_active_color = beautiful.music_player_fg,
    bar_margins = dpi(8),
  }
  status_bar.animation = rubato.timed {
    intro = 0.0,
    duration = 5.0,
    easing = rubato.quadratic,
    subscribed = function(pos)
      status_bar.value = pos
    end
  }

  play_seperator = wibox.widget {
    layout = wibox.layout.ratio.vertical,
    {
      layout = wibox.layout.align.horizontal,
      expand = 'none',
      {
        layout = wibox.container.margin,
        top = dpi(5),
        bottom = dpi(5),
        left = dpi(7),
        right = dpi(5),
        {
          layout = wibox.layout.flex.vertical,
          title_widget,
          artist_widget,
          album_name_widget,
        },
      },
      nil,
      nil,
    },
    {
      layout = wibox.layout.align.horizontal,
      expand = 'none',
      nil,
      {
        layout = wibox.container.margin,
        margins = dpi(1),
        {
          layout = wibox.layout.flex.horizontal,
          spacing = dpi(5),
          previous_button,
          play_pause_button,
          next_button,
        },
      },
      nil
    }
  }
  play_seperator:adjust_ratio(2, 0.7, 0.3, 0.0)

  button_seperator = wibox.widget {
    layout = wibox.layout.ratio.horizontal,
    {
      layout = wibox.layout.align.vertical,
      expand = 'none',
      nil,
      album_art,
      nil,
    },
    play_seperator,
  }
  button_seperator:adjust_ratio(2, 0.3, 0.7, 0.0)

  status_seperator = wibox.widget {
    layout = wibox.layout.ratio.vertical,
    button_seperator,
    {
      layout = wibox.container.margin,
      top = dpi(5),
      bottom = dpi(5),
      left = dpi(10),
      right = dpi(10),
      status_bar,
    }
  }
  status_seperator:adjust_ratio(2, 0.8, 0.2, 0.0)

  local music_player = wibox.widget {
    layout = wibox.container.background,
    bg = beautiful.music_player_bg,
    fg = beautiful.music_player_fg,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, dpi(20))
    end,
    forced_height = sizeY,
    forced_width = sizeX,
    {
      layout = wibox.container.margin,
      margins = dpi(10),
      status_seperator
    }
  }

  local function parse_update_info(stdout)
    local album_url
    local title
    local album_name
    local artist
    local playing_status
    local song_length
    local song_position
    update_info = {}
    i = 0
    for info in string.gmatch(stdout, "([^\n]+)") do
      i = i + 1
      if i == 1 then
        if info == "Playing" then
          playing_status = true
        else
          playing_status = false
        end
      elseif i == 2 then
        song_position = tonumber(info)
      else
        full_infotype = {}
        for infotype in string.gmatch(info, "([^ ]+)") do
          table.insert(full_infotype, infotype)
        end

        infotype = full_infotype[2]
        full_infotype[1] = ""
        full_infotype[2] = ""

        if infotype == "mpris:length" then
          song_length = tonumber(full_infotype[3]) / 1000000
        elseif infotype == "mpris:artUrl" then
          album_url = table.concat(full_infotype, " "):sub(3)
        elseif infotype == "xesam:album" then
          album_name = table.concat(full_infotype, " "):sub(3)
        elseif infotype == "xesam:artist" then
          artist = table.concat(full_infotype, " "):sub(3)
        elseif infotype == "xesam:title" then
          title = table.concat(full_infotype, " "):sub(3)
        end
      end
    end

    return {
      album_url = album_url or icons.reboot,
      title = title or "No title",
      album_name = album_name or "No album",
      artist = artist or "No artist",
      playing_status = playing_status,
      song_length = song_length or 999999,
      song_position = song_position or 0
    }
  end

  local function update_song_art(art_path)
    album_art.image = art_path
  end

  local function download_song_art(art_url)
    awful.spawn.easy_async_with_shell(
      [[curl ]] .. art_url .. [[ > /tmp/awesome_music_player_album_art.png]],
      function(stdout)
        update_song_art(gears.surface.load_uncached("/tmp/awesome_music_player_album_art.png"))
      end
    )
  end

  local function update_all()
    awful.spawn.easy_async_with_shell(
      grab_player_info,
      function(stdout)
        local full_song_detail = parse_update_info(tostring(stdout))

        if full_song_detail.title ~= title then
          title = full_song_detail.title
          title_widget.text = full_song_detail.title
          album_name_widget.text = full_song_detail.album_name
          artist_widget.text = full_song_detail.artist
          status_bar.maximum = full_song_detail.song_length

          local album_url_elements = {}
          for element in string.gmatch(full_song_detail.album_url, "([^/]+)") do
            table.insert(album_url_elements, element)
          end

          if (album_url_elements[1] == "https:" or album_url_elements[1] == "http:") then
            album_url_elements[1] = album_url_elements[1] .. "/"
            download_song_art(table.concat(album_url_elements,"/"))
          else
            album_url_elements[1] = ""
            update_song_art(table.concat(album_url_elements,"/"))
          end
        end

        if full_song_detail.playing_status ~= playing_status then
          playing_status = full_song_detail.playing_status
          if full_song_detail.playing_status then
            play_pause_button.change_icon(icons.play_button)
          else
            play_pause_button.change_icon(icons.pause_button)
          end
        end
        if full_song_detail.song_position ~= song_position then
          song_position = full_song_detail.song_position
          status_bar.animation.target = full_song_detail.song_position
        end
      end
    )
  end

  music_timer = gears.timer {
    timeout = 5,
    call_now = false,
    autostart = false,
    callback = update_all
  }

  music_player:connect_signal("widget::music_player:start_clock", function()
    update_all()
    music_timer:start()
  end)

  music_player:connect_signal("widget::music_player:stop_clock", function()
    music_timer:stop()
  end)

  return music_player
end

return create_music_player
