// obj_text_input 全局鼠标按下事件
// 检查是否点击了输入框
var _click_x = (os_type == os_ios && global.pointer_input.device_only)
    ? global.pointer_input.x : mouse_x;
var _click_y = (os_type == os_ios && global.pointer_input.device_only)
    ? global.pointer_input.y : mouse_y;
if (point_in_rectangle(_click_x, _click_y, x, y, x + width, y + height)) {
    active = true;
} else {
    active = false;
}
// 输入法的放开/恢复不在这里做：本事件是全局鼠标事件，多输入框时各实例执行顺序不确定，
// 统一由 obj_file_manager 的 Step 依据所有输入框的 active 状态处理（见那里的 v7.3 注释）。