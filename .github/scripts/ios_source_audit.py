#!/usr/bin/env python3
"""Static regression gates for the iOS/GameMaker port. Does not replace a device smoke test."""
from pathlib import Path
import re
import sys

root = Path(__file__).resolve().parents[2]
errors = []


def load(rel):
    p = root / rel
    if not p.is_file():
        errors.append(f"missing file: {rel}")
        return ""
    return p.read_text(encoding="utf-8-sig")


def expect(cond, detail):
    if not cond:
        errors.append(detail)


notice = load("objects/obj_notice_controller/Create_0.gml")
notice_step = load("objects/obj_notice_controller/Step_1.gml")
for token in ("ios_prev_down =", "ios_last_focus =", "ios_virtual_esc_held =",
              "global.pointer_input =", "global.battle_skip_frame =",
              "global.battle_simulation_tick =", "global.battle_keep_paused_after_skip =",
              "ios_clickable_objects ="):
    expect(token in notice, f"persistent iOS controller missing initialization: {token}")
expect("instance_number(obj_notice_controller) > 1" in notice,
       "missing upstream single-instance guard")
expect("global.pointer_input.pressed" in notice_step,
       "persistent pointer sampling removed")

file_manager = load("objects/obj_file_manager/Step_0.gml")
expect(file_manager.count("ime_tick++") == 1,
       "Windows IME heartbeat duplicated or missing")
expect("if (os_type == os_windows) {" in file_manager,
       "Windows-only IME and native mouse hook are not scoped")
expect(file_manager.rfind("if (os_type == os_windows) {") <
       file_manager.find("native_start_mouse_limit"),
       "Windows native mouse hook outside platform scope")

other = load("objects/obj_file_manager/Other_3.gml")
expect(re.search(r"if\s*\(\s*os_type\s*==\s*os_windows\s*&&\s*native_stop_mouse_limit", other) is not None,
       "Windows-only native hook may run on iOS during exit")

player = load("objects/obj_player_character/Mouse_53.gml")
for token in ("var _click_x =", "var _click_y =", "instance_position(_click_x, _click_y"):
    expect(token in player, f"player placement pointer value missing: {token}")
expect(player.index("var _click_y =") < player.index("instance_position(_click_x, _click_y"),
       "player placement coordinates are read before declaration")

ios = load("options/ios/options_ios.yy")
workflow = load(".github/workflows/build-ios-ipa.yml")
init = load("objects/obj_game_init/Create_0.gml")
expect('"option_ios_version":"3.0.1"' in ios, "iOS version must match upstream 3.0.1")
expect('"option_ios_build_number":30103' in ios, "iOS hotfix build must be 30103")
expect('global.game_version = "3.0.1"' in init, "game version out of sync")
expect('Set :CFBundleVersion 30103' in workflow, "IPA Info.plist build number out of sync")
expect('Set :CFBundleShortVersionString 3.0.1' in workflow, "IPA Info.plist game version out of sync")

