// 强制清除application_surface，避免上一房间图像残留
surface_set_target(application_surface);
draw_clear_alpha(c_black, 0); // 用透明黑色清除surface，alpha值0表示完全透明
surface_reset_target();

global.menu_screen = false
instance_create_depth(1700,883,-2,obj_battlestart_button)
readyroom_music = mus_readyroom

ds_list_clear(global.selected_deck);
deck_ensure_size();
//for(var i = 0;i < 21;i++){
//add_to_deck("xiao_long_bao",0);
//}
//add_to_deck("small_fire",get_card_info_simple("small_fire").shape);
//add_to_deck("flour_sack",get_card_info_simple("flour_sack").shape);
//add_to_deck("toast_bread",0)
//add_to_deck("toast_bread",0);
select_card_index = ds_list_create()
hover_card_index = -1
hover_slot_index = -1
slot_rows = 11
slot_cols = 10
slot_surface = -1
map_surface = -1
y_offset = 0

// Scrollable card library. The old screen only exposed mouse-wheel events,
// which left touch users unable to reach the clipped bottom rows.
card_scroll_view_left = x + 761
card_scroll_view_right = x + 1685
card_scroll_view_top = y + 327
card_scroll_view_bottom = y + 747
card_scroll_view_height = card_scroll_view_bottom - card_scroll_view_top
card_scroll_bottom_padding = 12
card_scroll_row_count = 1
card_scroll_content_height = card_scroll_view_height
card_scroll_max = 0
card_scroll_dragging = false
card_scroll_moved = false
card_scroll_start_y = 0
card_scroll_start_offset = 0
card_scroll_threshold = 12
card_scrollbar_x = x + 1700
card_scrollbar_width = 18
card_scrollbar_dragging = false
card_scrollbar_grab_offset = 0
card_scrollbar_thumb_y = card_scroll_view_top
card_scrollbar_thumb_h = card_scroll_view_height

function readyroom_refresh_card_scroll_metrics(){
	var _card_count = ds_list_size(global.player_deck) div 2
	card_scroll_row_count = max(1,ceil(_card_count / slot_rows))
	card_scroll_content_height = card_scroll_row_count * 96 + card_scroll_bottom_padding
	card_scroll_max = max(0,card_scroll_content_height - card_scroll_view_height)
	y_offset = clamp(y_offset,0,card_scroll_max)

	if card_scroll_max > 0{
		card_scrollbar_thumb_h = max(56,card_scroll_view_height * card_scroll_view_height / card_scroll_content_height)
		card_scrollbar_thumb_y = card_scroll_view_top
			+ (y_offset / card_scroll_max) * (card_scroll_view_height - card_scrollbar_thumb_h)
	}
	else{
		card_scrollbar_thumb_h = card_scroll_view_height
		card_scrollbar_thumb_y = card_scroll_view_top
	}
}

function readyroom_select_card_at_point(_px,_py){
	if !point_in_rectangle(_px,_py,card_scroll_view_left,card_scroll_view_top,
		card_scroll_view_right,card_scroll_view_bottom){
		return false
	}

	var _card_index = 0
	for(var _i = 0;_i < ds_list_size(global.player_deck);_i += 2){
		var _card_id = global.player_deck[| _i]
		var _row = _card_index div slot_rows
		var _col = _card_index mod slot_rows
		var _cx = x + 803 + _col * 84
		var _cy = y + 375 + _row * 96 - y_offset

		if point_in_rectangle(_px,_py,_cx - 42,_cy - 48,_cx + 42,_cy + 48){
			var _unlocked = false
			var _already_selected = false

			for(var _u = 0;_u < array_length(global.save_data.unlocked_cards);_u++){
				if global.save_data.unlocked_cards[_u].id == _card_id{
					_unlocked = true
					break
				}
			}
			for(var _s = 0;_s < ds_list_size(global.selected_deck);_s++){
				if global.selected_deck[| _s][? "card_id"] == _card_id{
					_already_selected = true
					break
				}
			}

			if _unlocked && !_already_selected && deck_slot_first_empty() != -1{
				audio_play_sound(snd_button,0,0)
				add_to_deck(_card_id,get_card_info_simple(_card_id).shape)
			}
			return true
		}
		_card_index++
	}
	return false
}

readyroom_refresh_card_scroll_metrics()

is_submenu_open = false

deck_first_slot_index = 0

selected_custom_deck = 0

for(var i = 1; i < 7;i++){
	var inst = instance_create_depth(x+680+150*i,y+218,depth-5,obj_deck_select_btn)
	inst.deck_index = i
}
instance_create_depth(x+1735,y+215,depth-5,obj_deck_clear_btn)

var prev_btn = instance_create_depth(x+1745,y+105,depth-5,obj_readyroom_slot_btn)
prev_btn.type = "prev"
var next_btn = instance_create_depth(x+1745,y+155,depth-5,obj_readyroom_slot_btn)
next_btn.type = "next"

//统计敌人和BOSS类型
enemy_type_list = []
boss_type_list = []
for(var i = 0;i < global.level_file.total_waves;i ++){
	if global.level_file.waves[i].boss_wave{
		if array_get_index(boss_type_list,global.level_file.waves[i].boss) == -1{
			array_push(boss_type_list,global.level_file.waves[i].boss)
		}
		if is_real(global.level_file.version){
			if array_get_index(boss_type_list,global.level_file.waves[i].boss2) == -1 && global.level_file.waves[i].boss2 != ""{
				array_push(boss_type_list,global.level_file.waves[i].boss2)
			}
		}
	}
	var subwave = global.level_file.waves[i].subwaves
	for(var j = 0 ; j <array_length(subwave);j++){
		var enemy_list = subwave[j].enemy_list
		for(var k = 0 ; k < array_length(enemy_list);k++){
			if array_get_index(enemy_type_list,enemy_list[k].type) == -1{
				array_push(enemy_type_list,enemy_list[k].type)
			}
		}
	}
}
