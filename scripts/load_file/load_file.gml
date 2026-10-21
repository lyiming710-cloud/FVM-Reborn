/// @function load_file(file_slot)
/// @desc 加载存档文件到全局变量global.save_data中
/// @param {real} file_slot 存档槽位
// Invalid saves stay on disk. Play with temporary read-only defaults instead.
function load_file_read_only_fallback(file_slot, reason) {
    global.save_read_only = true;
    global.save_read_only_slot = file_slot;
    reset_file(file_slot, false);
    show_debug_message("Unable to load save slot " + string(file_slot) + ": " + string(reason));
    show_message_async("存档读取失败。原存档未被修改，已使用临时数据进入游戏。\n当前存档槽位为只读，请先备份并修复原存档。");
    return false;
}

function load_file(file_slot) {
    global.save_read_only = false;
    global.save_read_only_slot = -1;
	var file_path = "saves/" + "save" + string(file_slot) + ".json"
    // 检查存档文件是否存在
    if (!file_exists(file_path)) {
        // 如果存档不存在，创建初始存档数据
        reset_file(file_slot)
        return true;
    }
    
    // 打开存档文件
    var file = file_text_open_read(file_path);
    if (file == -1) {
        return load_file_read_only_fallback(file_slot, "file cannot be opened");
    }
    
    // 读取文件内容
    var json_string = "";
    while (!file_text_eof(file)) {
        json_string += file_text_read_string(file);
        file_text_readln(file);
    }
    file_text_close(file);
    
    // 解析JSON字符串
    try {
        var _loaded = json_parse(json_string);
        if (!is_struct(_loaded)) {
            return load_file_read_only_fallback(file_slot, "save root is not an object");
        }
        if (!variable_struct_exists(_loaded, "player") || !is_struct(_loaded.player)) {
            return load_file_read_only_fallback(file_slot, "player record missing");
        }
        if (!variable_struct_exists(_loaded.player, "name") ||
            !variable_struct_exists(_loaded.player, "total_time") ||
            !variable_struct_exists(_loaded.player, "level") ||
            !variable_struct_exists(_loaded, "version")) {
            return load_file_read_only_fallback(file_slot, "required player fields missing");
        }
        // No save writes during schema verification or automatic migrations.
        global.save_read_only = true;
        global.save_read_only_slot = file_slot;
        global.save_data = _loaded;
		if global.save_data.version == 1.0 || global.save_data.version == "1.1"|| global.save_data.version == "1.2"|| global.save_data.version == "1.3"{
            // Old schemas need explicit migration, never silent deletion.
            return load_file_read_only_fallback(file_slot, "legacy format needs manual recovery");
        }
        else{
			if global.save_data.version == "1.4"{
				if array_get_index(global.save_data.completed_levels,"cocoa_island_night") != -1{
					unlock_weapon("double_water_gun")
				}
				if array_get_index(global.save_data.completed_levels,"abyss") != -1{
					unlock_card("chocolate_pult",0,0,5)
				}
				global.save_data.version = 1.5
			}
			if global.save_data.version == 1.5{
				global.save_data.attires = []
				global.save_data.version = 1.6
			}
			if global.save_data.version == 1.6{
				global.save_data.player.crown_version = "0.0.0"
				global.save_data.version = 1.7
			}
			if global.save_data.version == 1.7{
				global.save_data.equipped_cookbook = [[],[],[]]
				global.save_data.version = 1.8
			}
			if global.save_data.version == 1.8{
				if array_get_index(global.save_data.completed_levels,"cheese_castle") != -1{
					unlock_gem("holy_gem")
				}
				global.save_data.version = 1.9
			}
		}
        // Validate fields read by the menu and new game before permitting writes.
        if (!variable_struct_exists(global.save_data, "unlocked_cards") ||
            !variable_struct_exists(global.save_data, "unlocked_items") ||
            !variable_struct_exists(global.save_data, "equipped_items") ||
            !variable_struct_exists(global.save_data, "tasks") ||
            !variable_struct_exists(global.save_data, "equipped_cookbook") ||
            !variable_struct_exists(global.save_data, "saved_decks") ||
            !variable_struct_exists(global.save_data, "completed_levels") ||
            !variable_struct_exists(global.save_data, "inventory") ||
            !variable_struct_exists(global.save_data, "unlocked_weapons") ||
            !variable_struct_exists(global.save_data, "unlocked_gems")) {
            return load_file_read_only_fallback(file_slot, "save schema is incomplete");
        }
        if (!is_array(global.save_data.unlocked_cards) ||
            !is_array(global.save_data.tasks) ||
            !is_array(global.save_data.saved_decks) ||
            !is_array(global.save_data.equipped_cookbook) ||
            !is_array(global.save_data.completed_levels) ||
            !is_array(global.save_data.inventory) ||
            !is_array(global.save_data.unlocked_weapons) ||
            !is_array(global.save_data.unlocked_gems) ||
            !is_struct(global.save_data.unlocked_items) ||
            !is_struct(global.save_data.equipped_items)) {
            return load_file_read_only_fallback(file_slot, "save fields have invalid types");
        }
        global.save_read_only = false;
        global.save_read_only_slot = -1;
        show_debug_message("存档加载成功!");
        return true;
    } catch(e) {
        return load_file_read_only_fallback(file_slot, "parse or migration exception: " + string(e));
    }
}

