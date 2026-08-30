// Safety guard: if this attack alarm is ever delivered during a real or
// synthetic pause frame, defer it before changing any combat state.
if (global.is_paused) {
    alarm[0] = 1;
    exit;
}

// 水面附属效果可能让攻击事件再次进入；已经结算过时不再伤害或播放声音。
if (impact_resolved) {
    exit;
}
impact_resolved = true

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

// 下砸只结算和播放一次，随后保留压扁模型约 41 tick。
audio_play_sound(snd_flour_sack, 0, false);

alarm[1] = 41
chspeed = 0
cvspeed = 0
