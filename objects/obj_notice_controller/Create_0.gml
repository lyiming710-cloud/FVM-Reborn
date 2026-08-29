depth = -9900

// iPadOS input bridge state.
// GameMaker's Mouse events can desynchronise when switching between touch and
// an attached trackpad/keyboard. Track device state independently so we can
// recover only when the native mouse layer misses a press.
ios_prev_device0_down = false;
ios_prev_device1_down = false;
ios_mouse_mismatch_frames = 0;
ios_last_focus = window_has_focus();