function reset_file(file_slot, write_to_disk = true){
	//重置到初始存档
	global.save_data = {
            "version": 1.9,
            "player": {
                "gold": 0,
                "level": 1,
                "experience": 0,
				"name":"Player",
				"total_time":0,
				"crown_version":"0.0.0"
            },
            "unlocked_cards": [
                {"id": "small_fire", "level": 0, "shape": 0,"skill":0,"max_level":0,"max_shape":0},
				{"id": "toast_bread", "level": 0, "shape": 0,"skill":0,"max_level":0,"max_shape":0},
				{"id": "xiao_long_bao", "level": 0, "shape": 0,"skill":0,"max_level":0,"max_shape":0},
				{"id": "flour_sack", "level": 0, "shape": 0,"skill":0,"max_level":0,"max_shape":0}
            ],
            "completed_levels": [],
            "inventory": [],
            "unlocked_items": {
                "max_card_level": 0,
                "max_skill_level": 0,
                "max_gem_level": 0,
				"max_slot":5,
				"max_shape":[],
				"shovel":"normal",
				"elite_unlocked":false,
				"mario_mouse_killed":false,
				"arno_killed":false
            },
            "unlocked_weapons": [
                {"id": "long_bao_gun"}
            ],
			"unlocked_gems":[],
			"equipped_items":{
				"main_weapon":{
					"id":"long_bao_gun",
					"gems":[]
				},
				"secondary_weapon":{
					"id":"",
					"gems":[]
				},
				"super_weapon":{
					"id":"",
					"gems":[]
				}
			},
			"saved_decks":[
				{"name":"卡组1","card_id":[]},
				{"name":"卡组2","card_id":[]},
				{"name":"卡组3","card_id":[]},
				{"name":"卡组4","card_id":[]},
				{"name":"卡组5","card_id":[]},
				{"name":"卡组6","card_id":[]} 
			],
			"tasks":[
				{
					"id":"main_level_0",
					"progress":[0],
					"state":"new"
				},
				{
					"id":"card_upgrade_1",
					"progress":[0],
					"state":"new"
				},
				{
					"id":"flame_save_1",
					"progress":[0,0],
					"state":"new"
				},
				{
					"id":"perfect_challenge_1",
					"progress":[0,0,0],
					"state":"new"
				},
				{
					"id":"hardcore_challenge_1",
					"progress":[0,0,0],
					"state":"new"
				}
			],
			"completed_tasks":[],
			"attires":[],
			"equipped_cookbook":[[],[],[]]
        };
	if (write_to_disk) save_file(file_slot);
}