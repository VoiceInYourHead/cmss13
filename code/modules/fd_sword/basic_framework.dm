#define SPAN_STYLE(style, X) "<span style=\"[style]\">[X]</span>"
#define SPAN_COLOR(color, text) SPAN_STYLE("color: [color]", "[text]")
#define SPAN_SIZE(size, text) SPAN_STYLE("font-size: [size]", "[text]")
#define FONT_SMALL(X) SPAN_SIZE("10px", "[X]")
#define FONT_NORMAL(X) SPAN_SIZE("13px", "[X]")
#define FONT_LARGE(X) SPAN_SIZE("16px", "[X]")

/matrix/proc/Update(scale_x, scale_y, rotation, offset_x, offset_y, list/others)
	var/x_null = isnull(scale_x)
	var/y_null = isnull(scale_y)
	if (!x_null || !y_null)
		Scale(x_null ? 1 : scale_x, y_null ? 1 : scale_y)
	if (!isnull(rotation))
		Turn(rotation)
	if (offset_x || offset_y)
		Translate(offset_x || 0, offset_y || 0)
	if (islist(others))
		for (var/other in others)
			Multiply(other)
	else if (others)
		Multiply(others)
	return src

//// HUD ////
/datum/hud
	var/atom/movable/screen/sword_info/sword_info

	var/atom/movable/screen/sword_info/traverse_info/traverse_info
	var/atom/movable/screen/sword_info/ranged_info/ranged_info
	var/atom/movable/screen/sword_info/aoe_info/aoe_info
	var/atom/movable/screen/sword_info/targeted_info/targeted_info

	var/atom/movable/screen/sword_usage_stat/sword_usage_stat
	var/atom/movable/screen/sword_limit_stat/sword_limit_stat

/datum/hud/human/proc/draw_sword_info(datum/custom_hud/ui_datum)
	sword_info = new /atom/movable/screen/sword_info()
	sword_info.icon = ui_datum.ui_style_icon
	sword_info.screen_loc = "CENTER,CENTER"
	infodisplay += sword_info

/datum/hud/human/proc/traverse_info(datum/custom_hud/ui_datum)
	traverse_info = new /atom/movable/screen/sword_info/traverse_info()
	traverse_info.icon = ui_datum.ui_style_icon
	traverse_info.screen_loc = "CENTER,CENTER"
	infodisplay += traverse_info

/datum/hud/human/proc/ranged_info(datum/custom_hud/ui_datum)
	ranged_info = new /atom/movable/screen/sword_info/ranged_info()
	ranged_info.icon = ui_datum.ui_style_icon
	ranged_info.screen_loc = "CENTER,CENTER"
	infodisplay += ranged_info

/datum/hud/human/proc/aoe_info(datum/custom_hud/ui_datum)
	aoe_info = new /atom/movable/screen/sword_info/aoe_info()
	aoe_info.icon = ui_datum.ui_style_icon
	aoe_info.screen_loc = "CENTER,CENTER"
	infodisplay += aoe_info

/datum/hud/human/proc/targeted_info(datum/custom_hud/ui_datum)
	targeted_info = new /atom/movable/screen/sword_info/targeted_info()
	targeted_info.icon = ui_datum.ui_style_icon
	targeted_info.screen_loc = "CENTER,CENTER"
	infodisplay += targeted_info

/atom/movable/screen/sword_info
	icon_state = "info_dump"
	alpha = 0
	mouse_opacity = FALSE
	var/mother_button = TRUE
	var/hide = FALSE

	var/opened = FALSE
	var/prepare_offset = 0

