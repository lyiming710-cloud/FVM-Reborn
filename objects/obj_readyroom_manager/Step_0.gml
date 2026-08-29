
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

    if (os_type == os_ios) {
        // Synchronise only our own edge detector. Do not clear GameMaker's
        // synthetic mouse state, which can strand iPad touch/trackpad input.
        for (var _sync_d = 0; _sync_d < 8; _sync_d++) {
            ios_ready_prev_down[_sync_d] = device_mouse_check_button(_sync_d, mb_left);
        }
    }
}

// Recompute immediately after creation/destruction; never carry a stale lock
// into the next input frame.
is_submenu_open = instance_exists(obj_quit_confirm) || instance_exists(obj_level_preview);


// iOS resilient click path. This supplements the legacy Mouse event system
// with direct device_mouse edges so touch keeps working after ESC modals and
// Magic Keyboard attach/detach.
if (os_type == os_ios) {
    var _standard_pressed = mouse_check_button_pressed(mb_left);
    var _press = _standard_pressed;
    var _device_edge = false;
    var _px = mouse_x;
    var _py = mouse_y;

    for (var _d = 0; _d < 8; _d++) {
        var _down = device_mouse_check_button(_d, mb_left);
        var _edge = device_mouse_check_button_pressed(_d, mb_left) || (_down && !ios_ready_prev_down[_d]);
        if (_edge) {
            _press = true;
            _device_edge = true;
            _px = device_mouse_x(_d);
            _py = device_mouse_y(_d);
        }
        ios_ready_prev_down[_d] = _down;
    }

    if (_press && !is_submenu_open) {
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

        // If only device_mouse produced the edge, legacy object Mouse events
        // may not fire. Reproduce the small set of ready-room button actions.
        if (_device_edge && !_standard_pressed && !_handled) {
            var _hit = instance_position(_px, _py, obj_battlestart_button);
            if (_hit != noone) {
                if (deck_slot_count() > 0) {
                    _hit.button_pushed = true;
                    audio_play_sound(snd_button, 0, 0);
                }
                else {
                    show_notice("至少需要选择一张防御卡", 60);
                }
                _handled = true;
            }

            if (!_handled) {
                _hit = instance_position(_px, _py, obj_deck_clear_btn);
                if (_hit != noone) {
                    audio_play_sound(snd_button, 0, 0);
                    clear_deck();
                    _handled = true;
                }
            }

            if (!_handled) {
                _hit = instance_position(_px, _py, obj_deck_select_btn);
                if (_hit != noone) {
                    if (selected_custom_deck != _hit.deck_index) {
                        selected_custom_deck = _hit.deck_index;
                        audio_play_sound(snd_button, 0, 0);
                        load_custom_deck(_hit.deck_index - 1);
                    }
                    _handled = true;
                }
            }

            if (!_handled) {
                _hit = instance_position(_px, _py, obj_readyroom_slot_btn);
                if (_hit != noone) {
                    if (_hit.type == "prev") {
                        if (deck_first_slot_index >= 10) deck_first_slot_index -= 10;
                        else deck_first_slot_index = 10;
                    }
                    else {
                        if (deck_first_slot_index < 10) deck_first_slot_index += 10;
                        else deck_first_slot_index = 0;
                    }
                    audio_play_sound(snd_button, 0, 0);
                }
            }
        }
    }
}
