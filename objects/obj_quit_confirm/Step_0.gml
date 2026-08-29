// Modal Step Event
selected_button = -1;

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var _released = mouse_check_button_released(mb_left);

if (os_type == os_ios) {
    _released = false;
    for (var _d = 0; _d < 4; _d++) {
        if (device_mouse_check_button_released(_d, mb_left)) {
            mx = device_mouse_x_to_gui(_d);
            my = device_mouse_y_to_gui(_d);
            _released = true;
            break;
        }
    }
}

for (var i = 0; i < array_length(buttons); i++) {
    var btn = buttons[i];
    var btn_x = x + btn[0];
    var btn_y = y + 70;
    var btn_width = btn[2];
    var btn_height = btn[3];

    if (point_in_rectangle(mx, my,
        btn_x - btn_width/2, btn_y - btn_height/2,
        btn_x + btn_width/2, btn_y + btn_height/2))
    {
        selected_button = i;

        if (_released) {
            switch (i) {
                case 1: // Cancel
                    if (instance_exists(obj_player_info_ui)) {
                        obj_player_info_ui.menu_type = 0;
                    }
                    if (instance_exists(obj_world_map_button)) {
                        obj_world_map_button.world_map = 0;
                    }
                    if (os_type == os_ios) {
                        mouse_clear(mb_any);
                    }
                    instance_destroy();
                    break;

                case 0: // Confirm
                    if (instance_exists(obj_player_info_ui)) {
                        obj_player_info_ui.menu_type = 0;
                    }
                    if (instance_exists(obj_world_map_button)) {
                        obj_world_map_button.world_map = 0;
                    }
                    if (os_type == os_ios) {
                        mouse_clear(mb_any);
                    }
                    if (global.menu_screen) {
                        game_end();
                    }
                    else {
                        if (global.map_id == "tower_cake" || global.map_id == "delicious_town") {
                            global.map_id = "delicious_island";
                            global.map_name = "美味岛";
                        }
                        global.menu_screen = true;
                        global.gui_stack.pop();
                    }
                    break;
            }
            audio_play_sound(snd_button,0,0);
        }
        break;
    }
}

// Consume ESC locally if this modal gets it before its parent manager.
if (keyboard_check_pressed(vk_escape)) {
    keyboard_clear(vk_escape);
    if (os_type == os_ios) {
        mouse_clear(mb_any);
    }
    instance_destroy();
}
