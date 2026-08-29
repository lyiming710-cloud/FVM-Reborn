
if (not audio_is_playing(readyroom_music)) {
    audio_stop_sound(readyroom_music);
    audio_play_sound(readyroom_music, 0, 0);
}

// Always derive the lock from real instances before reading it.
is_submenu_open = instance_exists(obj_quit_confirm) || instance_exists(obj_level_preview);

if (keyboard_check_pressed(vk_escape)) {
    // Close the current top-level ready-room modal first.
    if (instance_exists(obj_level_preview)) {
        instance_destroy(obj_level_preview);
    }
    else if (instance_exists(obj_quit_confirm)) {
        instance_destroy(obj_quit_confirm);
    }
    else {
        instance_create_depth(room_width / 2, room_height / 2, -100, obj_quit_confirm);
    }

    // Consume this ESC so obj_quit_confirm/obj_level_preview cannot process
    // the exact same edge and leave a ghost modal behind.
    keyboard_clear(vk_escape);

    if (os_type == os_ios) {
        mouse_clear(mb_any);
    }
}

// Recompute immediately after creation/destruction; never carry a stale lock
// into the next input frame.
is_submenu_open = instance_exists(obj_quit_confirm) || instance_exists(obj_level_preview);
