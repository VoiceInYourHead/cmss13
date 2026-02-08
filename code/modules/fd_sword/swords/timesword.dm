/atom
	var/deplaced = FALSE

/obj/item/weapon/sword/fd_sword/timesword
	techniques = list(/datum/sword_tech/timesword)

/obj/item/weapon/sword/fd_sword/timesword/attack(mob/target, mob/user)
	. = ..()

	var/mob/living/carbon/human/H = user

	if(istype(target, /mob/living) && H.sword_combat_active)
		if(target != user)

			new_soul.add_status_value("time", 1)

/mob/living/proc/reset_timeanchor()

	anchored = FALSE
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, TIMECURSE_TRAIT)
	REMOVE_TRAIT(src, TRAIT_UNDENSE, TIMECURSE_TRAIT)

	remove_filter("timestopped", 1, list("type" = "blur", "size" = 1))

/datum/sword_tech/timesword
	name = "КОНЦЕПЦИЯ: Время"

	traverse_ability_cooldown = 30 SECONDS
	traverse_ability_cost = 1
	traverse_ability_charges = 3

	ranged_ability_cooldown = 10 SECONDS
	ranged_ability_charges = 2
	ranged_ability_cost = 2
	var/ranged_ability_range = 4

	aoe_ability_cooldown = 1 MINUTES
	aoe_ability_cost = 4

	targeted_ability_cost = 0
	targeted_ability_cooldown = 2 SECONDS

	var/traverse_fragments_cost = 1
	var/aoe_fragments_cost = 10
	var/targeted_fragments_cost = 1

	traverse_ability_name = "ВРЕМЕННОЙ ЯКОРЬ"
	ranged_ability_name = "ТЕМПОРАЛЬНАЯ ВОЛНА"
	aoe_ability_name = "ЧАС РАСПЛАТЫ"
	targeted_ability_name = "ВРЕМЕННОЕ ИСКАЖЕНИЕ"

	traverse_ability_desc = "Устанавливает в точке временной якорь, который перемещает вас обратно во времени по прохождению пяти секунд, тратя 1 ФРАГМЕНТ и полностью восстанавливая здоровье"
	ranged_ability_desc = "Все сущности, оказавшиеся в зоне оной, становятся на временной якорь. По прохождению 5 секунд, эти сущности притягиваются к якорю и замирают во времени. +2 ФРАГМЕНТА за каждую поражённую цель"
	aoe_ability_desc = "Создаёт темпоральный шторм, заставляющий всех живых существ замереть во времени. Тратит 10 ФРАГМЕНТОВ"
	targeted_ability_desc = "Касание пустой руки в боевом режиме де-материализует предмет из пространства за 1 ФРАГМЕНТ. Обычная атака даёт 1 ФРАГМЕНТ"

/datum/sword_tech/timesword/overcharge_marks()
	connected_weapon.new_soul.age += 10

	connected_weapon.new_soul.r_hair = 255
	connected_weapon.new_soul.g_hair = 255
	connected_weapon.new_soul.b_hair = 255

	connected_weapon.new_soul.r_facial = 255
	connected_weapon.new_soul.g_facial = 255
	connected_weapon.new_soul.b_facial = 255

	connected_weapon.new_soul.update_hair()

	if(connected_weapon.new_soul.age >= 100)
		process_death()

