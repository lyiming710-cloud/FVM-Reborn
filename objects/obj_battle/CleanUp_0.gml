if (ds_exists(chomp_sound_list, ds_type_list)) {
	ds_list_destroy(chomp_sound_list);
}

// Never leak the battle-only 120 FPS render/input rate into menus or the next room.
game_set_speed(60, gamespeed_fps);

if (variable_global_exists("battle_skip_frame")) {
    global.battle_skip_frame = false;
    global.battle_simulation_tick = true;
    global.battle_keep_paused_after_skip = false;
}
