depth = -9900

// One pointer edge is produced per frame for touch and Magic Keyboard input.
// Consumers set `consumed` so the same physical tap cannot activate two UI
// paths. Never clear GameMaker's synthetic mouse state here.
ios_prev_down = array_create(8, false);
ios_last_focus = window_has_focus();
ios_virtual_esc_held = false;

// Battle clock state. Synthetic skip frames reuse the game's normal pause
// checks while leaving every instance active for placement/collision queries.
global.battle_skip_frame = false;
global.battle_simulation_tick = true;
global.battle_keep_paused_after_skip = false;

global.pointer_input = {
    pressed: false,
    released: false,
    native_pressed: false,
    device_only: false,
    consumed: false,
    device: -1,
    x: mouse_x,
    y: mouse_y,
    gui_x: 0,
    gui_y: 0
};

// Objects that actually own a local Left Pressed event. Filtering against
// this list prevents an invisible/decorative instance from swallowing a tap.
ios_clickable_objects = [
    obj_battlestart_button, obj_bomb_gem, obj_card_attire_select_btn,
    obj_card_edit_btn, obj_cateye_gem, obj_closecraft_btn,
    obj_closemenu_btn, obj_closepackage_btn, obj_config_btn,
    obj_craft_confirm_btn, obj_craft_select_btn, obj_deck_clear_btn,
    obj_deck_save_btn, obj_deck_select_btn, obj_difficulty_select_btn,
    obj_edit_btn, obj_edit_menu_button, obj_freeze_gem,
    obj_fullscreen_btn, obj_gem_edit_btn, obj_gem_edit_select_btn,
    obj_info_island_edit_btn, obj_info_island_edit_menu_btn,
    obj_info_island_select_btn, obj_key_bind_button, obj_laser_gem,
    obj_levelselect_button, obj_menu_select_btn, obj_mute_button,
    obj_packageselect_btn, obj_page_button, obj_player_attire_select_btn,
    obj_player_menu_btn, obj_readyroom_slot_btn, obj_save_slot_select_btn,
    obj_setting_toggle, obj_shop_buy_btn, obj_shop_page_btn,
    obj_shop_select_btn, obj_starlight_gem, obj_startgame_button,
    obj_task_claim_btn, obj_task_line_bg, obj_task_select_btn,
    obj_tower_cake_card_reward, obj_tower_cake_level_btn,
    obj_tower_cake_page_btn, obj_tower_cake_start_btn,
    obj_update_checker_btn, obj_volume_slider, obj_world_map_button,
    obj_world_map_choose_btn, obj_world_map_close_btn
];
