depth = -9900

// iPadOS pointer fallback state.
// Track GameMaker device_mouse slots without clearing the engine's synthetic
// mouse state. This lets touch and Magic Keyboard trackpad coexist safely.
ios_prev_down = array_create(8, false);
ios_last_focus = window_has_focus();
