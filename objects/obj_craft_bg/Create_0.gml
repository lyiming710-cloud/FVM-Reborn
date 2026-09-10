image_xscale = 0.9
image_yscale = 0.9

is_submenu_opened = false
button_select = 0

instance_create_depth(x+785,y-466,depth-1,obj_closecraft_btn)
instance_create_depth(x-305,y+220,depth-1,obj_craft_confirm_btn)

var btn1 = instance_create_depth(x-661,y-50,depth-1,obj_craft_select_btn)
btn1.button_index = 0
btn1.text_spr = spr_craft_card_text
var btn2 = instance_create_depth(x-661,y+100,depth-1,obj_craft_select_btn)
btn2.button_index = 1
btn2.text_spr = spr_craft_gem_text

card_material_id_list = ["natural_spices","secret_spices","royal_spices","clover_1","clover_2","clover_3","clover_4"]
gem_material_id_list = ["less_crystal","middle_crystal","advanced_crystal"]


hover_card_index = -1
hover_gem_index = -1
close_timer = -1

y_offset = 0
card_surface = -1

// The card enhancement surface is 600x815 and ends at x+754. Put the touch
// scrollbar immediately outside it so the seventh card column remains clickable.
craft_scrollbar_dragging = false
craft_scrollbar_grab_offset = 0
craft_scrollbar_x = x + 762
craft_scrollbar_width = 16
craft_scrollbar_top = y - 369
craft_scrollbar_bottom = y + 446

current_uprade_target_id = ""

spices_use_order = ["natural_spices","secret_spices","royal_spices"]
clover_use_order = ["clover_1","clover_2","clover_3","clover_4"]
crystal_use_order = ["less_crystal","middle_crystal","advanced_crystal"]
