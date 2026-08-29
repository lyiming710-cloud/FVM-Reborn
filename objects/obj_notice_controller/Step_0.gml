update_notices()

// iPadOS touch / Magic Keyboard pointer recovery.
// Normal GameMaker Mouse events remain the primary path. device_mouse only
// fills in a press edge when the native synthetic mouse layer misses it.
if (os_type == os_ios) {
    var _focus_now = window_has_focus();

    // Focus changes can remap pointer device slots. Resynchronise our own edge
    // detector only; never call io_clear()/mouse_clear() here.
    if (_focus_now != ios_last_focus) {
        for (var _sync_d = 0; _sync_d < 8; _sync_d++) {
            ios_prev_down[_sync_d] = device_mouse_check_button(_sync_d, mb_left);
        }
        ios_last_focus = _focus_now;
        exit;
    }

    var _device = -1;
    for (var _d = 0; _d < 8; _d++) {
        var _down = device_mouse_check_button(_d, mb_left);
        var _edge = device_mouse_check_button_pressed(_d, mb_left) || (_down && !ios_prev_down[_d]);
        if (_device == -1 && _edge) {
            _device = _d;
        }
        ios_prev_down[_d] = _down;
    }

    var _native_pressed = mouse_check_button_pressed(mb_left);

    if (_device != -1 && !_native_pressed) {
        var _px = device_mouse_x(_device);
        var _py = device_mouse_y(_device);

        // Re-fire the local Left Pressed event on the top-most visible instance
        // under the physical pointer. This preserves existing button logic.
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

        // These objects intentionally use Global Left Pressed. Ready-room input
        // is excluded because obj_readyroom_manager already has its own
        // coordinate-correct device_mouse fallback in Step_0.gml.
        with (obj_craft_bg) event_perform(ev_mouse, 53);
        with (obj_info_island_bg) event_perform(ev_mouse, 53);
        with (obj_package_bg) event_perform(ev_mouse, 53);
        with (obj_player_character) event_perform(ev_mouse, 53);
        with (obj_text_input) event_perform(ev_mouse, 53);
    }
}