/atom/movable/screen/sword_info/proc/change_visibility(mob/living/carbon/human/user)

	if(mother_button)
		if(user && user.hud_used && user.sword_combat_active)
			mouse_opacity = TRUE
			animate(src, alpha = 255, time = 0.5 SECONDS)
			return 1
		if(user && user.hud_used && !user.sword_combat_active)
			mouse_opacity = FALSE
			animate(src, alpha = 0, time = 0.5 SECONDS)
			return 1

	if(!mother_button)
		if(user && user.hud_used)
			if(!user.sword_combat_active)
				mouse_opacity = FALSE
				hide = TRUE
				animate(src, alpha = 0, time = 0.5 SECONDS)
				animate(src, transform = matrix(0, 0, MATRIX_TRANSLATE), time = 0.5 SECONDS, easing = SINE_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
				return 1
			if(hide)
				mouse_opacity = TRUE
				hide = FALSE
				animate(src, alpha = 255, time = 0.5 SECONDS)
				animate(src, transform = matrix(prepare_offset, 0, MATRIX_TRANSLATE), time = 0.5 SECONDS, easing = SINE_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
				return 1
			if(!hide)
				mouse_opacity = FALSE
				hide = TRUE
				animate(src, alpha = 0, time = 0.5 SECONDS)
				animate(src, transform = matrix(0, 0, MATRIX_TRANSLATE), time = 0.5 SECONDS, easing = SINE_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
				return 1

/atom/movable/screen/sword_info/clicked(mob/living/carbon/human/user, list/mods)
	if (..())
		return 1

	if(opened)
		playsound_client(user.client, 'code/modules/fd_sword/sounds/009_MainUI_DownPanel_a_v1.wav', user, 50, 0)
	if(!opened)
		playsound_client(user.client, 'code/modules/fd_sword/sounds/010_MainUI_UpPanel_a_v1.wav', user, 50, 0)

	if(user && user.hud_used && user.sword_combat_active)
		if(mother_button)
			user.hud_used.traverse_info.change_visibility(user)
			user.hud_used.ranged_info.change_visibility(user)
			user.hud_used.aoe_info.change_visibility(user)
			user.hud_used.targeted_info.change_visibility(user)

			if(!opened)
				opened = TRUE
				return 1
			if(opened)
				opened = FALSE
				return 1

/atom/movable/screen/sword_info/traverse_info
	icon_state = "info_traverse"
	alpha = 0
	mother_button = FALSE
	hide = TRUE

	prepare_offset = -15

/atom/movable/screen/sword_info/traverse_info/MouseEntered(location, control, params)
	. = ..()
	var/mob/living/carbon/human/user = usr

	var/content_of_tooltip = get_additional_info(user)
	openToolTip(user = usr, tip_src = src, params = params, title = name, content = content_of_tooltip)

/atom/movable/screen/sword_info/traverse_info/proc/get_additional_info(mob/living/carbon/human/user)
	var/list/info = list()

	info += FONT_LARGE("[SPAN_COLOR("#ffffff","[user.current_active_technique.traverse_ability_name]")]")
	info += FONT_NORMAL("<li>[user.current_active_technique.traverse_ability_desc]</li>")

	info += FONT_SMALL("</ul></li>")
	info += FONT_NORMAL("<br>")

	info += FONT_SMALL("<li>ЦЕНА:[SPAN_COLOR("#ffffff","[user.current_active_technique.traverse_ability_cost]")]</li>")
	if(user.current_active_technique.traverse_ability_charges > 0)
		info += FONT_SMALL("<li>ЗАРЯДЫ:[SPAN_COLOR("#ffffff","[user.current_active_technique.traverse_ability_charges]")]</li>")

	info += FONT_SMALL("</ul></li>")

	return jointext(info, "")

/atom/movable/screen/sword_info/ranged_info
	icon_state = "info_ranged"
	alpha = 0
	mother_button = FALSE
	hide = TRUE

	prepare_offset = -30

/atom/movable/screen/sword_info/ranged_info/MouseEntered(location, control, params)
	. = ..()
	var/mob/living/carbon/human/user = usr

	var/content_of_tooltip = get_additional_info(user)
	openToolTip(user = usr, tip_src = src, params = params, title = name, content = content_of_tooltip)

/atom/movable/screen/sword_info/ranged_info/proc/get_additional_info(mob/living/carbon/human/user)
	var/list/info = list()

	info += FONT_LARGE("[SPAN_COLOR("#ffffff","[user.current_active_technique.ranged_ability_name]")]")
	info += FONT_NORMAL("<li>[user.current_active_technique.ranged_ability_desc]</li>")

	info += FONT_SMALL("</ul></li>")
	info += FONT_NORMAL("<br>")

	info += FONT_SMALL("<li>ЦЕНА:[SPAN_COLOR("#ffffff","[user.current_active_technique.ranged_ability_cost]")]</li>")
	if(user.current_active_technique.ranged_ability_charges > 0)
		info += FONT_SMALL("<li>ЗАРЯДЫ:[SPAN_COLOR("#ffffff","[user.current_active_technique.ranged_ability_charges]")]</li>")

	info += FONT_SMALL("</ul></li>")

	return jointext(info, "")

/atom/movable/screen/sword_info/aoe_info
	icon_state = "info_aoe"
	alpha = 0
	mother_button = FALSE
	hide = TRUE

	prepare_offset = -45

/atom/movable/screen/sword_info/aoe_info/MouseEntered(location, control, params)
	. = ..()
	var/mob/living/carbon/human/user = usr

	var/content_of_tooltip = get_additional_info(user)
	openToolTip(user = usr, tip_src = src, params = params, title = name, content = content_of_tooltip)

/atom/movable/screen/sword_info/aoe_info/proc/get_additional_info(mob/living/carbon/human/user)
	var/list/info = list()

	info += FONT_LARGE("[SPAN_COLOR("#ffffff","[user.current_active_technique.aoe_ability_name]")]")
	info += FONT_NORMAL("<li>[user.current_active_technique.aoe_ability_desc]</li>")

	info += FONT_SMALL("</ul></li>")
	info += FONT_NORMAL("<br>")

	info += FONT_SMALL("<li>ЦЕНА:[SPAN_COLOR("#ffffff","[user.current_active_technique.aoe_ability_cost]")]</li>")
	if(user.current_active_technique.aoe_ability_charges > 0)
		info += FONT_SMALL("<li>ЗАРЯДЫ:[SPAN_COLOR("#ffffff","[user.current_active_technique.aoe_ability_charges]")]</li>")

	info += FONT_SMALL("</ul></li>")

	return jointext(info, "")

/atom/movable/screen/sword_info/targeted_info
	icon_state = "info_targeted"
	alpha = 0
	mother_button = FALSE
	hide = TRUE

	prepare_offset = -60

/atom/movable/screen/sword_info/targeted_info/MouseEntered(location, control, params)
	. = ..()
	var/mob/living/carbon/human/user = usr

	var/content_of_tooltip = get_additional_info(user)
	openToolTip(user = usr, tip_src = src, params = params, title = name, content = content_of_tooltip)

/atom/movable/screen/sword_info/targeted_info/proc/get_additional_info(mob/living/carbon/human/user)
	var/list/info = list()

	info += FONT_LARGE("[SPAN_COLOR("#ffffff","[user.current_active_technique.targeted_ability_name]")]")
	info += FONT_NORMAL("<li>[user.current_active_technique.targeted_ability_desc]</li>")

	info += FONT_SMALL("</ul></li>")
	info += FONT_NORMAL("<br>")

	info += FONT_SMALL("<li>ЦЕНА:[SPAN_COLOR("#ffffff","[user.current_active_technique.targeted_ability_cost]")]</li>")
	if(user.current_active_technique.targeted_ability_charges > 0)
		info += FONT_SMALL("<li>ЗАРЯДЫ:[SPAN_COLOR("#ffffff","[user.current_active_technique.targeted_ability_charges]")]</li>")

	info += FONT_SMALL("</ul></li>")

	return jointext(info, "")

/datum/hud/human/proc/draw_sword_usage_stat(datum/custom_hud/ui_datum)
	sword_usage_stat = new /atom/movable/screen/sword_usage_stat()
	sword_usage_stat.icon = ui_datum.ui_style_icon
	sword_usage_stat.screen_loc = "CENTER,CENTER"
	infodisplay += sword_usage_stat

/atom/movable/screen/sword_usage_stat
	name = "current usage"
	icon_state = "usage_0"
	alpha = 0
	mouse_opacity = FALSE
	var/already_playing = FALSE

/atom/movable/screen/sword_usage_stat/proc/update_stat(mob/living/carbon/human/user)
	if(user && user.hud_used)
		if(user.sword_combat_active)

			if(user.overcharged || user.sword_usage_current > 10)
				icon_state = "usage_11"
			if(user.sword_usage_current <= 10 && !user.overcharged)
				icon_state = "usage_[user.sword_usage_current]"

			if(!already_playing)
				already_playing = TRUE

				if(alpha != 255)
					animate(src, alpha = 255, time = 0.5 SECONDS, flags = ANIMATION_PARALLEL)
					animate(src, transform = matrix(32, 0, MATRIX_TRANSLATE), time = 0.5 SECONDS, easing = SINE_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)

				if(!user.overcharged)
					addtimer(CALLBACK(src, PROC_REF(hide_stat)), 5 SECONDS)
				else
					addtimer(CALLBACK(src, PROC_REF(hide_stat)), 200 SECONDS)

		else
			if(alpha != 0)
				hide_stat()

/atom/movable/screen/sword_usage_stat/proc/hide_stat()
	animate(src, alpha = 0, time = 0.5 SECONDS, flags = ANIMATION_PARALLEL)
	animate(src, transform = matrix(0, 0, MATRIX_TRANSLATE), time = 0.5 SECONDS, easing = SINE_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
	already_playing = FALSE

/datum/hud/human/proc/draw_sword_limit_stat(datum/custom_hud/ui_datum)
	sword_limit_stat = new /atom/movable/screen/sword_limit_stat()
	sword_limit_stat.icon = ui_datum.ui_style_icon
	sword_limit_stat.screen_loc = "CENTER,CENTER"
	infodisplay += sword_limit_stat

/atom/movable/screen/sword_limit_stat
	name = "usage limit"
	icon_state = "usage_cap_10"
	alpha = 0
	mouse_opacity = FALSE
	var/already_playing = FALSE

/atom/movable/screen/sword_limit_stat/proc/update_stat(mob/living/carbon/human/user)
	if(user && user.hud_used)
		if(user.sword_combat_active)
			if(user.sword_usage_limit < 0)
				icon_state = "usage_cap_0"
			else
				icon_state = "usage_cap_[user.sword_usage_limit]"

			if(!already_playing)
				already_playing = TRUE

				if(alpha != 255)
					animate(src, alpha = 255, time = 0.5 SECONDS, flags = ANIMATION_PARALLEL)
					animate(src, transform = matrix(32, 0, MATRIX_TRANSLATE), time = 0.5 SECONDS, easing = SINE_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)

				if(!user.overcharged)
					addtimer(CALLBACK(src, PROC_REF(hide_stat)), 5 SECONDS)
				else
					addtimer(CALLBACK(src, PROC_REF(hide_stat)), 200 SECONDS)

		else
			if(alpha != 0)
				hide_stat()

/atom/movable/screen/sword_limit_stat/proc/hide_stat()
	animate(src, alpha = 0, time = 0.5 SECONDS, flags = ANIMATION_PARALLEL)
	animate(src, transform = matrix(0, 0, MATRIX_TRANSLATE), time = 0.5 SECONDS, easing = SINE_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
	already_playing = FALSE

//// SWORD ////

GLOBAL_LIST_INIT(parry_sound, list('code/modules/fd_sword/sounds/parry1.wav',
								'code/modules/fd_sword/sounds/parry2.wav',
								'code/modules/fd_sword/sounds/parry3.wav',
								'code/modules/fd_sword/sounds/parry4.wav',
								'code/modules/fd_sword/sounds/parry5.wav',
								'code/modules/fd_sword/sounds/parry6.wav',
								'code/modules/fd_sword/sounds/parry7.wav',
								'code/modules/fd_sword/sounds/parry8.wav'))

/obj/item/weapon/sword/fd_sword
	var/list/datum/sword_tech/techniques = list()
	var/datum/sword_tech/technique_attached = null
	icon = 'code/modules/fd_sword/icons/swords.dmi'
	icon_state = "timesword"

	hitsound = 'code/modules/fd_sword/sounds/basic_melee.wav'

	var/awakend = FALSE
	var/mob/living/carbon/human/new_soul = null
	var/hit_color = "#FF0000"

/obj/item/weapon/sword/fd_sword/Initialize(mapload, ...)
	. = ..()

	var/list/tech_creation = techniques.Copy()
	techniques.Cut()
	for(var/techs in tech_creation)
		new techs(src)

	if(length(techniques))
		technique_attached = techniques[1]

/obj/item/weapon/sword/fd_sword/attack(mob/target, mob/user)
	if(istype(target, /mob/living))

		var/mob/living/L = target
		var/mob/living/N = user

		N.cool_sword_attack_on(target)
		N.flick_attack_overlay(target, "punch")

		if(L.parry_protection)
			playsound(L, pick(GLOB.parry_sound), 50)
			new /obj/effect/block(get_turf(L))

			if(ishuman(L))
				var/mob/living/carbon/human/H = L
				H.remove_sword_usage(2)

			N.handle_melee_parry()
			return FALSE

	. = ..()

	if(!ishuman(target))
		new /obj/effect/fd_sword/hit_text(get_turf(target), force)

		var/impact_effect = pick(1,2)
		switch(impact_effect)
			if(1)
				new /obj/effect/fd_sword/hit_effect/alt1(get_turf(target))
			if(2)
				new /obj/effect/fd_sword/hit_effect/alt2(get_turf(target))

/obj/item/weapon/sword/fd_sword/equipped(mob/user, slot, silent)
	. = ..()

	if(awakend)
		trigger_awakening(user)

/obj/item/weapon/sword/fd_sword/dropped(mob/user)
	. = ..()

	if(awakend)
		trigger_awakening(user)

/obj/item/weapon/sword/fd_sword/attack_self(mob/user)
	. = ..()

	if(istype(user, /mob/living/carbon/human))
		trigger_awakening(user)

/obj/item/weapon/sword/fd_sword/proc/trigger_awakening(mob/living/carbon/human/soul)
	if(!awakend)

		if(!isnull(new_soul) && new_soul != soul)
			new /obj/effect/fd_sword/cannot_cast_ability(get_turf(soul))
			soul.balloon_alert(soul, "Меч уже привязан к [new_soul]!", COLOR_RED)
			shake_camera(soul, 2, 1)

			return FALSE

		if(length(soul.sword_pact) && !(src in soul.sword_pact))

			if(length(soul.sword_pact) >= 2)
				new /obj/effect/fd_sword/cannot_cast_ability(get_turf(soul))
				soul.balloon_alert(soul, "Вы уже повязаны пактом с двумя другими орудиями!", COLOR_RED)
				shake_camera(soul, 2, 1)

				return FALSE

			else
				soul.play_screen_text(text = "Вы хотите привязать второе орудие ценой своей стабильности?", alert_type = /atom/movable/screen/text/screen_text/command_order, override_color = "#ffffff")

				var/list/selection = list("YES" = image(icon = 'code/modules/fd_sword/icons/visuals.dmi', icon_state = "green"),
										"NO" = image(icon = 'code/modules/fd_sword/icons/visuals.dmi', icon_state = "red"))
				var/answer = show_radial_menu(soul, soul, selection, tooltips = TRUE, radius = 30)
				if(!answer)
					new /obj/effect/fd_sword/cannot_cast_ability(get_turf(soul))
					soul.balloon_alert(soul, "Вы уже повязаны пактом с другим орудием!", COLOR_RED)
					shake_camera(soul, 2, 1)

					return FALSE

				switch(answer)
					if("YES")
						soul.sword_usage_limit -= 2
						soul.hud_used.sword_usage_stat.update_stat(soul)
						soul.hud_used.sword_limit_stat.update_stat(soul)
					if("NO")
						new /obj/effect/fd_sword/cannot_cast_ability(get_turf(soul))
						soul.balloon_alert(soul, "Вы уже повязаны пактом с другим орудием!", COLOR_RED)
						shake_camera(soul, 2, 1)

						return FALSE

		awakend = TRUE
		add_filter("awakend", 1, list("type" = "outline", "color" = "#ffffff", "size" = 1))

		soul.current_active_technique = technique_attached
		soul.sword_combat_active = TRUE

		if(isnull(new_soul))
			new_soul = soul
			new_soul.sword_pact += src

		soul.hud_used.sword_info.change_visibility(soul)
		playsound(soul, 'code/modules/fd_sword/sounds/unsheet.wav', 50)
		soul.balloon_alert_to_viewers("*[soul.real_name] обнажил(а) клинок*", null, DEFAULT_MESSAGE_RANGE, null, COLOR_RED)

		return TRUE

	if(awakend)
		awakend = FALSE
		remove_filter("awakend", 1, list("type" = "outline", "color" = "#ffffff", "size" = 1))

		soul.current_active_technique = null
		soul.sword_combat_active = FALSE

		soul.balloon_alert_to_viewers("*[soul.real_name] спрятал(а) клинок*", null, DEFAULT_MESSAGE_RANGE, null, COLOR_WHITE)

		soul.hud_used.sword_info.change_visibility(soul)
		soul.hud_used.traverse_info.change_visibility(soul)
		soul.hud_used.ranged_info.change_visibility(soul)
		soul.hud_used.aoe_info.change_visibility(soul)
		soul.hud_used.targeted_info.change_visibility(soul)

		soul.hud_used.sword_usage_stat.update_stat(new_soul)
		soul.hud_used.sword_limit_stat.update_stat(new_soul)

		return TRUE

//// MOB ////

/mob
	var/srd_faction = "Neutral"

/mob/living
	var/parry_delay = FALSE
	var/parry_protection = FALSE

/mob/living/Life(delta_time)
	if(ice_stacks > 0)
		if(ice_stacks >= 10)
			turn_to_ice()
			set_status_value("cold", 0)
		else
			remove_status_value("cold", 1)

	if(bleed_stacks > 0)
		new /obj/effect/fd_sword/hit_text(get_turf(src), bleed_stacks*2)

		apply_damage(bleed_stacks*2, BRUTE)
		remove_status_value("bleed", 2)

	update_srd_statuses()

	. = ..()

/mob/living/proc/reset_parry_timer()
	balloon_alert(src, "Парирование перезарядилось!", COLOR_ORANGE)
	parry_delay = FALSE

/mob/living/proc/reset_parry_protection()
	anchored = FALSE
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, PARRY_TRAIT)

	parry_protection = FALSE

/mob/living/proc/handle_melee_parry()
	for(var/i = 0, i <= 3, i++)
		new /obj/effect/fd_sword/stunned(get_turf(src))

	shake_camera(src, 2, 1)

	ADD_TRAIT(src, TRAIT_IMMOBILIZED, PARRY_STUN_TRAIT)
	addtimer(CALLBACK(src, PROC_REF(remove_parry_stun)), 4 SECONDS)

/mob/living/proc/remove_parry_stun()
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, PARRY_STUN_TRAIT)

/mob/living/proc/cool_sword_attack_on(atom/A, pixel_offset = 8)

	var/obj/item/weapon/sword/fd_sword/FDS = get_active_hand()
	animation_flash_color(A, FDS.hit_color)
	SEND_SIGNAL(src, COMSIG_MOB_ANIMATING)

	if(A.clone)
		if(src.Adjacent(A.clone))
			A = A.clone
	if(buckled || anchored || HAS_TRAIT(src, TRAIT_HAULED)) //it would look silly.
		return
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0
	var/angle_diff = 0
	var/direction = get_dir(src, get_turf(A))
	pixel_offset = floor(pixel_offset) // Just to be safe

	var/client_offset_x = 0
	var/client_offset_y = 0

	if(QDELETED(A))
		direction = dir

	sword_overlayed_strike(FDS, src, direction)

	switch(direction)
		if(NORTH)
			pixel_y_diff = pixel_offset
			angle_diff = 30
			client_offset_y = 10
		if(SOUTH)
			pixel_y_diff = -pixel_offset
			angle_diff = -30
			client_offset_y = -10
		if(EAST)
			pixel_x_diff = pixel_offset
			angle_diff = 30
			client_offset_x = 10
		if(WEST)
			pixel_x_diff = -pixel_offset
			angle_diff = -30
			client_offset_x = -10
		if(NORTHEAST)
			pixel_x_diff = pixel_offset
			pixel_y_diff = pixel_offset
			angle_diff = 30
			client_offset_x = 10
			client_offset_y = 10
		if(NORTHWEST)
			pixel_x_diff = -pixel_offset
			pixel_y_diff = pixel_offset
			angle_diff = -30
			client_offset_x = -10
			client_offset_y = 10
		if(SOUTHEAST)
			pixel_x_diff = pixel_offset
			pixel_y_diff = -pixel_offset
			angle_diff = 30
			client_offset_x = 10
			client_offset_y = -10
		if(SOUTHWEST)
			pixel_x_diff = -pixel_offset
			pixel_y_diff = -pixel_offset
			angle_diff = -30
			client_offset_x = -10
			client_offset_y = -10

	special_camera_move(src, client_offset_x, client_offset_y)

	animate(src, transform = matrix(angle_diff, MATRIX_ROTATE), pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, time = 0.3 SECONDS, easing = SINE_EASING)
	animate(src, transform = matrix(2, 2, MATRIX_SCALE), time = 0.2 SECONDS, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
	animate(transform = matrix(0, MATRIX_ROTATE), pixel_x = initial(pixel_x), pixel_y = initial(pixel_y), time = 0.2 SECONDS)
	animate(transform = matrix(1, 1, MATRIX_SCALE), time = 0.3 SECONDS)

/proc/sword_overlayed_strike(atom/A, mob/living/owner, sword_direction = NORTH)

	var/obj/effect/fd_sword/fake_simple/fakesword = new /obj/effect/fd_sword/fake_simple(get_turf(owner))
	fakesword.icon_state = A.icon_state

	var/rotate_for = 0
	var/pixel_x_offset = 0
	var/pixel_y_offset = 0
	var/matrix/start_point = matrix()

	switch(sword_direction)
		if(NORTH)
			fakesword.pixel_y = 15
			start_point.Turn(60)
			rotate_for = 30
			pixel_y_offset = 10
		if(SOUTH)
			fakesword.pixel_y = -15
			start_point.Turn(240)
			rotate_for = 195
			pixel_y_offset = -10
		if(EAST)
			fakesword.pixel_x = 15
			start_point.Turn(150)
			rotate_for = 120
			pixel_x_offset = 10
		if(WEST)
			fakesword.pixel_x = -15
			start_point.Turn(300)
			rotate_for = 330
			pixel_x_offset = -10
		if(NORTHEAST)
			fakesword.pixel_x = 15
			fakesword.pixel_y = 15
			start_point.Turn(135)
			rotate_for = 90
			pixel_x_offset = 10
			pixel_y_offset = 10
		if(NORTHWEST)
			fakesword.pixel_x = -15
			fakesword.pixel_y = 15
			start_point.Turn(315)
			rotate_for = 360
			pixel_x_offset = -10
			pixel_y_offset = 10
		if(SOUTHEAST)
			fakesword.pixel_x = 15
			fakesword.pixel_y = -15
			start_point.Turn(135)
			rotate_for = 180
			pixel_x_offset = 10
			pixel_y_offset = -10
		if(SOUTHWEST)
			fakesword.pixel_x = -15
			fakesword.pixel_y = -15
			start_point.Turn(315)
			rotate_for = 270
			pixel_x_offset = -10
			pixel_y_offset = -10

	fakesword.transform = start_point
	animate(fakesword, alpha = 175, pixel_x = fakesword.pixel_x + pixel_x_offset, pixel_y = fakesword.pixel_y + pixel_y_offset, transform = matrix(rotate_for, MATRIX_ROTATE), time = 0.3 SECONDS, easing = SINE_EASING)

	spawn(1 SECONDS)
		qdel(fakesword)

/proc/special_camera_move(mob/M, offset_x, offset_y)
	var/old_x = M.client.get_pixel_x()
	var/old_y = M.client.get_pixel_y()

	animate(M.client, pixel_x = old_x + offset_x, pixel_y = old_y + offset_y, time = 0.3 SECONDS, easing = BACK_EASING|EASE_OUT)
	animate(pixel_x = old_x, pixel_y = old_y, time = 0.2 SECONDS, easing = SINE_EASING|EASE_OUT)

/obj/effect/fd_sword/fake_simple
	name = "combat sword"
	icon = 'code/modules/fd_sword/icons/swords.dmi'
	icon_state = "goldensword"

	anchored = TRUE
	mouse_opacity = FALSE
	layer = 5
	plane = 5

	alpha = 0

/mob/living/carbon/human
	var/datum/sword_tech/current_active_technique = null
	var/list/obj/item/weapon/sword/fd_sword/sword_pact = list()

	var/sword_usage_limit = 10
	var/sword_usage_current = 0

	var/sword_combat_active = FALSE // Больше никаких рандомклик взрывов школы

	var/danger_zone_reached = FALSE
	var/overcharged = FALSE

	var/sword_directionals = TRUE

	srd_faction = "Allies"

/mob/living/carbon/human/Move(NewLoc, direct)

	if(istype(current_active_technique, /datum/sword_tech/goldensword))
		if(collected_gold < 20 && collected_gold > 5)
			next_move_slowdown = -0.5
		if(collected_gold >= 20 && collected_gold < 50)
			next_move_slowdown = -1
		if(collected_gold >= 50)
			next_move_slowdown = -2

	if(overcharged)
		next_move_slowdown = -2

	if(istype(current_active_technique, /datum/sword_tech/wintersword))
		var/datum/sword_tech/wintersword/icewalk = current_active_technique
		if(icewalk.traverse_active)
			next_move_slowdown = -1
			flags_atom |= NO_ZFALL
			var/obj/structure/fd_sword/ice_bridge/newbridge = new /obj/structure/fd_sword/ice_bridge(get_turf(NewLoc))
			newbridge.related_faction = srd_faction

	. = ..()

	flags_atom &= ~NO_ZFALL

/mob/living/carbon/human/proc/remove_sword_usage(amount)
	sword_usage_current = max(0, sword_usage_current - amount)

/mob/living/carbon/human/proc/add_sword_usage(amount)
	sword_usage_current += amount
	current_active_technique.check_overcharge()

/mob/living/carbon/human/proc/trigger_overcharge()
	playsound_client(client, 'code/modules/fd_sword/sounds/overflow.mp3', src, 25, 0)

	new /obj/effect/fd_sword/sanity_effect/overflow(get_turf(src))
	add_filter("overcharged", 1, list("type" = "outline", "color" = "#a200ff", "size" = 1))
	overlays += image('code/modules/fd_sword/icons/visuals.dmi', icon_state = "dementation")

	overcharged = TRUE
	hud_used.sword_usage_stat.update_stat(src)
	hud_used.sword_limit_stat.update_stat(src)

	for(var/obj/item/weapon/sword/fd_sword/S in sword_pact)
		S.attack_speed = 1

	addtimer(CALLBACK(src, PROC_REF(resolve_overcharge)), 200 SECONDS)

/mob/living/carbon/human/proc/resolve_overcharge()
	var/datum/sword_tech/last_used_tech = current_active_technique

	new /obj/effect/fd_sword/sanity_effect(get_turf(src))
	remove_filter("overcharged", 1, list("type" = "outline", "color" = "#a200ff", "size" = 1))
	overlays -= image('code/modules/fd_sword/icons/visuals.dmi', icon_state = "dementation")

	apply_effect(10, SLOW)
	apply_effect(10, AGONY)

	overcharged = FALSE
	sword_usage_limit -= 1
	sword_usage_current = 0

	hud_used.sword_usage_stat.update_stat(src)
	hud_used.sword_limit_stat.update_stat(src)

	reagents.del_reagent("speed_stimulant")
	reagents.del_reagent("brain_stimulant")

	for(var/obj/item/weapon/sword/fd_sword/S in sword_pact)
		S.attack_speed = initial(S.attack_speed)

	last_used_tech.overcharge_marks()
	last_used_tech.danger_zone_reached = FALSE

//// SCHOOL ////

/datum/sword_tech
	var/name = "ТЕХНИКА: Ничего"

	var/tech_level = 1
	var/danger_zone_reached = FALSE

	var/traverse_ability_cooldown = 0 // Q keybind
	var/traverse_ability_ready = TRUE
	var/traverse_ability_cost = 1
	var/traverse_ability_charges = -1

	var/traverse_ability_name = "ПЕРЕДВИЖЕНИЕ"
	var/traverse_ability_desc = "Описание"

	var/ranged_ability_cooldown = 0 // E keybind
	var/ranged_ability_ready = TRUE
	var/ranged_ability_cost = 1
	var/ranged_ability_charges = -1

	var/ranged_ability_name = "ДИСТАНЦИОННОЕ"
	var/ranged_ability_desc = "Описание"

	var/aoe_ability_cooldown = 0 // Shift+E keybind
	var/aoe_ability_ready = TRUE
	var/aoe_ability_cost = 1
	var/aoe_ability_charges = -1

	var/aoe_ability_name = "МАССОВОЕ"
	var/aoe_ability_desc = "Описание"

	var/targeted_ability_cooldown = 0 // LMB по объектам
	var/targeted_ability_ready = TRUE
	var/targeted_ability_cost = 1
	var/targeted_ability_charges = -1

	var/targeted_ability_name = "НАПРАВЛЕННОЕ"
	var/targeted_ability_desc = "Описание"

	var/obj/item/weapon/sword/fd_sword/connected_weapon

/datum/sword_tech/New(obj/item/weapon/sword/fd_sword/weapon)
	. = ..()
	connected_weapon = weapon
	weapon.techniques += src

	Initialize()

/datum/sword_tech/Destroy()
	connected_weapon.new_soul = null
	connected_weapon = null
	. = ..()

/datum/sword_tech/proc/Initialize()

	if(name)
		src.name = name

/datum/sword_tech/proc/check_overcharge()
	var/pre_overcharge = connected_weapon.new_soul.sword_usage_limit - 2

	if(connected_weapon.new_soul.sword_usage_current >= pre_overcharge && !danger_zone_reached)
		danger_zone_reached = TRUE
		new /obj/effect/fd_sword/sanity_effect/full(get_turf(connected_weapon.new_soul))
		return TRUE

	if(connected_weapon.new_soul.sword_usage_current > connected_weapon.new_soul.sword_usage_limit && !connected_weapon.new_soul.overcharged && !connected_weapon.new_soul.jackpot_status)
		connected_weapon.new_soul.trigger_overcharge()

/datum/sword_tech/proc/overcharge_marks()
	return TRUE

/datum/sword_tech/proc/traverse_ability_check()
	if(!traverse_ability_ready)
		new /obj/effect/fd_sword/ability_on_cooldown(get_turf(connected_weapon.new_soul))
		connected_weapon.new_soul.balloon_alert(connected_weapon.new_soul, "Способность перезаряжается!", COLOR_ORANGE)
		return FALSE

	use_traverse_ability()
	connected_weapon.new_soul.add_sword_usage(traverse_ability_cost)

	if(traverse_ability_cost > 0)
		connected_weapon.new_soul.hud_used.sword_usage_stat.update_stat(connected_weapon.new_soul)
		connected_weapon.new_soul.hud_used.sword_limit_stat.update_stat(connected_weapon.new_soul)
	if(traverse_ability_charges > 0)
		traverse_ability_charges -= 1
		return TRUE

	traverse_ability_ready = FALSE
	addtimer(CALLBACK(src, PROC_REF(traverse_ability_reset)), traverse_ability_cooldown)

	return TRUE
/datum/sword_tech/proc/use_traverse_ability()
	return TRUE
/datum/sword_tech/proc/traverse_ability_reset()
	if(traverse_ability_charges == 0)
		traverse_ability_charges = initial(traverse_ability_charges)

	traverse_ability_ready = TRUE




/datum/sword_tech/proc/ranged_ability_check()
	if(!ranged_ability_ready)
		new /obj/effect/fd_sword/ability_on_cooldown(get_turf(connected_weapon.new_soul))
		connected_weapon.new_soul.balloon_alert(connected_weapon.new_soul, "Способность перезаряжается!", COLOR_ORANGE)
		return FALSE

	use_ranged_ability()
	connected_weapon.new_soul.add_sword_usage(ranged_ability_cost)

	if(ranged_ability_cost > 0)
		connected_weapon.new_soul.hud_used.sword_usage_stat.update_stat(connected_weapon.new_soul)
		connected_weapon.new_soul.hud_used.sword_limit_stat.update_stat(connected_weapon.new_soul)

	if(ranged_ability_charges > 0)
		ranged_ability_charges -= 1
		return TRUE

	ranged_ability_ready = FALSE
	addtimer(CALLBACK(src, PROC_REF(ranged_ability_reset)), ranged_ability_cooldown)

	return TRUE
/datum/sword_tech/proc/use_ranged_ability()
	return TRUE
/datum/sword_tech/proc/ranged_ability_reset()
	if(ranged_ability_charges == 0)
		ranged_ability_charges = initial(ranged_ability_charges)

	ranged_ability_ready = TRUE




/datum/sword_tech/proc/aoe_ability_check()
	if(!aoe_ability_ready)
		new /obj/effect/fd_sword/ability_on_cooldown(get_turf(connected_weapon.new_soul))
		connected_weapon.new_soul.balloon_alert(connected_weapon.new_soul, "Способность перезаряжается!", COLOR_ORANGE)
		return FALSE

	use_aoe_ability()
	connected_weapon.new_soul.add_sword_usage(aoe_ability_cost)

	if(aoe_ability_cost > 0)
		connected_weapon.new_soul.hud_used.sword_usage_stat.update_stat(connected_weapon.new_soul)
		connected_weapon.new_soul.hud_used.sword_limit_stat.update_stat(connected_weapon.new_soul)

	if(aoe_ability_charges > 0)
		aoe_ability_charges -= 1
		return TRUE

	aoe_ability_ready = FALSE
	addtimer(CALLBACK(src, PROC_REF(aoe_ability_reset)), aoe_ability_cooldown)

	return TRUE
/datum/sword_tech/proc/use_aoe_ability()
	return TRUE
/datum/sword_tech/proc/aoe_ability_reset()
	if(aoe_ability_charges == 0)
		aoe_ability_charges = initial(aoe_ability_charges)

	aoe_ability_ready = TRUE




/datum/sword_tech/proc/targeted_ability_check(atom/target)
	if(!targeted_ability_ready)
		if(!connected_weapon.new_soul.get_active_hand())
			new /obj/effect/fd_sword/ability_on_cooldown(get_turf(connected_weapon.new_soul))
			connected_weapon.new_soul.balloon_alert(connected_weapon.new_soul, "Способность перезаряжается!", COLOR_ORANGE)
		return FALSE

	use_targeted_ability(target)
	connected_weapon.new_soul.add_sword_usage(targeted_ability_cost)

	if(targeted_ability_cost > 0)
		connected_weapon.new_soul.hud_used.sword_usage_stat.update_stat(connected_weapon.new_soul)
		connected_weapon.new_soul.hud_used.sword_limit_stat.update_stat(connected_weapon.new_soul)

	if(targeted_ability_charges > 0)
		targeted_ability_charges -= 1
		return TRUE

	targeted_ability_ready = FALSE
	addtimer(CALLBACK(src, PROC_REF(targeted_ability_reset)), targeted_ability_cooldown)

	return TRUE
/datum/sword_tech/proc/use_targeted_ability(atom/target)
	return TRUE
/datum/sword_tech/proc/targeted_ability_reset()
	if(targeted_ability_charges == 0)
		targeted_ability_charges = initial(targeted_ability_charges)

	targeted_ability_ready = TRUE

//// KEYBINDS ////
#define COMSIG_KB_HUMAN_SWORD_TRAVERSE "keybinding_human_sword_traverse"
#define COMSIG_KB_HUMAN_SWORD_RANGED "keybinding_human_sword_ranged"
#define COMSIG_KB_HUMAN_SWORD_AOE "keybinding_human_sword_aoe"

#define COMSIG_KB_HUMAN_SWORD_PARRY "keybinding_human_sword_parry"
#define COMSIG_KB_HUMAN_SWORD_DIRECTIONALS "keybinding_human_sword_directionals"

#define CATEGORY_SWORD "ПРОЕКТ МЕЧ"

/datum/keybinding/human/sword_technique
	category = CATEGORY_SWORD

/datum/keybinding/human/sword_technique/can_use(client/user)

	var/mob/living/carbon/human/human_mob = user.mob

	if(!human_mob.sword_combat_active)
		new /obj/effect/fd_sword/cannot_cast_ability(get_turf(human_mob))
		human_mob.balloon_alert(human_mob, "Вытащите меч из ножен!", COLOR_RED)
		shake_camera(human_mob, 2, 1)
		return FALSE

	. = ..()

/datum/keybinding/human/sword_technique/traverse
	hotkey_keys = list("Q")
	classic_keys = list("Unbound")
	name = "sword_traverse"
	full_name = "ТЕХНИКА: Передвижение"
	description = "Помогает в перемещении по пространству."
	keybind_signal = COMSIG_KB_HUMAN_SWORD_TRAVERSE

/datum/keybinding/human/sword_technique/traverse/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/human_mob = user.mob
	if(istype(human_mob.current_active_technique, /datum/sword_tech/pyrokinesis))
		var/datum/sword_tech/pyrokinesis/P = human_mob.current_active_technique
		P.cooling = TRUE

/datum/keybinding/human/sword_technique/traverse/up(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/human_mob = user.mob
	human_mob.current_active_technique.traverse_ability_check()

	if(istype(human_mob.current_active_technique, /datum/sword_tech/pyrokinesis))
		var/datum/sword_tech/pyrokinesis/P = human_mob.current_active_technique
		P.cooling = FALSE

	return TRUE

/datum/keybinding/human/sword_technique/ranged
	hotkey_keys = list("E")
	classic_keys = list("Unbound")
	name = "sword_ranged"
	full_name = "ТЕХНИКА: Дальнее действие"
	description = "Дистанционная способность с разными применениями."
	keybind_signal = COMSIG_KB_HUMAN_SWORD_RANGED

/datum/keybinding/human/sword_technique/ranged/up(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/human_mob = user.mob
	human_mob.current_active_technique.ranged_ability_check()
	return TRUE

/datum/keybinding/human/sword_technique/aoe
	hotkey_keys = list("R")
	classic_keys = list("Unbound")
	name = "sword_aoe"
	full_name = "ТЕХНИКА: Массовое действие"
	description = "Способность с широким радиусом воздействия."
	keybind_signal = COMSIG_KB_HUMAN_SWORD_AOE

/datum/keybinding/human/sword_technique/aoe/up(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/human_mob = user.mob
	human_mob.current_active_technique.aoe_ability_check()
	return TRUE

/datum/keybinding/human/sword_technique/parry
	hotkey_keys = list("F")
	classic_keys = list("Unbound")
	name = "sword_parry"
	full_name = "УТИЛИТА: Паррирование"
	description = "Блокирует входящую атаку, если нажата вовремя."
	keybind_signal = COMSIG_KB_HUMAN_SWORD_PARRY

/datum/keybinding/human/sword_technique/parry/can_use(client/user)
	var/mob/living/carbon/human/human_mob = user.mob

	if(human_mob.parry_delay)
		new /obj/effect/fd_sword/cannot_cast_ability(get_turf(human_mob))
		human_mob.balloon_alert(human_mob, "Ещё рано! Парирование недоступно!", COLOR_RED)
		shake_camera(human_mob, 2, 1)
		return FALSE

	return ishuman(user.mob) && user.mob.stat == CONSCIOUS

/datum/keybinding/human/sword_technique/parry/up(client/user)
	. = ..()
	if(.)
		return

	var/mob/living/carbon/human/human_mob = user.mob
	human_mob.parry_delay = TRUE
	human_mob.parry_protection = TRUE

	new /obj/effect/fd_sword/parry(get_turf(human_mob))

	human_mob.anchored = TRUE
	ADD_TRAIT(human_mob, TRAIT_IMMOBILIZED, PARRY_TRAIT)
	addtimer(CALLBACK(human_mob, TYPE_PROC_REF(/mob/living/carbon/human, reset_parry_timer)), 6 SECONDS)
	addtimer(CALLBACK(human_mob, TYPE_PROC_REF(/mob/living/carbon/human, reset_parry_protection)), 1.5 SECONDS)

/datum/keybinding/human/sword_technique/directional_attacks
	hotkey_keys = list("Unbound")
	classic_keys = list("Unbound")
	name = "sword_directionals"
	full_name = "УТИЛИТА: Автоматическое наведение"
	description = "Атакует цель вплотную к вам по направлению клика"
	keybind_signal = COMSIG_KB_HUMAN_SWORD_DIRECTIONALS

/datum/keybinding/human/sword_technique/directional_attacks/can_use(client/user)
	return ishuman(user.mob) && user.mob.stat == CONSCIOUS

/datum/keybinding/human/sword_technique/directional_attacks/up(client/user)
	. = ..()
	if(.)
		return

	var/mob/living/carbon/human/human_mob = user.mob

	if(human_mob.sword_directionals)
		human_mob.sword_directionals = FALSE
		human_mob.balloon_alert(human_mob, "Автоматическое наведение отключено!", COLOR_ORANGE)
		return TRUE
	else
		human_mob.sword_directionals = TRUE
		human_mob.balloon_alert(human_mob, "Автоматическое наведение включено!", COLOR_ORANGE)
		return TRUE

// VARIOUS TEST STUFF //

/mob/living/simple_animal/hostile/alien/fd_sword_test
	icon = 'code/modules/fd_sword/icons/mob.dmi'
	icon_gib = "behemoth"

	name = "Entity"

	health = 10
	pixel_x = 0
	old_x = 0

	melee_damage_lower = 5
	melee_damage_upper = 15

/mob/living/simple_animal/hostile/alien/fd_sword_test/update_wounds()
	return
