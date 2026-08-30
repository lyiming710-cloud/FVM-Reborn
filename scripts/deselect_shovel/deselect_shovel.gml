// 函数: 取消选择铲子
function deselect_shovel() {
    with (obj_shovel_slot) {
        is_selected = false;
        hotkey_pressed = false;
    }
    global.selected_slot = noone;
    battle_end_tool_hold();
}
