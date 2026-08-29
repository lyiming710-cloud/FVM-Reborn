update_notices()

// iPadOS touch / Magic Keyboard pointer recovery.
// Keep the normal GameMaker Mouse event path as the primary input path.
// Only synthesize a click when device_mouse sees a fresh press that the
// normal mouse layer did not report.
if (os_type == os_ios) {
    var _focus_now = window_has_focus();
    if (_focus_now != ios_last_focus) {
        io_clear();
        ios_prev_device0_down = false;
        ios_prev_device1_down = false;
        ios_mouse_mismatch_frames = 0;
        ios_last_focus = _focus_now;
    }

    var _d0_down = device_mouse_check_button(0, mb_left);
    var _d1_down = device_mouse_check_button(1, mb_left);
    var _d0_pressed = _d0_down && !ios_prev_device0_down;
    var _d1_pressed = _d1_down && !ios_prev_device1_down;
    var _device_pressed = _d0_pressed || _d1_pressed;
    var _native_pressed = mouse_check_button_pressed(mb_left);

    // A detached trackpad can leave the legacy mouse button state latched.
    // Clear it once it disagrees with all device pointers for a few frames.
    if (!_d0_down && !_d1_down && mouse_check_button(mb_left)) {
        ios_mouse_mismatch_frames += 1;
        if (ios_mouse_mismatch_frames >= 3) {
            io_clear();
            ios_mouse_mismatch_frames = 0;
        }
    } else {
        ios_mouse_mismatch_frames = 0;
    }

    if (_device_pressed && !_native_pressed) {
        var _device = _d0_pressed ? 0 : 1;
        var _px = device_mouse_x(_device);
        var _py = device_mouse_y(_device);

        // Re-fire the local Left Pressed mouse event on the top-most instance
        // under the iPad pointer. This restores ordinary buttons that use
        // Mouse_4.gml without changing their existing code.
        var _hits = ds_list_create();
        collision_point_list(_px, _py, all, false, true, _hits, false);

        var _target = noone;
        var _best_depth = 1000000000;
        for (var _i = 0; _i < ds_list_size(_hits); _i++) {
            var _inst = ds_list_find_value(_hits, _i);
            if (instance_exists(_inst) && _inst.visible && _inst.depth < _best_depth) {
                _best_depth = _inst.depth;
                _target = _inst;
            }
        }

        if (_target != noone) {
            with (_target) {
                event_perform(ev_mouse, 4);
            }
        }
        ds_list_destroy(_hits);

        // These objects intentionally use Global Left Pressed (Mouse_53.gml),
        // so mirror that event as well when the normal mouse layer misses it.
        with (obj_craft_bg) event_perform(ev_mouse, 53);
        with (obj_info_island_bg) event_perform(ev_mouse, 53);
        with (obj_package_bg) event_perform(ev_mouse, 53);
        with (obj_player_character) event_perform(ev_mouse, 53);
        with (obj_readyroom_manager) event_perform(ev_mouse, 53);
        with (obj_text_input) event_perform(ev_mouse, 53);
    }

    ios_prev_device0_down = _d0_down;
    ios_prev_device1_down = _d1_down;
}
