// ESC handling is intentionally centralised in obj_battle_pause_manager.
// Keeping a second ESC handler here caused the same keypress to close and
// immediately recreate the pause modal depending on instance execution order.
