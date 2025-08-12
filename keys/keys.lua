-- All the shortcuts go in here :3!!!
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")
--local menubar = require("menubar")
-- Key bindings
-- Mod4 is the super key
local modkey = "Mod4"
local altkey = "Mod1"

local getC = function()
  --c = client.focus
  c = mouse.current_client
  if (not c) then
    c = client.focus
    if (not c) then
      return
    else
      return c
    end
  else
    return c
  end
end

-- Bring all keys into a list for exporting
local key_list = awful.util.table.join(
	-- General keybindings
	awful.key({modkey}, "h", hotkeys_popup.show_help,
		{description="show help", group="general"}),
	awful.key({modkey,'Shift','Control'}, 't', function() awesome.emit_signal("module::theme_switcher:show", true) end,
		{description='show theme switcher', group='general'}),
	awful.key({modkey,'Shift','Control'}, 'm', function() mymainmenu:show() end,
		{description='show main menu', group='general'}),
	awful.key({modkey,'Shift','Control'}, 'r', awesome.restart,
		{description='restart awesomeWM', group='general'}),
	awful.key({modkey,'Shift','Control'}, 'q', function() awesome.emit_signal("module::exit_screen:show") end,
		{description='quits awesomeWM', group='general'}),
	awful.key({modkey,'Shift','Control'}, 'l', function()
		awful.prompt.run {
			prompt = 'Run Lua Code: ',
			textbox = awful.screen.focused().toppanel_promptbox.widget,
			exe_callback = awful.util.eval,
			history_path = awful.util.get_cache_dir() .. "/history_eval"
		} end,
		{description='Run lua code', group='general'}),
	
	-- Client based keybinds
	awful.key({modkey}, 'q', function(c) 
		local c = getC()
    c:activate()
		c:kill() end,
		{description='kill task', group='client'}),
	awful.key({modkey}, 'f', function(c)
		local c = getC()
		c.fullscreen = not c.fullscreen
		c:raise() end,
		{description='toggle fullscreen', group='client'}),
	awful.key({modkey}, 'm', function(c)
		local c = getC()
		c.maximized = not c.maximized
		c:raise() end,
		{description='(un)maximize', group='client'}),
	awful.key({modkey}, 'n', function(c)
		local c = getC()
		c.minimized = true
        awesome.emit_signal("module::taskbar:update") end,
		{description='minimize', group='client'}),
	awful.key({modkey}, 'b', function ()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			c:activate {raise = true, context = "key.unminimize"} end
        awesome.emit_signal("module::taskbar:update")
		end,
		{description='restore minimized', group='client'}),
	awful.key({modkey}, 's', function(c)
		local c = getC()
    local is_focused = c.active
    c:move_to_screen()
    if ((c.floating or awful.layout.getname(awful.layout.get(c.screen)) == "floating") and (not c.fullscreen)) then
      awful.titlebar.show(c,'left')
      c:relative_move(beautiful.titlebar_size,0,0,0)
    else
      awful.titlebar.hide(c,'left')
    end
    if is_focused then
      gears.timer.start_new(1, function() c:activate {raise = true, context = "key.swapscreen"} end)
    end
  end,
		{description='move app to screen', group='client'}),
	awful.key({modkey}, 't', function(c)
		local c = client.focus
		c.ontop = not c.ontop end,
		{description='move on top', group='client'}),
	awful.key({modkey}, 'u', awful.client.urgent.jumpto,
		{description='jump to urgent client', group='client'}),
	awful.key({altkey}, 'Tab', function()
		--awful.client.focus.history.previous()
		awesome.emit_signal("module::alttab:show")
		if client.focus then
			client.focus:raise() end
		end,
		{description='alt-tab back', group='client'}),
	awful.key({modkey}, ".", function()
		awful.screen.focus_relative(1) end,
		{description='go forward to next tab in index', group='client'}),
	awful.key({modkey}, ",", function () 
		awful.screen.focus_relative(-1) end,
		{description='go back to previous tab in index', group='client'}),
  awful.key({modkey}, 'v', function(c)
      local c = getC()
      local wasfloating = c.wasfloating or false
      if c.sticky then
        if (not wasfloating) then
          c.floating = false
        end
      else
        c.wasfloating = c.floating
        c.floating = true
      end
      c.sticky = not c.sticky
      c.ontop = not c.ontop
    end,
    {description='toggle a window pinned status', group='client'}),


	-- launcher keybinds
	awful.key({modkey}, "Return", function() 
		awful.spawn(terminal, {screen = mouse.screen}) end,
		{description='spawn a terminal', group='launcher'}),
	awful.key({modkey,'Shift'}, "r", function()
		awful.spawn.with_shell("rofi -show drun -theme ~/.config/awesome/rofi/menu/rofi.rasi",false) end,
    {description='open run menu', group='launcher'}),
  awful.key({modkey}, "r", function()
    awesome.emit_signal("module::applauncher:show", mouse.screen) end,
		{description='open run menu', group='launcher'}),
	awful.key({altkey,modkey}, "b", function()
		awful.spawn(browser, {screen = mouse.screen}) end,
		{description='open browser', group='launcher'}),
	awful.key({altkey,modkey}, "p", function()
		awful.spawn(fileMan, {screen = mouse.screen}) end,
		{description='open file manager', group='launcher'}),
		
	-- layout keybinds
	awful.key({altkey,modkey}, "m", function() musicpanel:show() end,
		{description='shows music panel', group='layout'}),
	awful.key({altkey,modkey}, "l", function() awesome.emit_signal("module::left_panel:show") end,
		{description='shows left panel', group='layout'}),
	awful.key({altkey,modkey}, "f", function() fanpanel:show() end,
		{description='shows fan control panel', group='layout'}),
	awful.key({modkey,altkey}, "a", function() appsdrawer:show() end,
		{description='open apps drawer', group='layout'}),
	awful.key({altkey,modkey}, "q", function() quitmenu:show() end,
		{description='show the exit menu', group='layout'}),
	awful.key({modkey,'Control'}, ".", function() awful.layout.inc(1) end,
		{description='jump to next workspace', group='layout'}),
	awful.key({modkey,'Control'}, ",", function() awful.layout.inc(-1) end,
		{description='jump to previous workspace', group='layout'}),
	awful.key({modkey,'Shift','Control'}, ".", function () awful.client.swap.byidx(1) end,
		{description='swap with next screen index', group='layout'}),
	awful.key({modkey,'Shift','Control'}, ",", function () awful.client.swap.byidx(-1) end,
		{description='swap with previous screen index', group='layout'}),
    awful.key({modkey,altkey}, "1", function() awful.tag.incmwfact(-0.01) end,
        {description='decrease the width factor in tiling mode', group='layout'}),
    awful.key({modkey,altkey}, "2", function() awful.tag.incmwfact(0.01) end,
        {description='increase the width factor in tiling mode', group='layout'}),
    awful.key({modkey,altkey}, "3", function() awful.client.incwfact(-0.01) end,
        {description='decrease the height factor in tiling mode', group='layout'}),
    awful.key({modkey,altkey}, "4", function() awful.client.incwfact(0.01) end,
        {description='increase the height factor in tiling mode', group='layout'}),
    awful.key({modkey}, "1", function() awful.screen.focused().tags[1]:view_only() end,
        {description='view the Main tag', group='layout'}),
    awful.key({modkey}, "2", function() awful.screen.focused().tags[2]:view_only() end,
        {description='view the Game tag', group='layout'}),
    awful.key({modkey}, "3", function() awful.screen.focused().tags[3]:view_only() end,
        {description='view the Music tag', group='layout'}),
    awful.key({modkey}, "4", function() awful.screen.focused().tags[4]:view_only() end,
        {description='view the Art tag', group='layout'}),
    awful.key({modkey}, "5", function() awful.screen.focused().tags[5]:view_only() end,
        {description='view the Coding tag', group='layout'}),



	-- extra keys
	awful.key({}, "XF86MonBrightnessDown", function()
		awful.spawn('light -U 1', false)
		awesome.emit_signal("module::brightness_osd:value")
		awesome.emit_signal("module::brightness_osd:show",true) end,
		{description='Turn down the brightness', group='extra'}),
	awful.key({modkey}, "XF86MonBrightnessDown", function()
		awful.spawn('light -S 0', false) end,
		{description='Turn off monitor', group='extra'}),
	awful.key({modkey}, "XF86MonBrightnessUp", function()
		awful.spawn('light -S 30', false) end,
		{description='Turn on monitor', group='extra'}),
	awful.key({}, "XF86MonBrightnessUp", function()
		awful.spawn("light -A 1", false)
		awesome.emit_signal("module::brightness_osd:value")
		awesome.emit_signal("module::brightness_osd:show",true) end,
		{description='Turn up the brightness', group='extra'}),
	awful.key({}, "XF86AudioLowerVolume", function()
		awful.spawn('amixer sset Master 1%-', false)
		awesome.emit_signal("module::volume_osd:value")
		awesome.emit_signal("module::volume_osd:show",true) end,
		{description='Turn down the volume', group='extra'}),
	awful.key({}, "XF86AudioRaiseVolume", function()
		awful.spawn('amixer sset Master 1%+', false)
		awesome.emit_signal("module::volume_osd:value")
		awesome.emit_signal("module::volume_osd:show",true) end,
		{description='Turn up the volume', group='extra'}),
	awful.key({}, "XF86AudioMute", function()
		awful.spawn('amixer sset Master 1+ toggle', false)
		awesome.emit_signal("module::volume_osd:value")
		awesome.emit_signal("module::volume_osd:show",true) end,
		{description='Mute the volume', group='extra'}),

  awful.key({}, "Print", function()
--  awful.spawn.easy_async_with_shell('maim -o -s | tee ~/Pictures/Screenshots/"Screenshot from $(date +"%Y-%m-%d %H-%M-%S")".png | xclip -selection clipboard -t image/png') end,
    awesome.emit_signal("module::screenshottool:take_screenshot", {selected_screen = mouse.screen, interactive = true}) end,
    {description='Take a screenshot of an area', group='extra'}),
  awful.key({'Shift'}, "Print", function()
    awesome.emit_signal("module::screenshottool:take_screenshot", {selected_screen = mouse.screen, interactive = true, timer = 5}) end,
    {description='Take a screenshot of an area', group='extra'}),
  awful.key({'Ctrl'}, "Print", function()
    awesome.emit_signal("module::screenshottool:take_screenshot", {selected_screen = mouse.screen, interactive = false}) end,
    {description='Take a screenshot of an area', group='extra'}),
  awful.key({'Shift', 'Ctrl'}, "Print", function()
    awesome.emit_signal("module::screenshottool:take_screenshot", {selected_screen = mouse.screen, interactive = false, timer = 5}) end,
    {description='Take a screenshot of an area', group='extra'}),



	awful.key({}, "XF86AudioPlay", function()
		awful.spawn('playerctl -p "spotify,%any" play-pause',false) end,
		{description='Play/Pause current media', group='extra'}),
	awful.key({}, "XF86AudioNext", function()
		awful.spawn('playerctl -p "spotify,%any" next',false) end,
		{description='Skip to the next media', group='extra'}),
	awful.key({}, "XF86AudioPrev", function()
		awful.spawn('playerctl -p "spotify,%any" previous',false) end,
		{description='Skip to previous media', group='extra'})
)

return key_list
-- End :3c
