if global.lose_focus_pause{
	if !window_has_focus(){
		audio_pause_all()
		audio_pause = true
	}
	else{
		if audio_pause{
			audio_resume_all()
			audio_pause = false
		}
	}
}

// 输入法屏蔽心跳仅用于 Windows。
// obj_file_manager 是持久对象，跨房间存活；iOS 不提供 native_disable_ime，
// 因此必须先做平台分支，避免在 iOS Step 事件中读取不存在的扩展函数。
if (os_type == os_windows) {
    if (!variable_instance_exists(id, "ime_tick")) {
        ime_tick = 0;
    }
    ime_tick++;
    if (ime_tick >= 60) {
        ime_tick = 0;
        if (global.ime_block && native_disable_ime != undefined) {
            native_disable_ime(window_handle());
        }
    }
}
