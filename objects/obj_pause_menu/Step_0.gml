// obj_pause_menu - Step Event
// Check whether a child modal is open.
submenu_open = instance_exists(obj_config_menu) || instance_exists(obj_quit_confirm) || instance_exists(obj_restart_confirm);

if (!submenu_open) {
    selected_button = -1;

    // Keep both iPad input paths alive. Magic Keyboard trackpad can arrive
    // through standard mouse_* while touchscreen taps arrive through
    // device_mouse_*. Never disable one path just because we are on iOS.
    var mx = mouse_x;
    var my = mouse_y;
    var _released = mouse_check_button_released(mb_left);

    if (os_type == os_ios) {
        for (var _d = 0; _d < 8; _d++) {
            if (device_mouse_check_button_released(_d, mb_left)) {
                mx = device_mouse_x(_d);
                my = device_mouse_y(_d);
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

                // Do not call mouse_clear() here on iOS. Clearing GameMaker's
                // synthetic mouse state during a modal transition can leave
                // touch/trackpad mapping without a fresh press edge after
                // attaching or detaching Magic Keyboard.
                audio_play_sound(snd_button,0,0);
            }
            break;
        }
    }
}
