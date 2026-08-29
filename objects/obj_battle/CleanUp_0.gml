if (ds_exists(chomp_sound_list, ds_type_list)) {
	ds_list_destroy(chomp_sound_list);
}

// Never leak battle acceleration/slow-motion into menus or the next room.
game_set_speed(60, gamespeed_fps);
