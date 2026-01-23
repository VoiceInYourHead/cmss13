/mob
	var/collected_gold = 0
	var/circle_stacks = 0
	var/ice_stacks = 0
	var/time_fragments = 0

	var/image/golden_coins
	var/image/rejuv_coins
	var/image/cold_stacks
	var/image/time_stacks

/mob/proc/update_srd_statuses()

	golden_coins = image(icon = 'code/modules/fd_sword/icons/ui.dmi', icon_state = "gold", pixel_y = -10)
	rejuv_coins = image(icon = 'code/modules/fd_sword/icons/ui.dmi', icon_state = "rejuv", pixel_y = -20)
	cold_stacks = image(icon = 'code/modules/fd_sword/icons/ui.dmi', icon_state = "cold", pixel_x = -10, pixel_y = -10)
	time_stacks = image(icon = 'code/modules/fd_sword/icons/ui.dmi', icon_state = "time", pixel_x = 10, pixel_y = -10)

	overlays.Remove(golden_coins)
	overlays.Remove(rejuv_coins)
	overlays.Remove(cold_stacks)
	overlays.Remove(time_stacks)

	if(collected_gold > 0)
		golden_coins.maptext = SPAN_LANGCHAT("[collected_gold]")
		golden_coins.maptext_x = 6
		golden_coins.maptext_y = -7
		overlays.Add(golden_coins)
	if(ice_stacks > 0)
		cold_stacks.maptext = SPAN_LANGCHAT("[ice_stacks]")
		cold_stacks.maptext_x = -13
		cold_stacks.maptext_y = -7
		overlays.Add(cold_stacks)
	if(time_fragments > 0)
		time_stacks.maptext = SPAN_LANGCHAT("[time_fragments]")
		time_stacks.maptext_x = 13
		time_stacks.maptext_y = -7
		overlays.Add(time_stacks)
	if(circle_stacks > 0)
		rejuv_coins.maptext = SPAN_LANGCHAT("[circle_stacks]")
		rejuv_coins.maptext_x = 6
		rejuv_coins.maptext_y = -20
		overlays.Add(rejuv_coins)
