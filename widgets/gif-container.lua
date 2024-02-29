-- Import important library for gif conversion
local pixbuf = require("lgi").GdkPixbuf
local lgi = require("lgi")
local cairo = require("lgi").cairo

do
	local _ = lgi.require('Gdk', '3.0')
	-- for set_source_pixbuf >:3
end


local gif_container_creator = function(gif,height,width)
	local container = wibox.widget {
		image = beautiful.profile_pic,
		resize = true,
		forced_width = width,
		forced_height = height,
		visible = true,
		widget = wibox.widget.imagebox
	}

	local img, err = pixbuf.PixbufAnimation.new_from_file(gif)
	local img_width = img:get_width()
	local img_height = img:get_height()
	local img_scalex = width / img_width
	local img_scaley = height / img_height
	local iter = img:get_iter(nil)
	
	local advance_buffer = function()
		collectgarbage("collect")
		surface = cairo.ImageSurface(cairo.Format.ARGB32, width, height)
		cr = cairo.Context(surface)
		iter:advance(nil)
		cr:scale(img_scalex, img_scaley)
		cr:set_source_pixbuf(iter:get_pixbuf(), 0, 0)
		cr.operator = "SOURCE"
		cr:paint()
		container:set_image(surface)
	end
	
	local gifloop = gears.timer {
		timeout = iter:get_delay_time() / 1000,
		call_now = false,
		autostart = false,
		callback = advance_buffer
	}
	
	container:connect_signal("widget::gif:start_loop", function()
		gifloop:start() end
	)
	
	container:connect_signal("widget::gif:stop_loop", function()
		gifloop:stop() end
	)
	
	return container
end

return gif_container_creator
