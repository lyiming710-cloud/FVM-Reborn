
if (not audio_is_playing(readyroom_music)) {
    audio_stop_sound(readyroom_music);
    global.audio.play(readyroom_music, 0, 0);
}

// Always derive the lock from real instances before reading it.
is_submenu_open = instance_exists(obj_quit_confirm) || instance_exists(obj_level_preview);

var _readyroom_esc = keyboard_check_pressed(vk_escape);
var _readyroom_right_click = mouse_check_button_pressed(mb_right);
if (_readyroom_esc || _readyroom_right_click) {
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

    // Consume the triggering edge so another object cannot process it in the same frame.
    if (_readyroom_esc) keyboard_clear(vk_escape);
    if (_readyroom_right_click) mouse_clear(mb_right);

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


// 飞入动画推进（线性：每帧固定位移，到点后由槽位绘制接手）
if fly_active{
	fly_t++
	if fly_t >= fly_dur fly_active = false
}

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
                        global.audio.play(snd_button, 0, 0);
                        remove_from_deck(_slot);
                        _handled = true;
                        break;
                    }
                }
            }
        }

        // Level preview region.
        if (!_handled && _px > 785 && _px < 1546 && _py > 762 && _py < 980) {
            global.audio.play(snd_button, 0, 0);
            var _preview = instance_create_depth(0, 0, -500, obj_level_preview);
            _preview.enemy_type_list = enemy_type_list;
            _preview.boss_type_list = boss_type_list;
            _handled = true;
        }

        if (_handled) {
            global.pointer_input.consumed = true;
        }
}

// 选卡区快捷键：光标悬停在卡池卡片上时按「卡槽 N」，直接把这张卡放进第 N 槽
// （槽号与右侧卡槽显示一致；只认已解锁槽位，目标槽在另一页时先翻页，否则飞行终点落在看不见的格子）
if (hover_card_index != -1 && !is_submenu_open && !instance_exists(obj_package_bg)) {
	var _hot_card = global.player_deck[| hover_card_index * 2]
	for (var _k = 1; _k <= deck_slot_max(); _k++) {
		var _hot_key = global.keybind_map[? "卡槽" + string(_k)]
		if (_hot_key == undefined) continue
		if (!keyboard_check_pressed(_hot_key)) continue

		var _hot_slot = _k - 1
		var _hot_page = (_hot_slot >= 11) ? 10 : 0
		if (deck_first_slot_index != _hot_page) deck_first_slot_index = _hot_page

		global.audio.play(snd_button, 0, 0)
		// 目标槽已经有卡时，先给被替换的那张卡生成一条飞回卡池的动画
		// （和「清空」按钮走同一条 fly_batch 通道：飞行期间它在卡池的格子仍按"已选"灰显，落地后才恢复可选）
		// 出发位置 = 目标槽（页已翻好，用槽位在当页的列号），落点 = 这张卡在卡池网格里的格子
		// 必须在 add_to_deck() 之前取旧卡的 sprite / 卡池下标：它会 ds_map_destroy 掉被覆盖的那条记录
		if (!deck_slot_is_empty(_hot_slot)) {
			var _old_entry = global.selected_deck[| _hot_slot]
			var _old_id = _old_entry[? "card_id"]
			var _old_spr = _old_entry[? "data"][? "sprite"]
			var _old_pool_i = -1
			for (var _pk = 0; _pk < ds_list_size(global.player_deck); _pk += 2) {
				if (global.player_deck[| _pk] == _old_id) { _old_pool_i = _pk div 2; break }
			}
			if (_old_pool_i >= 0 && sprite_exists(_old_spr)) {
				array_push(fly_batch, {
					add: false,   // 飞回卡池
					spr: _old_spr,
					sx: x + 805 + (_hot_slot - deck_first_slot_index) * 86,
					sy: y + 132,
					tx: (x + 42 + (_old_pool_i mod slot_rows) * 84) + (x - 25 + 803 - 42),
					ty: (y + 48 + (_old_pool_i div slot_rows) * 96 - y_offset) + (y + 375 - 48),
					t: 0,
					dur: 18,
					pool_i: _old_pool_i
				})
			}
		}
		if (add_to_deck(_hot_card, get_card_info_simple(_hot_card).shape, _hot_slot)) {
			// 飞入卡槽：起点 = 绘制时记下的悬停卡片屏幕位置
			fly_add = true
			fly_spr = hover_card_spr
			fly_sx = hover_card_x
			fly_sy = hover_card_y
			fly_tx = x + 805 + (_hot_slot - deck_first_slot_index) * 86
			fly_ty = y + 132
			fly_slot = _hot_slot
			fly_dur = 18
			fly_t = 0
			fly_active = true
		}
		break
	}
}

// 清空时批量飞回卡池：倒着删避免下标错位
for (var _bi = array_length(fly_batch) - 1; _bi >= 0; _bi--){
	fly_batch[_bi].t++
	if fly_batch[_bi].t >= fly_batch[_bi].dur array_delete(fly_batch, _bi, 1)
}
