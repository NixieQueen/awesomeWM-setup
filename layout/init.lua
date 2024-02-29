-- Initialize layout here
-- Screen logic
local screens = dofile(gears.filesystem.get_configuration_dir() .. "/layout/screens.lua")

-- {{{ Tag layout
-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.tile,
        awful.layout.suit.floating,
        awful.layout.suit.fair,
        --awful.layout.suit.tile.left,
        --awful.layout.suit.tile.bottom,
        --awful.layout.suit.tile.top, 
        --awful.layout.suit.fair.horizontal,
        --awful.layout.suit.spiral,
        --awful.layout.suit.spiral.dwindle,
        --awful.layout.suit.max,
        --awful.layout.suit.max.fullscreen,
        --awful.layout.suit.magnifier,
        --awful.layout.suit.corner.nw,
    })
end)
-- }}}

-- handle workspaces!
screen.connect_signal("request::desktop_decoration", function(s)
    awful.tag({"Main","Game","Music","Art"}, s, awful.layout.layouts[1])
end
)

-- On creation & on floating handling of titlebar
client.connect_signal("property::floating", function(c)
	local b = false;
	if c.first_tag ~= nil then
		b = c.first_tag.layout.name == 'floating'
	end
	if c.floating or b then
		awful.titlebar.show(c,'left')
	else
		awful.titlebar.hide(c,'left')
	end
end)

-- Client removed :(
client.connect_signal("unmanage", function(c)
    local last_client = awful.client.focus.history.get(nil, 0)
    if last_client then
      last_client:activate { raise = true, context = "last_killed" }
    end
end)

-- New client added!
client.connect_signal("manage", function(c)
--	c:set_shape(function(cr, width, height)
--		gears.shape.rounded_rect(cr, width, height, beautiful.rounded_size) end)

    c.size_hints_honor = false

	c.maximized = false

	if c.floating or c.first_tag.layout.name == "floating" then
		awful.titlebar.show(c,'left')
		c:relative_move(beautiful.titlebar_size,0,0,0)
	else
		awful.titlebar.hide(c,'left')
	end

    -- add a button to every client to make it raised on a left mouse press if it is not already raised
    --naughty.notification({text=tostring(c:buttons())})
    local raise_client = function(c)
      if (not c.active) then
        c:raise()
      end
    end

    local new_buttons = gears.table.join(
      {
        -- all the old normal buttons :3
        c:buttons(),
        -- focusing client on interaction attempt
        awful.button({ }, 1, raise_client(c)),
        awful.button({ }, 2, raise_client(c)),
        awful.button({ }, 3, raise_client(c)),

        -- special code for dragging tiled items with mouse >:3
        awful.button({'Mod4'}, 1, function(c)
            local was_floating = c.floating
            c.floating = true,
            c:activate{action='mouse_move'}
            -- janky mess to capture when mouse is let go as the mouse::release signal does not work on clients
            -- only call this if the window was not floating beforehand
            if (not was_floating) then
              gears.timer.start_new(.1, function()
                if (not mouse.is_left_mouse_button_pressed) then
                  c.floating = false

                  -- get client closest to mouse
                  local closest_client = false
                  local previousDistance = 1000
                  local mousecoords = mouse.coords()

                  for clientIndex,screenClient in ipairs(client.get(s)) do
                    if not (c == screenClient) then
                      -- calculate center point of client
                      centerX = screenClient.x + screenClient.width / 2
                      centerY = screenClient.y + screenClient.height / 2

                      -- good ol' pythagoras
                      a = mousecoords.x - centerX
                      b = mousecoords.y - centerY
                      distance = math.abs(math.sqrt(a^2 + b^2))

                      -- decide if distance is smaller than previously established closest distance
                      if distance < previousDistance then
                        closest_client = screenClient
                        previousDistance = distance
                      end
                    end
                  end

                  -- move window to hovered area
                  c:move_to_screen(closest_client.screen)
                  c:swap(closest_client)

                  return false
                end
                return true
              end)
            end
        end
        ),
        awful.button({'Mod4'}, 3, function(c)
            c:activate{action='mouse_resize'} end
        )
      }
    )
    c:buttons(new_buttons)
end)

tag.connect_signal("property::layout", function(t)
	local clients = t:clients()
	for k,c in pairs(clients) do
		c.maximized = false
		if c.floating or c.first_tag.layout.name == "floating" then
			awful.titlebar.show(c,'left')
			c:relative_move(30,10,-60,-20)
		else
			awful.titlebar.hide(c,'left')
		end
	end
end)

client.connect_signal("property::maximized", function(c)
    if not (awful.layout.getname() == "floating") then
      awful.titlebar.hide(c, 'left')
    end
	--if c.maximized then
	--	c:set_shape(gears.shape.rect)
	--else
	--	c:set_shape(function(cr, width, height)
	--		gears.shape.rounded_rect(cr, width, height, beautiful.rounded_size) end)
	--end
end)

client.connect_signal("property::fullscreen", function(c)
    if c.fullscreen then
      if c.floating then
        awful.titlebar.hide(c, 'left')
      end
      c.border_width = 0
      gears.timer.delayed_call(
        function()
          if c.valid then
            c:geometry(c.screen.geometry)
          end
        end
      )
      --c:set_shape(gears.shape.rect)
    else
      if c.floating then
        awful.titlebar.show(c,'left')
      end
      c.border_width = beautiful.border_width
      --c:set_shape(function(cr, width, height)
      --gears.shape.rounded_rect(cr, width, height, beautiful.rounded_size) end)
      end
end)

client.connect_signal("button::press", function(c)
    c:activate {context = "focusonpress", raise = true}
end)
