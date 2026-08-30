// Recover if the previous frame ended before Pre Draw cleared a synthetic pause.
if (global.battle_skip_frame) {
    global.is_paused = global.battle_keep_paused_after_skip;
    global.battle_skip_frame = false;
    global.battle_keep_paused_after_skip = false;
}
global.battle_simulation_tick = true;

// Release a synthetic ESC from the previous frame before sampling new input.
if (ios_virtual_esc_held) {
    keyboard_key_release(vk_escape);
    ios_virtual_esc_held = false;
}

// Begin Step: sample every pointer source once before gameplay/UI Step events.
var _native_pressed = mouse_check_button_pressed(mb_left);
var _native_released = mouse_check_button_released(mb_left);
var _pressed_device = -1;
var _down_device = -1;
var _released_device = -1;

for (var _d = 0; _d < 8; _d++) {
    var _down = device_mouse_check_button(_d, mb_left);
    var _edge = device_mouse_check_button_pressed(_d, mb_left) ||
        (_down && !ios_prev_down[_d]);
    var _release_edge = device_mouse_check_button_released(_d, mb_left) ||
        (!_down && ios_prev_down[_d]);

    if (_pressed_device == -1 && _edge) _pressed_device = _d;
    if (_down_device == -1 && _down) _down_device = _d;
    if (_released_device == -1 && _release_edge) _released_device = _d;
    ios_prev_down[_d] = _down;
}

var _focus_now = window_has_focus();
var _focus_changed = (_focus_now != ios_last_focus);
ios_last_focus = _focus_now;

var _px = mouse_x;
var _py = mouse_y;
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _gui_x = _px * _gw / room_width;
var _gui_y = _py * _gh / room_height;
var _coordinate_device = (_pressed_device != -1) ? _pressed_device : _down_device;

if (_coordinate_device != -1) {
    _px = device_mouse_x(_coordinate_device);
    _py = device_mouse_y(_coordinate_device);
    _gui_x = device_mouse_x_to_gui(_coordinate_device);
    _gui_y = device_mouse_y_to_gui(_coordinate_device);
}
else if (_released_device != -1) {
    _px = device_mouse_x(_released_device);
    _py = device_mouse_y(_released_device);
    _gui_x = device_mouse_x_to_gui(_released_device);
    _gui_y = device_mouse_y_to_gui(_released_device);
}

global.pointer_input.pressed = !_focus_changed &&
    (_native_pressed || _pressed_device != -1);
global.pointer_input.released = !_focus_changed &&
    (_native_released || _released_device != -1);
global.pointer_input.native_pressed = !_focus_changed && _native_pressed;
global.pointer_input.device_only = !_focus_changed &&
    (_pressed_device != -1) && !_native_pressed;
global.pointer_input.consumed = false;
global.pointer_input.device = _coordinate_device;
global.pointer_input.x = _px;
global.pointer_input.y = _py;
global.pointer_input.gui_x = _gui_x;
global.pointer_input.gui_y = _gui_y;


// Persistent iOS ESC button. Outside battle this is the only touch HUD key.
// In battle, obj_battle_pause_manager draws and handles the same bottom slot
// together with pause/speed/slow controls.
if (os_type == os_ios && !instance_exists(obj_battle) &&
    global.pointer_input.pressed && !global.pointer_input.consumed) {
    var _esc_x1 = 24;
    var _esc_x2 = 184;
    var _esc_y1 = _gh - 98;
    var _esc_y2 = _gh - 28;

    if (_gui_x >= _esc_x1 && _gui_x <= _esc_x2 &&
        _gui_y >= _esc_y1 && _gui_y <= _esc_y2) {
        global.pointer_input.consumed = true;
        keyboard_key_press(vk_escape);
        ios_virtual_esc_held = true;
    }
}


// Schedule gameplay independently from the 120 FPS input/render loop.
if (instance_exists(obj_battle)) {
    var _battle_clock = instance_find(obj_battle, 0);
    if (!global.is_paused) {
        var _logic_hz = _battle_clock.speed_up ? 120 : 60;
        if (_battle_clock.card_hold_active && _battle_clock.card_slow_enabled) _logic_hz = 6;

        _battle_clock.simulation_accumulator += _logic_hz;
        if (_battle_clock.simulation_accumulator >= 120) {
            _battle_clock.simulation_accumulator -= 120;
            global.battle_simulation_tick = true;
        }
        else {
            global.battle_simulation_tick = false;
            global.battle_skip_frame = true;
            global.battle_keep_paused_after_skip = false;
            global.is_paused = true;
        }
    }

    // Alarms are decremented by GameMaker after Begin Step but before Step.
    // Hold battle alarms steady on real or synthetic pause frames by adding
    // back one tick now, before the engine performs that decrement.
    if (global.is_paused) {
        with (obj_flour_sack) {
            if (alarm[0] >= 0) alarm[0] += 1;
            if (alarm[1] >= 0) alarm[1] += 1;
        }
    }
}
else {
    global.battle_simulation_tick = true;
    global.battle_skip_frame = false;
    global.battle_keep_paused_after_skip = false;
}