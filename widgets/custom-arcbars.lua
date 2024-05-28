-- A little script that returns a dictionary containing a variety of custom arcbars
local function create_custom_arcbar(arcbar_type, barsize_x, barsize_y, colour, colour_off)
	if arcbar_type == "cpu" then
		return arcbar(
			gears.color.recolor_image(icons.cpu, colour),
			'Cpu',
			[[sh -c "echo $(top -b -n 1 | grep Cpu | awk '{print 100-$8-$16}')"]],
			[[sh -c "echo $(grep 'cpu MHz' /proc/cpuinfo | awk '{ghzsum+=$NF+0} END {printf "%.1f Ghz", ghzsum/NR/1000}')"]],
			barsize_x,
			barsize_y,
			colour,
			colour_off
		)

	elseif arcbar_type == "temperature" then
		return arcbar(
			gears.color.recolor_image(icons.temperature, colour),
			'Temps',
			--[[sh -c "echo $(sensors | grep -m 1 Package\ id\ 0 | awk '{printf "%.0f", $4}')"]]
			--[[sh -c "echo $(sensors | grep -m 1 Package\ id\ 0 | awk '{printf "%.0fC", $4}')"]]
			[[sh -c "echo $(paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$//' | grep "x86_pkg_temp" | awk '{print $2}')"]],
			[[sh -c "echo $(paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/' | grep "x86_pkg_temp" | awk '{print $2}')"]],
			barsize_x,
			barsize_y,
			colour,
			colour_off
		)

	elseif arcbar_type == "battery" then
		return arcbar(
			gears.color.recolor_image(icons.battery, colour),
			'Battery',
			[[sh -c "echo $(upower -d | grep -m 1 percentage: | awk '{print substr($2, 1, length($2)-1)}')"]],
			[[sh -c "echo $(upower -d | grep -m 1 time\ to | awk '{print $4" "$5}')"]],
			barsize_x,
			barsize_y,
			colour,
			colour_off
		)

	elseif arcbar_type == "gpu" then
		return arcbar(
			gears.color.recolor_image(icons.memory, colour),
			'GPU',
			[[sh -c "echo $(nvidia-smi | grep % | awk '{print $13-1}')"]],
			[[sh -c "echo $(nvidia-smi | grep % | awk '{printf "%.1fW / %.1fW", $5, $7}')"]],
			barsize_x,
			barsize_y,
			colour,
			colour_off
		)

	elseif arcbar_type == "memory" then
		return arcbar(
			gears.color.recolor_image(icons.memory, colour),
			'Memory',
			[[sh -c "echo $(free | grep Mem | awk '{print $3 / $2 * 100}')"]],
			[[sh -c "echo $(free | grep Mem | awk '{printf "%.1f GB / %.1f GB", ($2-$7)/1000000-0.4, $2/1000000-0.4}')"]],
			barsize_x,
			barsize_y,
			colour,
			colour_off
		)

	elseif arcbar_type == "disk" then
		return arcbar(
			gears.color.recolor_image(icons.disk, colour),
			'Disk',
			[[sh -c "echo $(df -h / | grep / | awk '{printf "%.1f", $3/$2*100}')"]],
			[[sh -c "echo $(df -h / | grep / | awk '{printf "%.1fG free", $4}')"]],
			barsize_x,
			barsize_y,
			colour,
			colour_off
		)

	else
		return nil
	end
end

return create_custom_arcbar
