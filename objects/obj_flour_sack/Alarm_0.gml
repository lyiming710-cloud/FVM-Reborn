// Safety guard: if this attack alarm is ever delivered during a real or
// synthetic pause frame, defer it before changing any combat state.
if (global.is_paused) {
    alarm[0] = 1;
    exit;
}

// alarm[0]事件 - 实际攻击执行
// 摧毁范围内敌人
var _x = x;
var _y = y;
var _range = 120;
if shape == 1{
	_range = 200
}
else if shape == 2{
	_range = 400
}
with (obj_enemy_parent) {
	if (can_hit(other.target_type,target_type) && point_distance(x, y, _x, _y) < _range && grid_row == other.grid_row) {
	    if (immune_to_ash) {
	        // 对免疫灰烬的敌人只造成伤害
	        hp -= other.atk;
			event_user(0)
	        // 受伤效果
	        //effect_create_above(effect_smoke, x, y, 1, c_gray);
	    } else {
	        // 直接摧毁非免疫敌人
	        instance_destroy();
	        // 摧毁效果
	        //effect_create_above(ef_explosion, x, y, 1, c_yellow);
	    }
	}
}

// 播放倭瓜攻击效果
//effect_create_above(ef_explosion, x, y, 2, c_white);

// 下砸只结算和播放一次。此前这里还会等待 alarm[1] 约 41 tick，
// 水面目标可能在这段滞留期内让攻击状态重复触发，造成连续下砸音效。
audio_play_sound(snd_flour_sack, 0, false);

chspeed = 0
cvspeed = 0
grid_row = origin_row
grid_col = origin_col
instance_destroy()
