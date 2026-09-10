draw_set_alpha(0.5);
// 绘制半透明遮罩
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);
draw_self()

if button_select < 0{
	draw_set_font(font_yuan)
	draw_set_colour(c_black)
	draw_set_halign(fa_left)
	draw_set_valign(fa_middle)
	draw_text(x+230,y-260,"未选择食谱类型")
	draw_text(x+240,y-163,"点击左侧选项卡以选择食谱类型")
	draw_text(x+230,y+33,"未选择食谱类型")
	draw_text(x+240,y+128,"点击左侧选项卡以选择食谱类型")
}
else{
	var cookbook_rank_list = global.save_data.equipped_cookbook[button_select]
	var cookbook_material = ["copper_cookbook_fragment","silver_cookbook_fragment","gold_cookbook_fragment"]
	var max_cookbook_slot = clamp(get_material_amount(cookbook_material[button_select]),0,2)
	draw_set_font(font_yuan)
	draw_set_colour(c_black)
	draw_set_halign(fa_left)
	draw_set_valign(fa_middle)
	if max_cookbook_slot <= 0{
		draw_text(x+230,y-260,"食谱槽位未解锁")
		var cm_data = get_material_info(cookbook_material[button_select])
		draw_text(x+240,y-163,$"获取1个{cm_data.name}以解锁此槽位")
	}
	else{
		if array_length(cookbook_rank_list) >= 1{
			var cdata = get_cookbook_data(cookbook_rank_list[0])
			draw_text(x+230,y-285,cdata.title)
			draw_text(x+230,y-235,cdata.tiny_desc)
			draw_set_valign(fa_top)
			draw_text(x+230,y-176,cdata.desc)
			draw_sprite_ext(spr_cookbook_icon,cdata.icon,x+150,y-260,1.8,1.8,0,c_white,1)
		}
		else{
			draw_text(x+230,y-260,"未装配食谱")
			draw_text(x+240,y-163,"在左侧食谱列表中装配食谱")
		}
	}
	if max_cookbook_slot <= 1{
		draw_text(x+230,y+33,"食谱槽位未解锁")
		var cm_data = get_material_info(cookbook_material[button_select])
		draw_text(x+240,y+128,$"获取2个{cm_data.name}以解锁此槽位")
	}
	else{
		if array_length(cookbook_rank_list) >= 2{
			var cdata = get_cookbook_data(cookbook_rank_list[1])
			draw_set_valign(fa_middle)
			draw_text(x+230,y+8,cdata.title)
			draw_text(x+230,y+58,cdata.tiny_desc)
			draw_set_valign(fa_top)
			draw_text(x+230,y+115,cdata.desc)
			draw_sprite_ext(spr_cookbook_icon,cdata.icon,x+150,y+33,1.8,1.8,0,c_white,1)
		}
		else{
			draw_set_valign(fa_middle)
			draw_text(x+230,y+33,"未装配食谱")
			draw_text(x+240,y+128,"在左侧食谱列表中装配食谱")
		}
	}
}

// More than six recipes require scrolling. Upstream exposes only wheel events;
// render a narrow drag target as the touch-accessible equivalent.
var _cookbook_max_offset = max(0, array_length(current_cookbook_list) - 6)
if (_cookbook_max_offset > 0) {
    var _cookbook_track_h = cookbook_scrollbar_bottom - cookbook_scrollbar_top
    var _cookbook_thumb_h = max(64, _cookbook_track_h * min(1, 6 / array_length(current_cookbook_list)))
    var _cookbook_travel = max(1, _cookbook_track_h - _cookbook_thumb_h)
    var _cookbook_thumb_top = cookbook_scrollbar_top + (clamp(y_offset, 0, _cookbook_max_offset) / _cookbook_max_offset) * _cookbook_travel

    draw_set_alpha(0.35)
    draw_set_colour(c_black)
    draw_rectangle(cookbook_scrollbar_x, cookbook_scrollbar_top,
        cookbook_scrollbar_x + cookbook_scrollbar_width, cookbook_scrollbar_bottom, false)
    draw_set_alpha(0.85)
    draw_set_colour(c_white)
    draw_rectangle(cookbook_scrollbar_x, _cookbook_thumb_top,
        cookbook_scrollbar_x + cookbook_scrollbar_width, _cookbook_thumb_top + _cookbook_thumb_h, false)
    draw_set_alpha(1)
    draw_set_colour(c_white)
}
