-- Startup apps, this is where you'd put things like discord if you want it to start at boot
-- Fill in the apps you'd like to start in the list below :3c

--local startup_list = {
--	"picom",
--	"polkit",
--	"redshift-gtk",
--	"ckb-next",
--	"discord",
--	"qjackctl",
--	"wacom"
--}

--if startup_list then
--	for _,task in pairs(startup_list) do
--		awful.spawn.with_shell("systemctl --user start " .. task,false)
--	end
--end

-- New implementation
awful.spawn.with_shell(
    'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;' ..
    'xrdb -merge <<< "awesome.started:true";' ..
    -- list each of your autostart commands, followed by ; inside single quotes, followed by ..
    'dex --environment Awesome --autostart'
)
