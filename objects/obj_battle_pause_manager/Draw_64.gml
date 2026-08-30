// iPad-only battle touch controls (Draw GUI).
if (os_type == os_ios && instance_exists(obj_battle)) {
    var _gh = display_get_gui_height();

    var _x1 = 24;
    var _x2 = 184;

    // Bottom -> top: ESC, speed, card-selection slow-time switch.
    var _esc_y1 = _gh - 98;
    var _esc_y2 = _gh - 28;
    var _speed_y1 = _gh - 182;
    var _speed_y2 = _gh - 112;
    var _slow_y1 = _gh - 266;
    var _slow_y2 = _gh - 196;

    draw_set_font(font_yuan);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    // ESC is the only persistent HUD button.
    draw_set_alpha(global.show_menu ? 0.82 : 0.58);
    draw_set_color(c_black);
    draw_roundrect(_x1, _esc_y1, _x2, _esc_y2, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_roundrect(_x1, _esc_y1, _x2, _esc_y2, true);
    draw_text((_x1 + _x2) * 0.5, (_esc_y1 + _esc_y2) * 0.5, "ESC");

    if (!global.is_paused && !global.show_menu) {
        // Speed 1x/2x. ASCII x avoids a missing-glyph square on iOS.
        draw_set_alpha(obj_battle.speed_up ? 0.82 : 0.58);
        draw_set_color(c_black);
        draw_roundrect(_x1, _speed_y1, _x2, _speed_y2, false);
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_roundrect(_x1, _speed_y1, _x2, _speed_y2, true);
        draw_text((_x1 + _x2) * 0.5, (_speed_y1 + _speed_y2) * 0.5,
            obj_battle.speed_up ? "倍速 2x" : "倍速 1x");

        // This switch only controls automatic 0.1x while a plant card is held.
        draw_set_alpha(obj_battle.card_slow_enabled ? 0.82 : 0.58);
        draw_set_color(c_black);
        draw_roundrect(_x1, _slow_y1, _x2, _slow_y2, false);
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_roundrect(_x1, _slow_y1, _x2, _slow_y2, true);
        draw_text((_x1 + _x2) * 0.5, (_slow_y1 + _slow_y2) * 0.5,
            obj_battle.card_slow_enabled ? "缓时 开" : "缓时 关");
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}