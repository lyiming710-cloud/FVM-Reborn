// Persistent iOS ESC key. Other virtual keys are battle-only.
if (os_type == os_ios && !instance_exists(obj_battle)) {
    var _gh = display_get_gui_height();
    var _x1 = 24;
    var _x2 = 184;
    var _y1 = _gh - 98;
    var _y2 = _gh - 28;

    draw_set_font(font_yuan);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    draw_set_alpha(0.58);
    draw_set_color(c_black);
    draw_roundrect(_x1, _y1, _x2, _y2, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_roundrect(_x1, _y1, _x2, _y2, true);
    draw_text((_x1 + _x2) * 0.5, (_y1 + _y2) * 0.5, "ESC");

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}