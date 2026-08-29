// iPad-only battle touch controls (Draw GUI).
if (os_type == os_ios && instance_exists(obj_battle)) {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();

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

    draw_set_font(font_yuan);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    // Pause
    draw_set_alpha((global.is_paused && !global.show_menu) ? 0.82 : 0.58);
    draw_set_color(c_black);
    draw_roundrect(_top_x1, _top_y1, _top_x2, _top_y2, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_roundrect(_top_x1, _top_y1, _top_x2, _top_y2, true);
    draw_text((_top_x1 + _top_x2) * 0.5, (_top_y1 + _top_y2) * 0.5,
        (global.is_paused && !global.show_menu) ? "继续" : "暂停");

    // Speed 1x/2x
    var _speed_active = obj_battle.speed_up && !obj_battle.slow_time;
    draw_set_alpha(_speed_active ? 0.82 : 0.58);
    draw_set_color(c_black);
    draw_roundrect(_speed_x1, _bottom_y1, _speed_x2, _bottom_y2, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_roundrect(_speed_x1, _bottom_y1, _speed_x2, _bottom_y2, true);
    draw_text((_speed_x1 + _speed_x2) * 0.5, (_bottom_y1 + _bottom_y2) * 0.5,
        obj_battle.speed_up ? "倍速 2×" : "倍速 1×");

    // ESC / pause menu
    draw_set_alpha(global.show_menu ? 0.82 : 0.58);
    draw_set_color(c_black);
    draw_roundrect(_esc_x1, _bottom_y1, _esc_x2, _bottom_y2, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_roundrect(_esc_x1, _bottom_y1, _esc_x2, _bottom_y2, true);
    draw_text((_esc_x1 + _esc_x2) * 0.5, (_bottom_y1 + _bottom_y2) * 0.5, "ESC");

    // 0.5x slow time
    draw_set_alpha(obj_battle.slow_time ? 0.82 : 0.58);
    draw_set_color(c_black);
    draw_roundrect(_slow_x1, _bottom_y1, _slow_x2, _bottom_y2, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_roundrect(_slow_x1, _bottom_y1, _slow_x2, _bottom_y2, true);
    draw_text((_slow_x1 + _slow_x2) * 0.5, (_bottom_y1 + _bottom_y2) * 0.5,
        obj_battle.slow_time ? "缓时 0.5×" : "缓时");

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
