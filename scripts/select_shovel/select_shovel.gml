// 函数: 选择铲子
function select_shovel() {
    // 取消任何选中的植物卡槽
    if (global.selected_slot != noone) {
        with (global.selected_slot) {
            deselect_slot();
        }
    }

    is_selected = true;
    // 铲子与植物卡片共享同一套选取缓时。
    global.selected_slot = noone;
    battle_begin_tool_hold();
}
