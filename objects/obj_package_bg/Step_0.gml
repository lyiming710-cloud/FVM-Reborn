// Keep the existing mouse-wheel y_offset semantics and add direct thumb dragging.
var _row_height = 88
var _visible_rows = 9
if (package_button_select == 1) {
    _row_height = 96
    _visible_rows = 8
}

var _content_h = package_rows * _row_height
var _visible_h = _visible_rows * _row_height
var _max_offset = max(0, _content_h - _visible_h)
y_offset = clamp(y_offset, 0, _max_offset)

if (_max_offset <= 0 || is_submenu_opened) {
    package_scrollbar_dragging = false
    exit
}

var _pointer_x = mouse_x
var _pointer_y = mouse_y
var _pointer_pressed = mouse_check_button_pressed(mb_left)
var _pointer_released = mouse_check_button_released(mb_left)
var _pointer_down = mouse_check_button(mb_left)
var _use_ios_pointer = os_type == os_ios && variable_global_exists("pointer_input")

if (_use_ios_pointer) {
    _pointer_x = global.pointer_input.x
    _pointer_y = global.pointer_input.y
    _pointer_pressed = global.pointer_input.pressed && !global.pointer_input.consumed
    _pointer_released = global.pointer_input.released
    if (global.pointer_input.device >= 0) {
        _pointer_down = _pointer_down || device_mouse_check_button(global.pointer_input.device, mb_left)
    }
}

var _track_h = package_scrollbar_bottom - package_scrollbar_top
var _thumb_h = max(64, _track_h * min(1, _visible_h / _content_h))
var _travel = max(1, _track_h - _thumb_h)
var _thumb_top = package_scrollbar_top + (y_offset / _max_offset) * _travel
var _bar_left = package_scrollbar_x - 8
var _bar_right = package_scrollbar_x + package_scrollbar_width + 8

if (_pointer_pressed && point_in_rectangle(_pointer_x, _pointer_y,
    _bar_left, package_scrollbar_top, _bar_right, package_scrollbar_bottom)) {
    package_scrollbar_dragging = true
    if (point_in_rectangle(_pointer_x, _pointer_y,
        _bar_left, _thumb_top, _bar_right, _thumb_top + _thumb_h)) {
        package_scrollbar_grab_offset = _pointer_y - _thumb_top
    }
    else {
        package_scrollbar_grab_offset = _thumb_h * 0.5
    }
    if (_use_ios_pointer) global.pointer_input.consumed = true
}

if (package_scrollbar_dragging) {
    if (_pointer_down) {
        var _new_thumb_top = clamp(_pointer_y - package_scrollbar_grab_offset,
            package_scrollbar_top, package_scrollbar_bottom - _thumb_h)
        y_offset = ((_new_thumb_top - package_scrollbar_top) / _travel) * _max_offset
        y_offset = clamp(y_offset, 0, _max_offset)
        if (_use_ios_pointer) global.pointer_input.consumed = true
    }

    if (_pointer_released || !_pointer_down) {
        package_scrollbar_dragging = false
        if (_use_ios_pointer) global.pointer_input.consumed = true
    }
}
