var _synthetic_pause = variable_global_exists("battle_skip_frame") && global.battle_skip_frame;
var _battle_paused = global.is_paused && !_synthetic_pause;

if audio_is_paused(battle_music) and not _battle_paused{
	audio_resume_sound(battle_music)
}
if not audio_is_playing(battle_music) and not _battle_paused{
	audio_play_sound(battle_music,0,0)
}
if audio_is_playing(battle_music) and _battle_paused{
	audio_pause_sound(battle_music)
}

if global.laboretory_room{
	var current_music_volum = audio_group_get_gain(music)
	audio_sound_gain(battle_music,current_music_volum)
	audio_sound_gain(new_battle_music,current_music_volum)
}