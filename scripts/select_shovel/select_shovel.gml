// 函数: 选择铲子
function select_shovel() {
    // 取消任何选中的植物卡槽
    if (global.selected_slot != noone) {
        with (global.selected_slot) {
            deselect_slot();
        }
    }

    is_selected = true;
    // 设置全局选中为铲子。缓时开关只作用于植物卡片，不作用于铲子。
    global.selected_slot = noone;
}
