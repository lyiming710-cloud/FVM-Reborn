if !is_submenu_open{
	readyroom_refresh_card_scroll_metrics()
	y_offset = min(card_scroll_max,y_offset + 40)
	readyroom_refresh_card_scroll_metrics()
}