/datum/sword_tech/timesword/proc/process_death()

	connected_weapon.new_soul.play_screen_text(text = "Сердце...забилось чаще?", alert_type = /atom/movable/screen/text/screen_text/command_order/centered, override_color = "#ffffff")
	connected_weapon.new_soul.m_intent = MOVE_INTENT_WALK

	spawn(5 SECONDS)
		connected_weapon.new_soul.play_screen_text(text = "Чувствую себя неважно, голова кружится...", alert_type = /atom/movable/screen/text/screen_text/command_order/centered, override_color = "#ffffff")
		connected_weapon.new_soul.emote("cough")

	spawn(5.5 SECONDS)
		connected_weapon.new_soul.emote("cough")

	spawn(10 SECONDS)
		connected_weapon.new_soul.apply_effect(999, EYE_BLUR)
		connected_weapon.new_soul.play_screen_text(text = "Неужто добегался?... <span class='corp_label_red'><b>Время словно утекает из моих рук</b></span>...", alert_type = /atom/movable/screen/text/screen_text/command_order/centered, override_color = "#ffffff")

	spawn(15 SECONDS)
		connected_weapon.new_soul.apply_effect(999, SLOW)
		connected_weapon.new_soul.play_screen_text(text = "Мне так... <span class='corp_label_red'><b>страшно</b></span>...", alert_type = /atom/movable/screen/text/screen_text/command_order/centered, override_color = "#ffffff")

	spawn(20 SECONDS)
		connected_weapon.new_soul.play_screen_text(text = "Ре...-бята...", alert_type = /atom/movable/screen/text/screen_text/command_order/centered, override_color = "#ffffff")
		connected_weapon.new_soul.apply_internal_damage(100, "heart")

/datum/sword_tech/timesword/proc/create_new_anchor(mob/living/anchored)
	var/teleport_to

	if(!istype(anchored, connected_weapon.new_soul))
		teleport_to = new /obj/effect/fd_sword/timeanchor/alter(get_turf(anchored))
	else
		teleport_to = new /obj/effect/fd_sword/timeanchor(get_turf(anchored))

	addtimer(CALLBACK(src, PROC_REF(backintime), teleport_to, anchored), 5 SECONDS)

