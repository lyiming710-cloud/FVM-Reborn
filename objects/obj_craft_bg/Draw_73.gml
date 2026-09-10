// Card-enhancement scrollbar. Draw End keeps room coordinates aligned with the grid.
if (button_select == 0 && !is_submenu_opened) {
    var _content_h = 96 * 20
    var _visible_h = 815
    var _max_offset = max(0, _content_h - _visible_h)

    if (_max_offset > 0) {
        var _track_h = craft_scrollbar_bottom - craft_scrollbar_top
        var _thumb_h = max(64, _track_h * min(1, _visible_h / _content_h))
        var _travel = max(1, _track_h - _thumb_h)
        var _thumb_top = craft_scrollbar_top + (clamp(y_offset, 0, _max_offset) / _max_offset) * _travel

        draw_set_alpha(0.35)
        draw_set_colour(c_black)
        draw_rectangle(craft_scrollbar_x, craft_scrollbar_top,
            craft_scrollbar_x + craft_scrollbar_width, craft_scrollbar_bottom, false)
        draw_set_alpha(0.85)
        draw_set_colour(c_white)
        draw_rectangle(craft_scrollbar_x, _thumb_top,
            craft_scrollbar_x + craft_scrollbar_width, _thumb_top + _thumb_h, false)
        draw_set_alpha(1)
        draw_set_colour(c_white)
    }
}
