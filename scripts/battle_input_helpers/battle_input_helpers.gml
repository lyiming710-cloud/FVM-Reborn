/// @desc Apply normal/2x speed, with optional 0.1x slowdown while a plant card is held.
function battle_apply_speed() {
    var _battle = instance_find(obj_battle, 0);
    if (_battle == noone) return;

    with (_battle) {
        var _target_fps = speed_up ? 120 : 60;

        // Slow only while a plant card is selected, and only when the HUD
        // "缓时" switch is enabled. Turning the switch off leaves normal/2x
        // speed untouched even while the card remains selected.
        if (card_hold_active && card_slow_enabled) {
            _target_fps = 6;
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
/// never inherits the optional 0.1x card-selection speed.
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