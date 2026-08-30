// iPad battle HUD consumes the same per-frame pointer edge as cards/shovel.
if (os_type == os_ios) {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _hud_pressed = global.pointer_input.pressed && !global.pointer_input.consumed;
    var _px = global.pointer_input.gui_x;
    var _py = global.pointer_input.gui_y;

    if (_hud_pressed) {
        var _top_x1 = 24;
        var _top_y1 = 24;
        var _top_x2 = 184;
        var _top_y2 = 94;

        var _bottom_y1 = _gh - 98;
        var _bottom_y2 = _gh - 28;
        var _speed_x1 = 24;
        var _speed_x2 = 184;
        var _esc_x1 = 198;
        var _esc_x2 = 358;
        var _slow_x1 = 372;
        var _slow_x2 = 532;

        if (_px >= _top_x1 && _px <= _top_x2 && _py >= _top_y1 && _py <= _top_y2) {
            virtual_pause_pressed = true;
            global.pointer_input.consumed = true;
        }
        else if (_py >= _bottom_y1 && _py <= _bottom_y2) {
            if (_px >= _speed_x1 && _px <= _speed_x2) {
                with (obj_battle) virtual_speed_pressed = true;
                global.pointer_input.consumed = true;
            }
            else if (_px >= _esc_x1 && _px <= _esc_x2) {
                virtual_esc_pressed = true;
                global.pointer_input.consumed = true;
            }
            else if (_px >= _slow_x1 && _px <= _slow_x2) {
                with (obj_battle) virtual_slow_pressed = true;
                global.pointer_input.consumed = true;
            }
        }
    }
}

// obj_battle_pause_manager - Step Event
if (keyboard_check_pressed(vk_space) || virtual_pause_pressed) {
    virtual_pause_pressed = false;	
    //if global.selected_slot == noone {
        if (!global.is_paused) {
            battle_cancel_selected_tool();
            // 空格暂停：只暂停不显示菜单
            global.is_paused = true;
            global.show_menu = false;
        }
        else if (global.is_paused && !global.show_menu) {
            // 取消暂停
			if global.game_over{
				if settlement || obj_game_over.sprite_index == spr_lose || global.level_file.version == "1.0.0"{
					if global.map_id == "tower_cake" || global.map_id == "delicious_town"{
						global.map_id = "delicious_island"
						global.map_name = "美味岛"
					}
					global.gui_stack.pop()
					if (obj_game_over.sprite_index != spr_lose) {
						global.gui_stack.pop()
					}
					global.menu_screen = true
					obj_world_map_button.world_map = 0
				}
				if global.level_file.version != "1.0.0"{
					if obj_game_over.sprite_index == spr_win && !settlement{
						if !global.laboretory_room{
							with obj_task_manager{
								refresh_task_progress()
							}
							if array_get_index(global.save_data.completed_levels,global.level_data.id) == -1{
								complete_level(global.level_data.id)
								first_complete = true
								if array_get_index(slot_unlock_level_id_list,global.level_data.id) != -1{
									if global.save_data.unlocked_items.max_slot < 21{
										global.save_data.unlocked_items.max_slot += 1
										show_notice("你解锁了一个新的卡槽",60)
									}
								}
								if global.level_data.id == "champagne_island_water"{
									global.save_data.unlocked_items.elite_unlocked = true
								}
								if global.level_data.id == "abyss"{
									global.save_data.unlocked_items.shovel = "copper"
								}
								if global.level_data.id == "macchiato_port"{
									global.save_data.unlocked_items.shovel = "silver"
								}
								if global.level_data.id == "snowcap_volcano"{
									global.save_data.unlocked_items.shovel = "gold"
								}
								if global.level_data.id == "tower_cake_35_3"{
									global.save_data.player.crown_version = global.game_version
								}
								if global.level_file.rewards[1].player_level >= global.save_data.player.level{
									global.save_data.player.level = global.level_file.rewards[1].player_level
								}
								if global.level_file.rewards[1].skill_level >= global.save_data.unlocked_items.max_skill_level{
									global.save_data.unlocked_items.max_skill_level = global.level_file.rewards[1].skill_level
									var length = array_length(global.save_data.unlocked_cards)
									for (var i = 0;i < length;i++){		
										global.save_data.unlocked_cards[i].skill = global.save_data.unlocked_items.max_skill_level
									}
								
								}
								global.save_data.player.gold += global.level_file.rewards[1].gold
								var item_list = global.level_file.rewards[1].items
								for(var i = 0 ; i < array_length(item_list) ; i++){
									var item_id = item_list[i].id
									add_material_amount(item_id,real(item_list[i].amount))
								}
						
								var card_unlock_id_list = global.level_file.rewards[1].card_unlock
								for(var i = 0 ; i < array_length(card_unlock_id_list) ; i++){
									var card_id = card_unlock_id_list[i]
									unlock_card(card_id,0,0,global.save_data.unlocked_items.max_skill_level)
								}
						
								var weapon_unlock_id_list = global.level_file.rewards[1].weapon_unlock
								for(var i = 0 ; i < array_length(weapon_unlock_id_list) ; i++){
									var weapon_id = weapon_unlock_id_list[i]
									unlock_weapon(weapon_id)
								}
						
								var gem_unlock_id_list = global.level_file.rewards[1].gem_unlock
								for(var i = 0 ; i < array_length(gem_unlock_id_list) ; i++){
									var gem_id = gem_unlock_id_list[i]
									unlock_gem(gem_id)
								}
								save_file(global.save_slot)
							}
							else{
								global.save_data.player.gold += global.level_file.rewards[0].gold
								var item_list = global.level_file.rewards[0].items
								for(var i = 0 ; i < array_length(item_list) ; i++){
									var item_id = item_list[i].id
									add_material_amount(item_id,item_list[i].amount)
								}
								save_file(global.save_slot)
							}
						}
						settlement = true
						obj_game_over.image_alpha = 0
					}
				}
				
				
			}
			if obj_battle.battle_time != 0 && !global.game_over{
				global.is_paused = false;
			}
        }
    //}
}

