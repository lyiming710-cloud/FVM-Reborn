update_notices()

// Only reproduce a legacy Mouse event when iOS saw a real device edge that
// GameMaker did not convert into a standard mouse edge.
if (os_type == os_ios && global.pointer_input.device_only &&
    !global.pointer_input.consumed) {
        var _px = global.pointer_input.x;
        var _py = global.pointer_input.y;
        var _hits = ds_list_create();
        collision_point_list(_px, _py, all, false, true, _hits, false);

        var _target = noone;
        var _best_depth = 1000000000;
        for (var _i = 0; _i < ds_list_size(_hits); _i++) {
            var _inst = ds_list_find_value(_hits, _i);
            if (instance_exists(_inst) && _inst.visible &&
                array_get_index(ios_clickable_objects, _inst.object_index) != -1 &&
                _inst.depth < _best_depth) {
                _best_depth = _inst.depth;
                _target = _inst;
            }
        }

        if (_target != noone) {
            global.pointer_input.consumed = true;
            with (_target) {
                event_perform(ev_mouse, 4);
            }
        }
        ds_list_destroy(_hits);

        if (!global.pointer_input.consumed) {
            // Ready-room input is coordinate-driven in its Step event. The
            // remaining legacy Global Left Pressed users are safe to replay.
            with (obj_craft_bg) event_perform(ev_mouse, 53);
            with (obj_info_island_bg) event_perform(ev_mouse, 53);
            with (obj_package_bg) event_perform(ev_mouse, 53);
            with (obj_player_character) event_perform(ev_mouse, 53);
            with (obj_text_input) event_perform(ev_mouse, 53);
        }
}