# Check potentially merge-damaged leading-underscore local variables. Only
# inspect selected iOS/merge paths, because GML's object-scope fields and
# cross-event instance state cannot be fully inferred by a lexical scanner.
target_paths = ["objects/obj_readyroom_manager/Step_0.gml","objects/obj_card_slot/Step_0.gml","objects/obj_notice_controller/Step_1.gml","objects/obj_battle_pause_manager/Step_2.gml","objects/obj_readyroom_manager/Create_0.gml","scripts/battle_input_helpers/battle_input_helpers.gml","objects/obj_quit_confirm/Step_0.gml","objects/obj_package_bg/Step_0.gml","objects/obj_battle_pause_manager/Draw_64.gml","objects/obj_cookbook_bg/Step_0.gml","objects/obj_file_manager/Step_0.gml","objects/obj_flour_sack/Alarm_0.gml","objects/obj_pause_menu/Step_0.gml","objects/obj_notice_controller/Create_0.gml","objects/obj_shovel_slot/Step_0.gml","objects/obj_coin/Step_0.gml","objects/obj_restart_confirm/Step_0.gml","objects/obj_package_bg/Draw_73.gml","objects/obj_battle/Step_0.gml","objects/obj_notice_controller/Draw_64.gml","objects/obj_card_slot/Create_0.gml","objects/obj_craft_bg/Draw_73.gml","objects/obj_platform/Step_2.gml","objects/obj_readyroom_manager/Draw_0.gml","scripts/select_shovel/select_shovel.gml","objects/obj_card_preview/Step_0.gml","objects/obj_cookbook_bg/Create_0.gml","objects/obj_edit_menu_button/Mouse_4.gml","objects/obj_game_init/Create_0.gml","objects/obj_battle/CleanUp_0.gml","objects/obj_battle/Create_0.gml","objects/obj_flour_sack/Step_0.gml","scripts/deselect_shovel/deselect_shovel.gml","objects/obj_level_preview/Step_0.gml","objects/obj_package_bg/Create_0.gml","objects/obj_battle_music_controller/Step_0.gml","objects/obj_craft_bg/Create_0.gml","objects/LaboratoryGUI/Create_0.gml","objects/obj_flour_sack/Alarm_1.gml","objects/obj_battle_pause_manager/Create_0.gml","objects/obj_player_character/Mouse_53.gml"]
for rel in target_paths:
    source = load(rel)
    masked = re.sub(r'//[^\n]*|/\*[\s\S]*?\*/', '', source)
    masked = re.sub(r'"(?:\\.|[^"\\])*"|' + r"'(?:\\.|[^'\\])*'", '""', masked)
    defined = set(re.findall(r'\b(?:var|let|const)\s+(_[A-Za-z]\w*)', masked))
    for match in re.finditer(r'\bfunction\s+[A-Za-z_]\w*\s*\(([^)]*)\)', masked):
        defined.update(p.strip() for p in match.group(1).split(','))
    used = set(re.findall(r'\b_[A-Za-z]\w*\b', masked))
    missing = sorted(name for name in used
                     if name not in defined
                     and f"function {name}" not in masked
                     and f".{name}" not in masked)
    if missing:
        errors.append(f"{rel}: possibly undeclared local(s): {', '.join(missing)}")

# Check 3.0.1 additions before GameMaker exports an iOS app.
for icon in ("spr_mermaid_mary_icon", "spr_machine_shark_icon", "spr_lobster_knight_icon", "spr_electric_jellyfish_icon", "spr_travel_record_icon"):
    expect((root / "sprites" / icon / (icon + ".yy")).is_file(), f"missing v3.0.1 boss icon: {icon}")
bosses = load("scripts/boss_init/boss_init.gml")
expect("spr_mermaid_mary_icon" in bosses and "spr_machine_shark_icon" in bosses, "upstream v3.0.1 boss icon registrations missing")
recipes = load("scripts/cookbook_init/cookbook_init.gml")
expect('"camp_stew"' in recipes, "upstream v3.0.1 unique camp stew recipe ID missing")
shop = load("objects/obj_camp_shop_bg/Create_0.gml")
expect(".max_shape >= " in shop, "upstream v3.0.1 purchased career guard missing")

# Non-destructive fallback for invalid and legacy-format save files.
loader = load("scripts/load_file/load_file.gml")
saver = load("scripts/save_file/save_file.gml")
startup = load("objects/obj_game_init/Other_2.gml")
expect("function load_file_read_only_fallback(" in loader, "missing save load fallback")
expect("reset_file(file_slot, false)" in loader, "recovery must initialize in memory only")
expect("function reset_file(file_slot, write_to_disk = true)" in loader,
       "save initializer must have non-persisting mode")
expect("if (write_to_disk) save_file(file_slot);" in loader, "save initializer writes unconditionally")
expect("legacy format needs manual recovery" in loader, "legacy saves may be erased on startup")
expect("global.save_read_only_slot = file_slot;\n        global.save_data = _loaded;" in loader,
       "save writes must be blocked until migration and validation finish")
expect("save schema is incomplete" in loader and "save fields have invalid types" in loader,
       "loaded save schema must be checked")
expect("global.save_read_only_slot == file_slot" in saver and
       saver.index("global.save_read_only_slot == file_slot") < saver.index("file_text_open_write(file_path)"),
       "read-only save lock is not enforced before opening original file")
expect("var _save_loaded = load_file(global.save_slot)" in startup,
       "startup does not handle recovery mode")

# The v3.0.1 upstream camp-night hard level had one trailing NUL.
import json
level = root / "datafiles/level_data/camp/nut_platform_night_hard.json"
try:
    raw = level.read_bytes()
    expect(b"\x00" not in raw, "camp night hard level contains NUL")
    decoded = json.loads(raw)
    expect(isinstance(decoded, dict) and isinstance(decoded.get("map"), list)
           and len(decoded["map"]) > 0, "camp night hard level grid missing")
except (ValueError, OSError, UnicodeError) as exc:
    errors.append("camp night hard JSON invalid: " + str(exc))

