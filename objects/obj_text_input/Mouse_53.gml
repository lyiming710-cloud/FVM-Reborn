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
