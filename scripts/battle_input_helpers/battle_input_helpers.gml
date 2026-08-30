/// @desc Restore the effective battle speed without losing the player's
/// normal, 2x or manual 0.5x selection.
function battle_apply_speed() {
    var _battle = instance_find(obj_battle, 0);
    if (_battle == noone) return;

    with (_battle) {
        var _target_fps = 60;
        if (card_hold_active) {
            // Keep pointer input responsive while making the battlefield
            // effectively stop as a card or the shovel is being aimed.
            _target_fps = 6;
        }
        else if (slow_time) {
            _target_fps = 30;
        }
        else if (speed_up) {
            _target_fps = 120;
        }
        game_set_speed(_target_fps, gamespeed_fps);
    }
}

function battle_begin_tool_hold() {
    var _battle = instance_find(obj_battle, 0);
    if (_battle == noone) return;
    _battle.card_hold_active = true;
    battle_apply_speed();
}

function battle_end_tool_hold() {
    var _battle = instance_find(obj_battle, 0);
    if (_battle == noone) return;
    _battle.card_hold_active = false;
    battle_apply_speed();
}

/// @desc Cancel any held card/shovel. Used by ESC and pause so the pause UI
/// never inherits the 0.1x aiming speed.
function battle_cancel_selected_tool() {
    if (variable_global_exists("selected_slot")) {
        var _slot = global.selected_slot;
        if (_slot != noone && instance_exists(_slot)) {
            _slot.is_selected = false;
            if (instance_exists(_slot.selected_preview)) {
                instance_destroy(_slot.selected_preview);
            }
            _slot.selected_preview = noone;
        }
        global.selected_slot = noone;
    }

    with (obj_shovel_slot) {
        is_selected = false;
        hotkey_pressed = false;
    }
    battle_end_tool_hold();
}
