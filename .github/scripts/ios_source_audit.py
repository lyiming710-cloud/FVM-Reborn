#!/usr/bin/env python3
"""Static regression gates for the FVM-Reborn iOS/GameMaker port (version-agnostic)."""
from pathlib import Path
import re
import sys

root = Path(__file__).resolve().parents[2]
errors = []
warnings = []


def load(rel):
    p = root / rel
    if not p.is_file():
        errors.append(f"missing file: {rel}")
        return ""
    return p.read_text(encoding="utf-8-sig", errors="replace")


def expect(cond, detail):
    if not cond:
        errors.append(detail)


for ext in ("*.gml", "*.yy", "*.yyp"):
    for path in root.rglob(ext):
        if ".git" in path.parts:
            continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        if "<<<<<<<" in text or ">>>>>>>" in text:
            errors.append(f"unresolved merge conflict marker in {path.relative_to(root)}")

notice = load("objects/obj_notice_controller/Create_0.gml")
notice_step = load("objects/obj_notice_controller/Step_1.gml")
notice_gui = load("objects/obj_notice_controller/Draw_64.gml")
for token in (
    "ios_prev_down =",
    "ios_last_focus =",
    "ios_virtual_esc_held =",
    "global.pointer_input =",
    "global.battle_skip_frame =",
    "global.battle_simulation_tick =",
    "global.battle_keep_paused_after_skip =",
    "ios_clickable_objects =",
):
    expect(token in notice, f"persistent iOS controller missing initialization: {token}")
expect("instance_number(obj_notice_controller) > 1" in notice,
       "missing single-instance guard in obj_notice_controller")
expect("global.pointer_input.pressed" in notice_step,
       "persistent pointer sampling missing in obj_notice_controller/Step_1.gml")
expect("instance_exists(obj_battle)" in notice_gui and '"ESC"' in notice_gui,
       "persistent touch HUD controls missing in obj_notice_controller/Draw_64.gml")

file_manager = load("objects/obj_file_manager/Step_0.gml")
expect("if (os_type == os_windows)" in file_manager,
       "Windows-only IME/mouse hook not isolated by os_type == os_windows in obj_file_manager/Step_0.gml")
if "native_start_mouse_limit" in file_manager and "if (os_type == os_windows)" in file_manager:
    expect(
        file_manager.rfind("if (os_type == os_windows)") < file_manager.find("native_start_mouse_limit"),
        "native_start_mouse_limit appears outside os_type == os_windows guard",
    )

other3 = load("objects/obj_file_manager/Other_3.gml")
expect(
    re.search(r"if\s*\(\s*os_type\s*==\s*os_windows\s*&&\s*native_stop_mouse_limit", other3) is not None,
    "Windows-only native_stop_mouse_limit not guarded by os_type == os_windows in obj_file_manager/Other_3.gml",
)

player = load("objects/obj_player_character/Mouse_53.gml")
for token in ("var _click_x =", "var _click_y =", "instance_position(_click_x, _click_y"):
    expect(token in player, f"player placement pointer variable missing: {token}")
if "var _click_y =" in player and "instance_position(_click_x, _click_y" in player:
    expect(
        player.index("var _click_y =") < player.index("instance_position(_click_x, _click_y"),
        "player placement coordinates read before declaration",
    )

for rel in (
    "objects/obj_package_bg/Step_0.gml",
    "objects/obj_package_bg/Draw_73.gml",
    "objects/obj_craft_bg/Draw_73.gml",
    "objects/obj_battle_pause_manager/Draw_64.gml",
):
    expect(not (root / rel).exists(), f"retired duplicate UI event still exists: {rel}")

init = load("objects/obj_game_init/Create_0.gml")
m_ver = re.search(r'global\.game_version\s*=\s*"([^"]+)"', init)
expect(m_ver is not None, "could not parse global.game_version from objects/obj_game_init/Create_0.gml")
game_version = m_ver.group(1) if m_ver else "unknown"

ios_opts = load("options/ios/options_ios.yy")
expect('"option_ios_orientation_portrait":false' in ios_opts,
       "options_ios.yy should lock portrait orientation off for landscape gameplay")
m_min_ios = re.search(r'"option_ios_min_version"\s*:\s*"(\d+(?:\.\d+)?)"', ios_opts)
if m_min_ios:
    expect(float(m_min_ios.group(1)) >= 12.0,
           f"option_ios_min_version ({m_min_ios.group(1)}) should be >= 12.0")

yyp_files = list(root.glob("*.yyp"))
expect(len(yyp_files) > 0, "no .yyp project file found at repository root")
if yyp_files:
    yyp_text = yyp_files[0].read_text(encoding="utf-8", errors="replace")
    if '"customOptions":"BCN' in yyp_text:
        warnings.append("FVM-reborn.yyp uses BCN texture compression (CI will switch TextureGroups to bz2 for iOS)")

for w in warnings:
    print(f"iOS source audit WARN: {w}")

if errors:
    print("iOS source audit FAILED:")
    for problem in errors:
        print("  -", problem)
    sys.exit(1)

print(f"iOS source audit PASS: game_version={game_version}, platform isolation, touch HUD, and conflict checks OK")
