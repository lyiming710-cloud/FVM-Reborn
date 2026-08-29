if array_length(mouse_preview_inst) == 0{
	for(var i = 0; i < array_length(enemy_type_list);i++){
		var enemy_data = global.enemy_map[? enemy_type_list[i]]
		var inst = instance_create_depth(300+(i mod 10)*170,300+floor(i / 10)*230,depth-1,obj_mouse_preview)
		inst.sprite_index = enemy_data.spr
		inst.tooltip_text = enemy_data.description + "\n基础生命值：" + string(enemy_data.hp)
		if enemy_data.shield > 0{
			inst.tooltip_text += "\n防具血量：" + string(enemy_data.shield)
		}
		array_push(mouse_preview_inst,inst)
	}
	for(var i = 0; i < array_length(boss_type_list);i++){
		var enemy_data = global.enemy_map[? boss_type_list[i]]
		var inst = instance_create_depth(300+(i mod 5)*340,900+floor(i / 5)*280,depth-1,obj_mouse_preview)
		inst.sprite_index = enemy_data.spr
		inst.tooltip_text = enemy_data.description + "\n基础生命值：" + string(enemy_data.hp)
		array_push(mouse_preview_inst,inst)
	}
}
if keyboard_check_pressed(vk_escape){
    keyboard_clear(vk_escape);

    // Never clear GameMaker's synthetic mouse state on iOS. Closing this
    // ready-room preview used to call mouse_clear(mb_any), which can strand
    // both touchscreen and Magic Keyboard trackpad input until the pointer
    // device is recreated.
    if (os_type == os_ios && instance_exists(obj_readyroom_manager)) {
        with (obj_readyroom_manager) {
            for (var _sync_d = 0; _sync_d < 8; _sync_d++) {
                ios_ready_prev_down[_sync_d] = device_mouse_check_button(_sync_d, mb_left);
            }
        }
    }

    instance_destroy();
}