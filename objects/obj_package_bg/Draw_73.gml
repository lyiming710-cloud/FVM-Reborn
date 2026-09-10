// Draw End keeps the scrollbar in the same room-coordinate space as the backpack.
var _row_height = 88
var _visible_rows = 9
if (package_button_select == 1) {
    _row_height = 96
    _visible_rows = 8
}
var _content_h = package_rows * _row_height
var _visible_h = _visible_rows * _row_height
var _max_offset = max(0, _content_h - _visible_h)

if (_max_offset > 0 && !is_submenu_opened) {
    var _track_h = package_scrollbar_bottom - package_scrollbar_top
    var _thumb_h = max(64, _track_h * min(1, _visible_h / _content_h))
    var _travel = max(1, _track_h - _thumb_h)
    var _thumb_top = package_scrollbar_top + (clamp(y_offset, 0, _max_offset) / _max_offset) * _travel

    draw_set_alpha(0.35)
    draw_set_colour(c_black)
    draw_rectangle(package_scrollbar_x, package_scrollbar_top,
        package_scrollbar_x + package_scrollbar_width, package_scrollbar_bottom, false)
    draw_set_alpha(0.85)
    draw_set_colour(c_white)
    draw_rectangle(package_scrollbar_x, _thumb_top,
        package_scrollbar_x + package_scrollbar_width, _thumb_top + _thumb_h, false)
    draw_set_alpha(1)
    draw_set_colour(c_white)
}
