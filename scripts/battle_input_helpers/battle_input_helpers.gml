/// @desc Keep battle rendering/input at 120 FPS while changing only simulation tick rate.
function battle_apply_speed() {
    var _battle = instance_find(obj_battle, 0);
    if (_battle == noone) return;

    with (_battle) {
        // Physical frame rate is fixed during battle. 1x/2x/0.1x are handled
        // by the simulation scheduler instead of lowering the whole game FPS.
        game_set_speed(120, gamespeed_fps);

        var _logic_hz = speed_up ? 120 : 60;
        if (card_hold_active && card_slow_enabled) {
            _logic_hz = 6;
        }

        // Make a mode change take effect on the next physical frame.
        simulation_accumulator = 120 - _logic_hz;
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

/// @desc Return the card/shovel slot under a battle pointer position. A held
/// tool uses this to leave UI clicks for the clicked slot instead of treating
/// them as placement/removal clicks on the battlefield.
function battle_tool_slot_at_point(_pointer_x, _pointer_y) {
    var _card_count = instance_number(obj_card_slot);
    for (var _i = 0; _i < _card_count; _i++) {
        var _slot = instance_find(obj_card_slot, _i);
        if (_slot != noone &&
            point_in_rectangle(_pointer_x, _pointer_y,
                _slot.x - 50, _slot.y - 70, _slot.x + 50, _slot.y + 70)) {
            return _slot;
        }
    }

    var _shovel_slot = instance_find(obj_shovel_slot, 0);
    if (_shovel_slot != noone &&
        point_in_rectangle(_pointer_x, _pointer_y,
            _shovel_slot.x, _shovel_slot.y,
            _shovel_slot.x + 150, _shovel_slot.y + 150)) {
        return _shovel_slot;
    }

    return noone;
}

/// @desc Cancel any held card/shovel. Used by ESC and pause so the pause UI
/// never inherits the optional 0.1x card-selection simulation speed.
function battle_cancel_selected_tool() {
    if (variable_global_exists("selected_slot")) {
        var _slot = global.selected_slot;
        if (_slot != noone && instance_exists(_slot)) {
            _slot.is_selected = false;
            if (instance_exists(_slot.selected_preview)) instance_destroy(_slot.selected_preview);
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
