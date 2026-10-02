-- Monitor geometry is hardware-specific. Keep scale unchanged until owner review.
-- GDK_SCALE=2 is separately set in hyprland.lua for GTK applications.
return function(hl)
	hl.monitor({
		output = "eDP-1",
		mode = "1920x1080@60",
		position = "0x0",
		scale = 1,
		bitdepth = 10,
	})
end
