// Synthetic pause lasts through Step/End Step only. Restore the real pause
// state before drawing so visuals and GUI still refresh at the full 120 FPS.
if (global.battle_skip_frame) {
    global.is_paused = global.battle_keep_paused_after_skip;
    global.battle_skip_frame = false;
    global.battle_keep_paused_after_skip = false;
}