// ESC is owned by this manager only. This prevents the pause menu and
// manager from both reacting to the same keypress in one frame.
var _esc_key_pressed = keyboard_check_pressed(vk_escape);
if (_esc_key_pressed || virtual_esc_pressed) {
    virtual_esc_pressed = false;
    var _esc_handled = false;

    // ESC always puts a held card/shovel back before opening the menu.
    battle_cancel_selected_tool();

    if (!global.is_paused) {
        global.is_paused = true;
        global.show_menu = true;
        if (!instance_exists(obj_pause_menu)) {
            instance_create_depth(room_width / 2, room_height / 2, depth, obj_pause_menu);
        }
        _esc_handled = true;
    }
    else if (global.is_paused && !global.show_menu) {
        // Space-pause -> ESC opens the full pause menu.
        global.show_menu = true;
        if (!instance_exists(obj_pause_menu)) {
            instance_create_depth(room_width / 2, room_height / 2, depth, obj_pause_menu);
        }
        _esc_handled = true;
    }
    else if (global.is_paused && global.show_menu) {
        // Close only the top-most modal first.
        if (instance_exists(obj_config_menu)) {
            instance_destroy(obj_config_menu);
            _esc_handled = true;
        }
        else if (instance_exists(obj_quit_confirm)) {
            instance_destroy(obj_quit_confirm);
            _esc_handled = true;
        }
        else if (instance_exists(obj_restart_confirm)) {
            instance_destroy(obj_restart_confirm);
            _esc_handled = true;
        }
        else {
            var _menu = instance_find(obj_pause_menu, 0);
            if (_menu != noone) {
                instance_destroy(_menu);
            }
            // Also recover from a stale show_menu flag with no menu instance.
            global.is_paused = false;
            global.show_menu = false;
            _esc_handled = true;
        }
    }

    if (_esc_handled) {
        // Consume the physical ESC so another object cannot process it again
        // later in this same step.
        if (_esc_key_pressed) {
            keyboard_clear(vk_escape);
        }
    }
}

if (keyboard_check_pressed(ord("R"))) {
	if global.game_over{
		if obj_game_over.sprite_index == spr_lose{
			room_restart()
		}
	}
}

if obj_battle.battle_time == 1{
	global.is_paused = true;
}