# UI synchronization regressions: do not draw a second scrollbar when
# upstream already owns backpack/craft scrolling.
package_draw = load("objects/obj_package_bg/Draw_0.gml")
craft_draw = load("objects/obj_craft_bg/Draw_0.gml")
for screen, code in (("backpack", package_draw), ("craft", craft_draw)):
    expect("spr_info_island_scroll_bar" in code,
           f"missing upstream-native {screen} scrollbar")
for rel in ("objects/obj_package_bg/Step_0.gml",
            "objects/obj_package_bg/Draw_73.gml",
            "objects/obj_craft_bg/Draw_73.gml",
            "objects/obj_battle_pause_manager/Draw_64.gml"):
    expect(not (root / rel).exists(), f"duplicate or shadowed UI event remains: {rel}")
package_create = load("objects/obj_package_bg/Create_0.gml")
craft_create = load("objects/obj_craft_bg/Create_0.gml")
expect("package_scrollbar_dragging" not in package_create, "backpack duplicate scrollbar state")
expect("craft_scrollbar_dragging" not in craft_create, "craft duplicate scrollbar state")
for rel, event_type, event_num, should_exist in (
    ("objects/obj_package_bg/obj_package_bg.yy", 3, 0, False),
    ("objects/obj_package_bg/obj_package_bg.yy", 8, 73, False),
    ("objects/obj_craft_bg/obj_craft_bg.yy", 8, 73, False),
    ("objects/obj_notice_controller/obj_notice_controller.yy", 8, 64, True),
    ("objects/obj_battle_pause_manager/obj_battle_pause_manager.yy", 8, 64, False),
):
    source = load(rel)
    event = f'"eventNum":{event_num},"eventType":{event_type},'
    expect((event in source) == should_exist,
           f"unexpected event registration {rel}: {event}")
gui = load("objects/obj_notice_controller/Draw_64.gml")
expect("instance_exists(obj_battle)" in gui and
       '"ESC"' in gui and '"暂停"' in gui and '"缓时 开"' in gui,
       "persistent GUI renderer must contain ESC/pause/speed/slow controls")
cookbook_render = load("objects/obj_cookbook_bg/Draw_0.gml")
cookbook_step = load("objects/obj_cookbook_bg/Step_0.gml")
expect("cookbook_scrollbar_x" in cookbook_render and
       cookbook_render.index("cookbook_scrollbar_x") <
       cookbook_render.index("panel_anim_end_slide(id, 260)"),
       "cookbook scrollbar missing from animated draw pass")
expect("cookbook_scrollbar_dragging" in cookbook_step,
       "cookbook touch scrolling unexpectedly removed")
expect("panel_anim_end_slide(id, 260)" in cookbook_render,
       "cookbook panel slide compositor unexpectedly removed")

# Ready-room upstream scrollbar must share limits and coordinates with iPad touch.
ready_draw = load("objects/obj_readyroom_manager/Draw_0.gml")
ready_step = load("objects/obj_readyroom_manager/Step_0.gml")
ready_create = load("objects/obj_readyroom_manager/Create_0.gml")
expect(ready_draw.count("draw_sprite_ext(spr_info_island_scroll_bar") == 1,
       "ready-room duplicate native scrollbar draw")
expect("card_scrollbar_x, card_scrollbar_thumb_y" in ready_draw,
       "ready-room native scrollbar and touch hitbox coordinates diverge")
expect("var _sb_max = 96 * slot_rows - 515" not in ready_draw,
       "ready-room upstream scrollbar limit conflicts with iPad content scroll")
expect("y_offset_target = y_offset" in ready_step and
       "y_offset_target = y_offset" in ready_draw,
       "dragging does not update shared scroll target")
expect("sprite_get_height(spr_info_island_scroll_bar) * 2.2" in ready_create,
       "ready-room touch thumb height differs from visible upstream sprite")
for path in ("objects/obj_readyroom_manager/Mouse_60.gml",
             "objects/obj_readyroom_manager/Mouse_61.gml"):
    wheel = load(path)
    expect("card_scroll_max" in wheel and "readyroom_refresh_card_scroll_metrics()" in wheel,
           f"ready-room mouse wheel limit not synchronized: {path}")

if errors:
    print("iOS source audit FAILED:")
    for problem in errors:
        print("  -", problem)
    sys.exit(1)
print(f"iOS source audit PASS: initialization, platform isolation, 3.0.1/30103, {len(target_paths)} event scripts")
