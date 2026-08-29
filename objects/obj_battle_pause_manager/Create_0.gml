// obj_battle_pause_manager - Create Event
global.is_paused = false;
global.show_menu = false; // 新增变量控制菜单显示
depth = -3000

settlement = false
first_complete = false

slot_unlock_level_id_list = ["cookie_island","salad_island_land","salad_island_water","champagne_island_land","champagne_island_water","cocoa_island_daytime","curry_island_night"]

// Touch HUD virtual key state.
virtual_pause_pressed = false;
virtual_esc_pressed = false;
// Track several touch/pointer device slots. iPadOS may remap the active
// pointer slot when Magic Keyboard is attached/detached.
ios_hud_prev_down = array_create(8, false);
