// obj_pause_menu - Step Event
// Check whether a child modal is open.
submenu_open = instance_exists(obj_config_menu) || instance_exists(obj_quit_confirm) || instance_exists(obj_restart_confirm);

if (!submenu_open) {
    selected_button = -1;

    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    var _released = mouse_check_button_released(mb_left);

    // On iOS, use the device/touch release path directly. This avoids mixing
    // device coordinates with the separate standard mouse release state.
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
        var btn_x = menu_x + btn[0];
        var btn_y = menu_y + 120 + btn[4];
        var btn_width = btn[2];
        var btn_height = btn[3];

        if (point_in_rectangle(mx, my,
            btn_x - btn_width/2, btn_y - btn_height/2,
            btn_x + btn_width/2, btn_y + btn_height/2))
        {
            selected_button = i;

            if (_released) {
                switch (i) {
                    case 0: // Continue
                        instance_destroy();
                        global.is_paused = false;
                        global.show_menu = false;
                        break;

                    case 1: // Settings
                        instance_create_depth(menu_x, menu_y, depth-1, obj_config_menu);
                        break;

                    case 2: // Quit
                        instance_create_depth(menu_x, menu_y, depth-1, obj_quit_confirm);
                        break;

                    case 3: // Restart
                        instance_create_depth(menu_x, menu_y, depth-1, obj_restart_confirm);
                        break;
                }

                if (os_type == os_ios) {
                    mouse_clear(mb_any);
                }
                audio_play_sound(snd_button,0,0);
            }
            break;
        }
    }
}
