// Safety guard: battle alarms are normally frozen in Begin Step before
// GameMaker decrements them. If this alarm is ever reached on a paused frame,
// defer it until the next real simulation tick.
if (global.is_paused) {
    alarm[1] = 1;
    exit;
}

grid_row = origin_row
grid_col = origin_col
instance_destroy();