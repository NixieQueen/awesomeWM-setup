-- This module gets called whenever the tag is switched. It takes a screenshot of the
-- current tag and the next and then plays a neat little animation to switch over.
-- it can of course be disabled in the config if desired as this is resource intensive and pointless ^w^

local function create_tag_screen(s, tag_index)
  local tag_index = tag_index or 0
  local screenshot = awful.screenshot {screen = s}
  screenshot:refresh()

  local tag_screen_widget = wibox.widget {
    widget = wibox.container.background,
    bg = beautiful.background,
    forced_height = s.geometry.height,
    forced_width = s.geometry.width,
    screenshot.content_widget
  }
  tag_screen_widget.point = {x=0, y=0}

  tag_screen_widget.change_tag = function()
    screenshot:refresh()
  end
  return tag_screen_widget
end

local function create_tag_switcher(s)
  local tag_switcher = wibox {
    ontop = true,
    width = s.geometry.width,
    height = s.geometry.height,
    x = s.geometry.x,
    y = s.geometry.y,
    visible = false,
    screen = s,
    type = 'desktop',
    bg = beautiful.background,
  }

  local tag_screen_1 = create_tag_screen(s)
  local tag_screen_2 = create_tag_screen(s, 1)

  tag_switcher.build = function()
    tag_switcher : setup {
          layout = wibox.layout.manual,
          tag_screen_1,
          tag_screen_2,
    }
  end

  tag_switcher.build()

  tag_switcher.animation = rubato.timed {
    intro = 0.5,
    duration = 1,
    easing = rubato.quadratic,
    subscribed = function(pos)
      tag_switcher.widget:move(1, {x=s.geometry.width * pos, y=0})
      tag_switcher.widget:move(2, {x=0-s.geometry.width + s.geometry.width * pos, y=0})
    end
  }

  tag_switcher.update = function()
    tag_screen_1.change_tag()
    gears.timer.start_new(0.5, function()
        tag_screen_2.change_tag()
        tag_switcher.build()
        tag_switcher.show()
    end)
  end

  tag_switcher.show = function()
    tag_switcher.visible = true
    tag_switcher.animation.target = 1
    gears.timer.start_new(1, tag_switcher.hide)
  end

  tag_switcher.hide = function()
    tag_switcher.visible = false
    tag_switcher.animation.target = 0
  end

  return tag_switcher
end

screen.connect_signal("request::desktop_decoration", function(s)
    s.tag_switcher = create_tag_switcher(s)
end)

awesome.connect_signal("module::tag_switcher:hide", function()
    for s in screen do
      s.tag_switcher.hide()
    end
end)

awesome.connect_signal("module::tag_switcher:show", function()
    awesome.emit_signal("module::tag_switcher:hide")
    focused = mouse.screen
    focused.tag_switcher.update()
end)

tag.connect_signal("property::selected", function() awesome.emit_signal("module::tag_switcher:show") end)
