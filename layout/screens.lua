-- Handling for screen adding/removing
-- when screen is removed
screen.connect_signal("removed", function(s)
	for c in s.all_clients do
		c:move_to_screen()
	end
end)

-- When a screen is added
screen.connect_signal("added", function(new_screen)
	local output = next(new_screen.outputs)
	naughty.notify({text=output .. " Connected!"})
	screen_tags = tag_store[output]
	if not (screen_tags == nil) then
		for _, tag in ipairs(new_screen.tags) do
			clients = screen_tags[tag.name]
			if not (clients == nil) then
				for _, client in ipairs(clients) do
					if not (client == nil) then
						client:move_to_tag(tag)
					end
				end
			end
		end
	end
end)

-- When screen is requested
tag.connect_signal("request::screen", function(t)
	local fallback_tag = nil
	for other_screen in screen do
		if other_screen ~= t.screen then
			fallback_tag = awful.tag.find_by_name(other_screen, t.name)
			if fallback_tag ~= nil then
				break
			end
		end
	end
	if fallback_tag == nil then
		fallback_tag = awful.tag.find_fallback()
	end
	if not (fallback_tag == nil) then
		local output = next(t.screen.outputs)
		if tag_store[output] == nil then
			tag_store[output] = {}
		end
		clients = t:clients()
		tag_store[output][t.name] = clients
		for _, c in ipairs(clients) do
			c:move_to_tag(fallback_tag)
		end
	end
end)

