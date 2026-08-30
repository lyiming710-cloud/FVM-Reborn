
if (not audio_is_playing(readyroom_music)) {
    audio_stop_sound(readyroom_music);
    audio_play_sound(readyroom_music, 0, 0);
}

// Always derive the lock from real instances before reading it.
is_submenu_open = instance_exists(obj_quit_confirm) || instance_exists(obj_level_preview);

if (keyboard_check_pressed(vk_escape)) {
    // Close the current top-level ready-room modal first.
    if (instance_exists(obj_level_preview)) {
        instance_destroy(obj_level_preview);
    }
    else if (instance_exists(obj_quit_confirm)) {
        instance_destroy(obj_quit_confirm);
    }
    else {
        instance_create_depth(room_width / 2, room_height / 2, -100, obj_quit_confirm);
    }

    // Consume this ESC so obj_quit_confirm/obj_level_preview cannot process
    // the exact same edge and leave a ghost modal behind.
    keyboard_clear(vk_escape);

}

// Recompute immediately after creation/destruction; never carry a stale lock
// into the next input frame.
is_submenu_open = instance_exists(obj_quit_confirm) || instance_exists(obj_level_preview);


// Coordinate-driven fallback for the parts of the ready room that use a
// Global Mouse event instead of button instances. The persistent pointer
// controller guarantees this edge is seen only once.
if (os_type == os_ios && global.pointer_input.device_only &&
    !global.pointer_input.consumed && !is_submenu_open) {
        var _px = global.pointer_input.x;
        var _py = global.pointer_input.y;
        var _handled = false;

        // Select a card directly from its screen-space slot.
        var _card_index = 0;
        for (var _i = 0; _i < ds_list_size(global.player_deck); _i += 2) {
            var _card_id = global.player_deck[| _i];
            var _row = _card_index div slot_rows;
            var _col = _card_index mod slot_rows;
            var _cx = x + 803 + _col * 84;
            var _cy = y + 375 + _row * 96 - y_offset;

            if (_py > y + 315 && _py < y + 755 &&
                point_in_rectangle(_px, _py, _cx - 42, _cy - 48, _cx + 42, _cy + 48)) {
                var _unlocked = false;
                var _already_selected = false;

                for (var _u = 0; _u < array_length(global.save_data.unlocked_cards); _u++) {
                    if (global.save_data.unlocked_cards[_u].id == _card_id) {
                        _unlocked = true;
                        break;
                    }
                }
                for (var _s = 0; _s < ds_list_size(global.selected_deck); _s++) {
                    if (global.selected_deck[| _s][? "card_id"] == _card_id) {
                        _already_selected = true;
                        break;
                    }
                }

                if (_unlocked && !_already_selected && deck_slot_first_empty() != -1) {
                    audio_play_sound(snd_button, 0, 0);
                    add_to_deck(_card_id, get_card_info_simple(_card_id).shape);
                }
                _handled = true;
                break;
            }
            _card_index++;
        }

        // Remove a selected card directly.
        if (!_handled) {
            for (var _slot = deck_first_slot_index; _slot < deck_first_slot_index + 11; _slot++) {
                if (_slot < deck_slot_max() && !deck_slot_is_empty(_slot)) {
                    var _sx = x + 805 + (_slot - deck_first_slot_index) * 86;
                    var _sy = y + 132;
                    if (point_in_rectangle(_px, _py, _sx - 42, _sy - 48, _sx + 42, _sy + 48)) {
                        audio_play_sound(snd_button, 0, 0);
                        remove_from_deck(_slot);
                        _handled = true;
                        break;
                    }
                }
            }
        }

        // Level preview region.
        if (!_handled && _px > 785 && _px < 1546 && _py > 762 && _py < 980) {
            audio_play_sound(snd_button, 0, 0);
            var _preview = instance_create_depth(0, 0, -500, obj_level_preview);
            _preview.enemy_type_list = enemy_type_list;
            _preview.boss_type_list = boss_type_list;
            _handled = true;
        }

        if (_handled) {
            global.pointer_input.consumed = true;
        }
}