/datum/sword_tech/timesword/proc/backintime(obj/anchor, mob/living/traveler)

	if(traveler == connected_weapon.new_soul)

		connected_weapon.new_soul.anchored = TRUE
		ADD_TRAIT(connected_weapon.new_soul, TRAIT_IMMOBILIZED, TIMECURSE_TRAIT)
		ADD_TRAIT(connected_weapon.new_soul, TRAIT_UNDENSE, TIMECURSE_TRAIT)

		new /obj/effect/fd_sword/timetentacles(get_turf(traveler))

		spawn(1 SECONDS)
			animate(connected_weapon.new_soul, pixel_x = -32, time = 0.5 SECONDS, easing = SINE_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
			animate(connected_weapon.new_soul, alpha = 0, time = 0.5 SECONDS, flags = ANIMATION_PARALLEL)

			playsound(connected_weapon.new_soul, 'code/modules/fd_sword/sounds/timesword_traverse.wav', 50)

		spawn(1.5 SECONDS)
			connected_weapon.new_soul.anchored = FALSE
			REMOVE_TRAIT(connected_weapon.new_soul, TRAIT_IMMOBILIZED, TIMECURSE_TRAIT)
			REMOVE_TRAIT(connected_weapon.new_soul, TRAIT_UNDENSE, TIMECURSE_TRAIT)

			traveler.forceMove(get_turf(anchor))
			traveler.rejuvenate()
			connected_weapon.new_soul.pixel_x = 0
			animate(connected_weapon.new_soul, alpha = 255, time = 1 SECONDS)

			if(!connected_weapon.new_soul.is_holding(connected_weapon))

				if(!connected_weapon.new_soul.r_hand)
					connected_weapon.new_soul.put_in_r_hand(connected_weapon)

				else
					if(!connected_weapon.new_soul.l_hand)
						connected_weapon.new_soul.put_in_l_hand(connected_weapon)

	else
		traveler.throw_atom(anchor, get_dist(anchor, traveler)+5, SPEED_VERY_FAST, src, TRUE, HIGH_LAUNCH, PASS_ALL)
		if(istype(anchor, /obj/effect/fd_sword/timeanchor))
			var/obj/effect/fd_sword/timeanchor/T = anchor

			T.timecurse(traveler)

	animate(anchor, alpha = 0, time = 1 SECONDS)
	spawn(1.5 SECONDS)
		qdel(anchor)

/datum/sword_tech/timesword/traverse_ability_check()
	if(connected_weapon.new_soul.time_fragments < traverse_fragments_cost)
		new /obj/effect/fd_sword/cannot_cast_ability(get_turf(connected_weapon.new_soul))
		connected_weapon.new_soul.balloon_alert(connected_weapon.new_soul, "Недостаточно фрагментов!", COLOR_RED)
		shake_camera(connected_weapon.new_soul, 2, 1)
		return FALSE

	. = ..()

/datum/sword_tech/timesword/use_traverse_ability()

	connected_weapon.new_soul.remove_status_value("time", traverse_fragments_cost)

	//update_info()
	create_new_anchor(connected_weapon.new_soul)

/datum/sword_tech/timesword/use_ranged_ability()
	var/final_ability_range = ranged_ability_range + tech_level
	var/turf/ending = get_ranged_target_turf(connected_weapon.new_soul, connected_weapon.new_soul.dir, final_ability_range)
	var/list/affected_turfs = list()

	for(var/turf/T in get_line(connected_weapon.new_soul, ending))
		if(T == get_turf(connected_weapon.new_soul))
			continue
		affected_turfs += T

	for(var/turf/T in affected_turfs)
		new /obj/effect/fd_sword/telegraph_basic/timesword/ranged(T)

		// ДЛЯ СОЮЗНИКОВ //
		for(var/mob/living/N in T)
			var/list/escape_turfs = list()
			if(N.srd_faction == connected_weapon.new_soul.srd_faction && N != connected_weapon.new_soul)
				for(var/turf/move_to in range(1,N))
					if(move_to.density)
						continue
					if(!(move_to in affected_turfs))
						escape_turfs += move_to

				N.forceMove(pick(escape_turfs))
		// ДЛЯ СОЮЗНИКОВ //

	spawn(0.5 SECONDS)

		playsound(connected_weapon.new_soul, 'code/modules/fd_sword/sounds/timesword_ranged.wav', 50)

		for(var/turf/T in affected_turfs)
			new /obj/effect/fd_sword/timewave(T)

			for(var/mob/living/N in T)
				if(N.parry_protection)
					playsound(N, pick(GLOB.parry_sound), 50)
					new /obj/effect/block(get_turf(N))

					if(ishuman(N))
						var/mob/living/carbon/human/H = N
						H.remove_sword_usage(2)

					continue
				new /obj/effect/fd_sword/anchored(get_turf(N))

				connected_weapon.new_soul.add_status_value("time", 2)
				create_new_anchor(N)

		var/reverse_facing = get_dir(ending, connected_weapon.new_soul)

		new /obj/effect/fd_sword/hit_effect(get_turf(connected_weapon.new_soul))
		connected_weapon.new_soul.animation_attack_on(ending)

		connected_weapon.new_soul.throw_atom(get_edge_target_turf(connected_weapon.new_soul, reverse_facing), 1, SPEED_AVERAGE, src, FALSE)
		connected_weapon.new_soul.face_atom(ending)

/datum/sword_tech/timesword/aoe_ability_check()
	if(connected_weapon.new_soul.time_fragments < aoe_fragments_cost)
		new /obj/effect/fd_sword/cannot_cast_ability(get_turf(connected_weapon.new_soul))
		connected_weapon.new_soul.balloon_alert(connected_weapon.new_soul, "Недостаточно фрагментов!", COLOR_RED)
		shake_camera(connected_weapon.new_soul, 2, 1)
		return FALSE

	. = ..()

/datum/sword_tech/timesword/use_aoe_ability()
	var/aoe_area = 2 + tech_level
	connected_weapon.new_soul.remove_status_value("time", aoe_fragments_cost)

	//update_info()

	connected_weapon.new_soul.anchored = TRUE
	ADD_TRAIT(connected_weapon.new_soul, TRAIT_IMMOBILIZED, TIMECURSE_TRAIT)
	ADD_TRAIT(connected_weapon.new_soul, TRAIT_UNDENSE, TIMECURSE_TRAIT)

	animate(connected_weapon.new_soul, pixel_z = 64, time = 1 SECONDS, easing = SINE_EASING|EASE_OUT)

	var/list/danger_turfs = list()
	for(var/turf/T in orange(aoe_area, connected_weapon.new_soul))
		new /obj/effect/fd_sword/telegraph_basic/timesword/aoe(T)
		danger_turfs += T

		// ДЛЯ СОЮЗНИКОВ //
		for(var/mob/living/L in T)
			var/list/escape_turfs = list()
			if(L.srd_faction == connected_weapon.new_soul.srd_faction && L != connected_weapon.new_soul)
				for(var/turf/move_to in view(7,L))
					if(move_to.density)
						continue
					if(!(move_to in danger_turfs))
						escape_turfs += move_to

				L.throw_atom(pick(escape_turfs), 7, SPEED_FAST, src, FALSE, HIGH_LAUNCH, PASS_ALL)
		// ДЛЯ СОЮЗНИКОВ //

	spawn(1 SECONDS)

		playsound(connected_weapon.new_soul, 'code/modules/fd_sword/sounds/timesword_aoe3.wav', 50)

		for(var/turf/T in orange(aoe_area, connected_weapon.new_soul))
			new /obj/effect/fd_sword/timewave(T)

		new /obj/effect/fd_sword/timeaoe(get_turf(connected_weapon.new_soul))
		animate(connected_weapon.new_soul, pixel_z = 0, time = 0.2 SECONDS, easing = SINE_EASING|EASE_OUT)

		connected_weapon.new_soul.anchored = FALSE
		REMOVE_TRAIT(connected_weapon.new_soul, TRAIT_IMMOBILIZED, TIMECURSE_TRAIT)
		REMOVE_TRAIT(connected_weapon.new_soul, TRAIT_UNDENSE, TIMECURSE_TRAIT)

		for(var/mob/living/M in orange(aoe_area, connected_weapon.new_soul))

			if(M == connected_weapon.new_soul)
				continue

			new /obj/effect/fd_sword/anchored(get_turf(M))
			M.add_filter("timestopped", 1, list("type" = "blur", "size" = 1))

			M.anchored = TRUE
			ADD_TRAIT(M, TRAIT_IMMOBILIZED, TIMECURSE_TRAIT)
			ADD_TRAIT(M, TRAIT_UNDENSE, TIMECURSE_TRAIT)

			addtimer(CALLBACK(M, TYPE_PROC_REF(/mob/living, reset_timeanchor)), 10 SECONDS)

/datum/sword_tech/timesword/use_targeted_ability(atom/target)
	if(istype(target, /obj/) && target != connected_weapon)
		var/obj/O = target

		if(!connected_weapon.new_soul.get_active_hand())
			if(connected_weapon.new_soul.time_fragments >= targeted_fragments_cost)

				new /obj/effect/fd_sword/targeted_ability(get_turf(O))

				if(!O.deplaced && !istype(O, /obj/item/weapon/sword/fd_sword))
					animate(O, alpha = 100, time = 1 SECONDS)
					O.add_filter("timestopped", 1, list("type" = "blur", "size" = 1))

					O.density = FALSE
					O.anchored = TRUE
					O.opacity = FALSE
					O.deplaced = TRUE

					connected_weapon.new_soul.remove_status_value("time", targeted_fragments_cost)
					connected_weapon.new_soul.add_sword_usage(1)

					connected_weapon.new_soul.hud_used.sword_usage_stat.update_stat(connected_weapon.new_soul)
					connected_weapon.new_soul.hud_used.sword_limit_stat.update_stat(connected_weapon.new_soul)

					//update_info()
				else
					animate(O, alpha = 255, time = 1 SECONDS)
					O.remove_filter("timestopped", 1, list("type" = "blur", "size" = 1))

					O.density = initial(O.density)
					O.anchored = initial(O.anchored)
					O.opacity = initial(O.opacity)
					O.deplaced = FALSE

					connected_weapon.new_soul.remove_status_value("time", targeted_fragments_cost)

					//update_info()
			else
				new /obj/effect/fd_sword/cannot_cast_ability(get_turf(connected_weapon.new_soul))
				connected_weapon.new_soul.balloon_alert(connected_weapon.new_soul, "Недостаточно фрагментов!", COLOR_RED)
				shake_camera(connected_weapon.new_soul, 2, 1)

				return FALSE
