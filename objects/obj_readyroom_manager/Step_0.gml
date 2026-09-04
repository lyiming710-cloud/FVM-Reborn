
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

readyroom_refresh_card_scroll_metrics()

// Unified mouse/touch scrolling for the clipped card library. A short press is
// resolved as a card tap on release; moving past the threshold becomes a drag,
// so swiping over a card never selects it accidentally.
var _scroll_pointer_x = mouse_x
var _scroll_pointer_y = mouse_y
var _scroll_pointer_pressed = mouse_check_button_pressed(mb_left)
var _scroll_pointer_released = mouse_check_button_released(mb_left)
var _scroll_pointer_down = mouse_check_button(mb_left)

if os_type == os_ios{
	_scroll_pointer_x = global.pointer_input.x
	_scroll_pointer_y = global.pointer_input.y
	_scroll_pointer_pressed = global.pointer_input.pressed && !global.pointer_input.consumed
	_scroll_pointer_released = global.pointer_input.released
	if global.pointer_input.device >= 0{
		_scroll_pointer_down = _scroll_pointer_down
			|| device_mouse_check_button(global.pointer_input.device,mb_left)
	}
}

if is_submenu_open{
	card_scroll_dragging = false
	card_scrollbar_dragging = false
}
else{
	if _scroll_pointer_pressed{
		var _over_scrollbar = card_scroll_max > 0
			&& point_in_rectangle(_scroll_pointer_x,_scroll_pointer_y,
				card_scrollbar_x - 12,card_scroll_view_top,
				card_scrollbar_x + card_scrollbar_width + 12,card_scroll_view_bottom)

		if _over_scrollbar{
			card_scrollbar_dragging = true
			card_scroll_dragging = false
			if point_in_rectangle(_scroll_pointer_x,_scroll_pointer_y,
				card_scrollbar_x - 12,card_scrollbar_thumb_y,
				card_scrollbar_x + card_scrollbar_width + 12,
				card_scrollbar_thumb_y + card_scrollbar_thumb_h){
				card_scrollbar_grab_offset = _scroll_pointer_y - card_scrollbar_thumb_y
			}
			else{
				card_scrollbar_grab_offset = card_scrollbar_thumb_h * 0.5
			}
		}
		else if point_in_rectangle(_scroll_pointer_x,_scroll_pointer_y,
			card_scroll_view_left,card_scroll_view_top,
			card_scroll_view_right,card_scroll_view_bottom){
			card_scroll_dragging = true
			card_scrollbar_dragging = false
			card_scroll_moved = false
			card_scroll_start_y = _scroll_pointer_y
			card_scroll_start_offset = y_offset
		}

		if os_type == os_ios && (card_scroll_dragging || card_scrollbar_dragging){
			global.pointer_input.consumed = true
		}
	}

	if card_scrollbar_dragging && _scroll_pointer_down{
		var _thumb_travel = card_scroll_view_height - card_scrollbar_thumb_h
		var _thumb_top = clamp(_scroll_pointer_y - card_scrollbar_grab_offset,
			card_scroll_view_top,card_scroll_view_bottom - card_scrollbar_thumb_h)
		if _thumb_travel > 0{
			y_offset = ((_thumb_top - card_scroll_view_top) / _thumb_travel) * card_scroll_max
		}
		if os_type == os_ios global.pointer_input.consumed = true
	}

	if card_scroll_dragging && _scroll_pointer_down{
		var _drag_delta = _scroll_pointer_y - card_scroll_start_y
		if abs(_drag_delta) >= card_scroll_threshold card_scroll_moved = true
		if card_scroll_moved{
			y_offset = clamp(card_scroll_start_offset - _drag_delta,0,card_scroll_max)
		}
		if os_type == os_ios global.pointer_input.consumed = true
	}

	if _scroll_pointer_released{
		if card_scroll_dragging{
			if !card_scroll_moved{
				readyroom_select_card_at_point(_scroll_pointer_x,_scroll_pointer_y)
			}
			card_scroll_dragging = false
			card_scroll_moved = false
			if os_type == os_ios global.pointer_input.consumed = true
		}
		if card_scrollbar_dragging{
			card_scrollbar_dragging = false
			if os_type == os_ios global.pointer_input.consumed = true
		}
	}
	else if !_scroll_pointer_down{
		// Recover cleanly if focus or the active pointer device changed mid-drag.
		card_scroll_dragging = false
		card_scrollbar_dragging = false
		card_scroll_moved = false
	}
}

readyroom_refresh_card_scroll_metrics()


// Coordinate-driven fallback for the parts of the ready room that use a
// Global Mouse event instead of button instances. The persistent pointer
// controller guarantees this edge is seen only once.
if (os_type == os_ios && global.pointer_input.device_only &&
    !global.pointer_input.consumed && !is_submenu_open) {
        var _px = global.pointer_input.x;
	        var _py = global.pointer_input.y;
	        var _handled = false;

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
