image_xscale = 0.9
image_yscale = 0.9
image_speed = 0

is_submenu_opened = false
button_select = -1
target_cookbook_index = -1
y_offset = 0

current_cookbook_list = []

// The upstream cookbook list only supports mouse-wheel paging. Keep that
// behavior, but also expose a draggable scrollbar so touch-only iPad users
// can reach entries beyond the first six without changing list-button taps.
cookbook_scrollbar_dragging = false
cookbook_scrollbar_grab_offset = 0
// The background already reserves a narrow groove immediately to the right
// of the recipe list. Keep the thumb inside that groove instead of the detail pane.
cookbook_scrollbar_x = x - 20
cookbook_scrollbar_width = 18
cookbook_scrollbar_top = y - 190
cookbook_scrollbar_bottom = y + 405

instance_create_depth(x+710,y-410,depth-1,obj_closecookbook_btn)

var btn1 = instance_create_depth(x-376,y-335,depth-5,obj_cookbook_select_btn)
btn1.btn_index = 0
btn1.btn_text = "上等佳肴"
var btn2 = instance_create_depth(x-376,y-280,depth-5,obj_cookbook_select_btn)
btn2.btn_index = 1
btn2.btn_text = "秘制佳肴"
var btn3 = instance_create_depth(x-376,y-225,depth-5,obj_cookbook_select_btn)
btn3.btn_index = 2
btn3.btn_text = "极品佳肴"


function refresh_cookbook_list(){
	instance_destroy(obj_cookbook_list_btn)
	//target_task_index = -1
	current_cookbook_list = []
	var cookbook_list = global.cookbook_list
	for(var i = 0;i < array_length(cookbook_list);i++){
		var cookbook_data = get_cookbook_data(cookbook_list[i])
		if (button_select == cookbook_data.rank){
			array_push(current_cookbook_list,cookbook_list[i])
			var inst = instance_create_depth(x-376,y-145+101*(array_length(current_cookbook_list)-1),depth-1,obj_cookbook_list_btn)
			inst.btn_index = array_length(current_cookbook_list)-1
			inst.cookbook_title = cookbook_data.title
			inst.spr_index = cookbook_data.icon
			inst.desc = cookbook_data.tiny_desc
			inst.cookbook_id = global.cookbook_list[i]
			inst.cookbook_rank = button_select
		}
	}
}
