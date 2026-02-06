/mob
	var/gold_worth = 0

/mob/living
	var/guessed_color

	var/havent_seen_goldensword_dom = TRUE
	var/havent_seen_goldensword_dom_explanation = TRUE
	var/jackpot_status = FALSE

/mob/proc/drop_gold()
	set waitfor = 0

	gold_worth += collected_gold
	if(gold_worth > 0)

		if(gold_worth > 10) // я боюсь за то что 90 голды просто положит сервер, так что выбить с моба можно не свыше 10-и
			gold_worth = 10

		for(var/i=0,i<gold_worth,i++)
			new /obj/effect/fd_sword/gold(get_turf(src))

		for(var/obj/effect/fd_sword/gold/G in get_turf(src))
			G.throw_atom(get_step(src, pick(GLOB.cardinals)), 3, SPEED_SLOW, src, TRUE, HIGH_LAUNCH, PASS_ALL)

/atom/movable/screen/text/screen_text/command_order/centered/fast
	fade_out_delay = 1 SECONDS
	fade_out_time = 0.3 SECONDS
	letters_per_update = 3

/mob/living/proc/heal_parts_of_damage()

	spawn(2 SECONDS)

		apply_damage(-30, BRUTE)
		apply_damage(-30, BURN)

		set_effect(0, PARALYZE)
		set_effect(0, STUN)
		set_effect(0, DAZE)
		ExtinguishMob()
		fire_stacks = 0

		// fix blindness and deafness
		blinded = FALSE
		SetEyeBlind(0)
		SetEyeBlur(0)
		SetEarDeafness(0)
		ear_damage = 0
		paralyzed = 0
		confused = 0
		druggy = 0

		nutrition = NUTRITION_NORMAL
		bodytemperature = T37C
		recalculate_move_delay = TRUE
		sdisabilities = 0
		disabilities = 0
		drowsiness = 0
		hallucination = 0
		jitteriness = 0
		dizziness = 0
		stamina.apply_damage(-stamina.max_stamina)

		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			H.restore_blood()
			H.reagents.clear_reagents()
			SShuman.processable_human_list |= H
			H.undefibbable = FALSE
			H.chestburst = 0
			H.update_headshot_overlay()

		restore_all_organs()

		active_surgeries = DEFENSE_ZONES_LIVING
		initialize_incision_depths()
		remove_surgery_overlays()

		set_stat(CONSCIOUS)
		regenerate_all_icons()

/atom/movable/screen/text/screen_text/command_order/centered
	screen_loc = "CENTER-7,CENTER"

/mob/living/proc/gambling_buff()
	rejuvenate()

/mob/living/proc/gambling_ownerbuff()
	var/list/tempo_list = list()

	for(var/mob/living/L in range(14, src))
		tempo_list += L

	add_filter("jackpot", 1, list("type" = "outline", "color" = "#ffae00", "size" = 1))
	rejuvenate()
	jackpot_status = TRUE

	for(var/mob/living/L in tempo_list)
		if(!L.client)
			continue

		if(L == src && !havent_seen_goldensword_dom_explanation)
			playsound_client(L.client, 'code/modules/fd_sword/sounds/invincible_gambler2.mp3', L, 25, 0)

		if(havent_seen_goldensword_dom_explanation)
			L.havent_seen_goldensword_dom_explanation = FALSE

			L.play_screen_text(text = "Успешно раскрыв заданный цвет во время действия <b>воплощённого концепта</b>...", alert_type = /atom/movable/screen/text/screen_text/command_order/centered, override_color = "#ffffff")

			spawn(6 SECONDS)
				L.play_screen_text(text = "...в качестве выигрыша на следующие 3 минуты и 33 секунды <b>[src]</b> становится...", alert_type = /atom/movable/screen/text/screen_text/command_order/centered, override_color = "#ffffff")

			spawn(12 SECONDS)
				playsound_client(L.client, 'code/modules/fd_sword/sounds/invincible_gambler2.mp3', L, 25, 0)
				L.play_screen_text(text = "<span class='corp_label_gold'><b>ФАКТИЧЕСКИ БЕССМЕРТЕН</b></span>", alert_type = /atom/movable/screen/text/screen_text/command_order/centered, override_color = "#ffae00")

	addtimer(CALLBACK(src, PROC_REF(remove_ownerbuff)), 213 SECONDS)
/mob/living/proc/remove_ownerbuff()

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		H.sword_usage_current = 0

	jackpot_status = FALSE
	remove_filter("jackpot", 1, list("type" = "outline", "color" = "#ffae00", "size" = 1))

/mob/living/proc/gambling_debuff()
	var/list/organs_to_remove = list()

	if(istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src

		if(H.has_limb("l_hand"))
			organs_to_remove += "l_hand"
		if(H.has_limb("r_hand"))
			organs_to_remove += "r_hand"

		if(H.has_limb("l_arm") && !H.has_limb("l_hand"))
			organs_to_remove += "l_arm"
		if(H.has_limb("r_arm") && !H.has_limb("r_hand"))
			organs_to_remove += "r_arm"

		if(length(organs_to_remove))
			var/obj/limb/limb = H.get_limb(pick(organs_to_remove))
			limb.droplimb(FALSE, FALSE, "gambling")
			shake_camera(H, 2, 1)

			playsound(H, 'sound/weapons/alien_tail_attack.ogg', 100, TRUE)
		else
			var/obj/limb/chest/mob_chest = locate(/obj/limb/chest) in H.limbs
			mob_chest.add_bleeding(damage_amount = 100)
			shake_camera(H, 2, 1)

			playsound(H, 'sound/effects/splat.ogg', 100, TRUE)
			H.say("!сплёвывает огромное количество крови.")

		H.apply_effect(30, AGONY)
		H.apply_effect(10, STUN)
	else
		apply_effect(10, STUN)
		apply_damage(50, BRUTE)

/atom/movable/screen/fullscreen/goldensword_dom
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "hakari_domain"

	screen_loc = "WEST,SOUTH to EAST,NORTH"

	plane = 4
	layer = 4

/obj/item/weapon/sword/fd_sword/goldensword
	icon_state = "goldensword"
	techniques = list(/datum/sword_tech/goldensword)

/obj/item/weapon/sword/fd_sword/goldensword/attack(mob/target, mob/user)
	. = ..()

	if(target.collected_gold > 0)
		target.remove_status_value("gold", 1)

		var/obj/spawned_gold = new /obj/effect/fd_sword/gold(get_turf(target))
		spawned_gold.throw_atom(get_step(target, pick(GLOB.cardinals)), 3, SPEED_SLOW, src, TRUE, HIGH_LAUNCH, PASS_ALL)

/datum/sword_tech/goldensword
	name = "КОНЦЕПЦИЯ: Беспечность"

	var/already_spawned_some_gold = FALSE
	var/overtime_at = 50
	var/overtime_reached = FALSE

	traverse_ability_cooldown = 2 SECONDS
	traverse_ability_cost = 2
	var/dance_cost = 5

	traverse_ability_name = "ТАНЕЦ: БУГИ-ВУГИ"
	traverse_ability_desc = "Меняет первый и второй номер местами ценою 5 монет из вашего запаса"

	ranged_ability_cooldown = 10 SECONDS
	ranged_ability_cost = 2

	ranged_ability_name = "ПОДГОТОВКА: ТЯЖЁЛЫЕ КАРМАНЫ"
	ranged_ability_desc = "Говорят, что плохому танцору яйца мешают, а у нас - деньги. Помечает и временно ослабляет всех противников, количество монет у которых больше чем 5"

	aoe_ability_cooldown = 10 SECONDS
	aoe_ability_cost = 4
	var/bet_cost = 10
	var/reroll_cost = 5

	var/keep_spinning = FALSE
	var/rerolling = FALSE
	var/obj/effect/fd_sword/goldensword_fake/fakesword = null
	var/additional_angle = 0

	aoe_ability_name = "ВОПЛОЩЕНИЕ КОНЦЕПЦИИ: МАКСИМАЛЬНАЯ СТАВКА"
	aoe_ability_desc = "Останавливает мир вокруг вас на время вращения рулетки. Загадывается случайное число в диапазоне от 1 до 6 и все участники включая вас должны угадать какое. В зависимости от результата ставки вы можете как получить определённые бонусы, так и серьёзно пострадать"

	targeted_ability_cost = 0

	targeted_ability_name = "ПОДГОТОВКА: ВЫБОР ПАРТНЁРА"
	targeted_ability_desc = "Нажимая по другому живому существу на дистанции более метра ИЛИ по самому себе - вы присваиваете ему первый или второй номер. Это не тратит ровным счётом ничего и используется способностью перемещения"

	var/mob/living/swap_target_1
	var/mob/living/swap_target_2

	var/list/bombs_pool = list()

/datum/sword_tech/goldensword/Initialize()
	. = ..()

	START_PROCESSING(SSobj, src)

/datum/sword_tech/goldensword/process(delta_time)

	if(connected_weapon.new_soul.stat == DEAD && connected_weapon.new_soul.circle_stacks > 0)
		connected_weapon.new_soul.remove_status_value("rejuv", 1)
		connected_weapon.new_soul.rejuvenate()

	if(connected_weapon.new_soul.collected_gold >= 100)
		connected_weapon.new_soul.set_status_value("gold", 0)
		overtime_at = 50
		connected_weapon.new_soul.add_status_value("rejuv", 1)

		connected_weapon.new_soul.play_screen_text(text = "<b>НОВЫЙ КРУГ!</b>", alert_type = /atom/movable/screen/text/screen_text/command_order/centered, override_color = "#ffae00")

	if(connected_weapon.new_soul.collected_gold >= overtime_at && !overtime_reached)
		overtime_reached = TRUE
		overtime_at += 50

	if(connected_weapon.new_soul.sword_combat_active && connected_weapon.new_soul.current_active_technique == src)
		if(!already_spawned_some_gold)
			spawn_gold()

/datum/sword_tech/goldensword/proc/spawn_gold()
	already_spawned_some_gold = TRUE
	var/list/turfs = list()

	if(overtime_reached)
		overtime_reached = FALSE

		var/turf/north = get_ranged_target_turf(connected_weapon.new_soul, NORTH, 7)
		var/turf/south = get_ranged_target_turf(connected_weapon.new_soul, SOUTH, 7)
		var/turf/west = get_ranged_target_turf(connected_weapon.new_soul, WEST, 7)
		var/turf/east = get_ranged_target_turf(connected_weapon.new_soul, EAST, 7)

		for(var/turf/T in get_line(connected_weapon.new_soul, north))
			if(T.density)
				continue
			if(connected_weapon.new_soul in T)
				continue
			turfs += T
		for(var/turf/T in get_line(connected_weapon.new_soul, south))
			if(T.density)
				continue
			if(connected_weapon.new_soul in T)
				continue
			turfs += T
		for(var/turf/T in get_line(connected_weapon.new_soul, west))
			if(T.density)
				continue
			if(connected_weapon.new_soul in T)
				continue
			turfs += T
		for(var/turf/T in get_line(connected_weapon.new_soul, east))
			if(T.density)
				continue
			if(connected_weapon.new_soul in T)
				continue
			turfs += T

		for(var/turf/T in turfs)
			new /obj/effect/fd_sword/gold(T)

	else
		for(var/turf/T in orange(9, connected_weapon.new_soul))
			if(T.density)
				continue
			if(connected_weapon.new_soul in T)
				continue
			turfs += T

		for(var/i=0, i<5, i++)
			var/turf/place_on = pick(turfs)

			turfs -= place_on
			new /obj/effect/fd_sword/gold(place_on)

	addtimer(CALLBACK(src, PROC_REF(reset_goldspawn)), 1 SECONDS)

/datum/sword_tech/goldensword/proc/reset_goldspawn()
	already_spawned_some_gold = FALSE

/datum/sword_tech/goldensword/proc/swordspin()
	set waitfor = 0

	if(additional_angle == 360)
		additional_angle = 0

	if(!keep_spinning)
		additional_angle = 0
		qdel(fakesword)

	animate(fakesword, transform = matrix(90 + additional_angle, MATRIX_ROTATE), time = 0.3 SECONDS, easing = EASE_IN)
	additional_angle += 90

	spawn(0.5 SECONDS)
		swordspin()

/datum/sword_tech/goldensword/traverse_ability_check()
	if(connected_weapon.new_soul.collected_gold < dance_cost)
		new /obj/effect/fd_sword/cannot_cast_ability(get_turf(connected_weapon.new_soul))
		connected_weapon.new_soul.balloon_alert(connected_weapon.new_soul, "Недостаточно средств!", COLOR_RED)
		shake_camera(connected_weapon.new_soul, 2, 1)
		return FALSE

	if(isnull(swap_target_1) || isnull(swap_target_2))
		new /obj/effect/fd_sword/cannot_cast_ability(get_turf(connected_weapon.new_soul))
		connected_weapon.new_soul.balloon_alert(connected_weapon.new_soul, "Для танца нужно минимум два человека!", COLOR_RED)
		shake_camera(connected_weapon.new_soul, 2, 1)
		return FALSE

	. = ..()

/datum/sword_tech/goldensword/use_traverse_ability()
	connected_weapon.new_soul.collected_gold -= dance_cost

	playsound(connected_weapon.new_soul, 'code/modules/fd_sword/sounds/dice_roll.wav', 100, 0)
	connected_weapon.new_soul.balloon_alert_to_viewers("*[connected_weapon.new_soul] щёлкнул пальцами*", null, DEFAULT_MESSAGE_RANGE, null, COLOR_WHITE)

	var/turf/first = get_turf(swap_target_1)
	var/turf/second = get_turf(swap_target_2)

	swap_target_1.alpha = 0
	new /obj/effect/fd_sword/lightning(first)

	swap_target_2.alpha = 0
	new /obj/effect/fd_sword/lightning(second)

	spawn(0.5 SECONDS)
		new /obj/effect/fd_sword/lightning(first)
		new /obj/effect/fd_sword/lightning(second)

	spawn(0.7 SECONDS)
		swap_target_1.alpha = 255
		swap_target_1.forceMove(second)
		swap_target_2.alpha = 255
		swap_target_2.forceMove(first)

/datum/sword_tech/goldensword/use_ranged_ability()
	var/list/target_turfs = list()
	var/list/remove_filter_later = list()

	for(var/obj/effect/fd_sword/gold_bomb/G in bombs_pool)
		G.trigger()
		bombs_pool -= G

	for(var/turf/T in orange(7, connected_weapon.new_soul))
		if(connected_weapon.new_soul in T)
			continue

		for(var/mob/living/L in T)

			// ДЛЯ СОЮЗНИКОВ //
			if(L.srd_faction == connected_weapon.new_soul.srd_faction && L != connected_weapon.new_soul)
				continue
			// ДЛЯ СОЮЗНИКОВ //

			if(L.collected_gold > 5)
				for(var/turf/attack_zone in range(1,L))
					new /obj/effect/fd_sword/telegraph_basic/goldensword/ranged(attack_zone)

					target_turfs += attack_zone

	spawn(0.5 SECONDS)
		for(var/turf/T in target_turfs)
			for(var/mob/living/L in T)
				L.apply_effect(20, SLOW)
				L.add_filter("greedy", 1, list("type" = "outline", "color" = "#ff0000", "size" = 1))

				L.throw_atom(connected_weapon.new_soul, 3, SPEED_FAST, src, FALSE, HIGH_LAUNCH, PASS_ALL)

				remove_filter_later += L

	spawn(1 SECONDS)
		for(var/mob/living/L in remove_filter_later)
			L.remove_filter("greedy", 1, list("type" = "outline", "color" = "#ff0000", "size" = 1))

/datum/sword_tech/goldensword/aoe_ability_check()
	if(connected_weapon.new_soul.collected_gold < bet_cost && !rerolling)
		new /obj/effect/fd_sword/cannot_cast_ability(get_turf(connected_weapon.new_soul))
		connected_weapon.new_soul.balloon_alert(connected_weapon.new_soul, "Недостаточно средств!", COLOR_RED)
		shake_camera(connected_weapon.new_soul, 2, 1)
		return FALSE

	. = ..()

/datum/sword_tech/goldensword/use_aoe_ability()
	if(rerolling)
		rerolling = FALSE

	if(!rerolling)
		connected_weapon.new_soul.remove_status_value("gold", bet_cost)

	keep_spinning = TRUE
	playsound(connected_weapon.new_soul, 'code/modules/fd_sword/sounds/goldsword_dom.mp3', 80, 0)

	if(!isnull(fakesword))
		fakesword = null

	fakesword = new /obj/effect/fd_sword/goldensword_fake(get_turf(connected_weapon.new_soul))

	ADD_TRAIT(connected_weapon.new_soul, TRAIT_IMMOBILIZED, GOLDENCASINO_TRAIT)

	animate(fakesword, alpha = 255, time = 1 SECONDS, flags = ANIMATION_PARALLEL)
	animate(fakesword, pixel_y = 32, time = 1 SECONDS, easing = SINE_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)

	if(connected_weapon.new_soul.havent_seen_goldensword_dom)
		connected_weapon.new_soul.say("Воплощение концепта...")

	sleep(2 SECONDS)
	swordspin()

	for(var/mob/living/L in range(7,connected_weapon.new_soul))

		var/x_offset = (connected_weapon.new_soul.x - L.x) * 32
		var/y_offset = (connected_weapon.new_soul.y - L.y) * 32

		if(L != connected_weapon.new_soul && L.client)
			animate(L.client, pixel_x = x_offset, pixel_y = y_offset, time = 6 SECONDS, easing = CUBIC_EASING)

		ADD_TRAIT(L, TRAIT_IMMOBILIZED, GOLDENCASINO_TRAIT)
		L.mouse_opacity = FALSE
		L.anchored = TRUE

		L.overlay_fullscreen("domain", /atom/movable/screen/fullscreen/goldensword_dom)
		L.plane = 5

		if(L.havent_seen_goldensword_dom)
			L.play_screen_text(text = "...<b>МАКСИМАЛЬНАЯ СТАВКА</b>!", alert_type = /atom/movable/screen/text/screen_text/command_order/centered, override_color = "#ffae00")
			L.havent_seen_goldensword_dom = FALSE

		playsound_client(L.client, 'code/modules/fd_sword/sounds/dice_roll.wav', L, 100, 0)

	sleep(5 SECONDS)

	var/list/players = list()
	var/correct_color = pick("GREEN","RED")

	var/list/color_selection = list("GREEN" = image(icon = 'code/modules/fd_sword/icons/visuals.dmi', icon_state = "green"),
									"RED" = image(icon = 'code/modules/fd_sword/icons/visuals.dmi', icon_state = "red"))

	var/list/afteroptions = list("REROLL" = image(icon = 'code/modules/fd_sword/icons/visuals.dmi', icon_state = "reroll"),
								"PASS" = image(icon = 'code/modules/fd_sword/icons/visuals.dmi', icon_state = "pass"))

	playsound(connected_weapon.new_soul, 'sound/machines/slotmachine/bigwin-slotmachine.ogg', 50)

	for(var/mob/living/L in range(7,connected_weapon.new_soul))

		if(L.client)
			L.play_screen_text(text = "КАЗИНО ЗАГАДАЛО ЦВЕТ...", alert_type = /atom/movable/screen/text/screen_text/command_order, override_color = "#ffffff")

			L.guessed_color = show_radial_menu(L, L, color_selection, tooltips = TRUE, radius = 60)
			if(!L.guessed_color)
				L.guessed_color = pick("GREEN","RED")

			players += L

		else
			players += L
			L.guessed_color = pick("GREEN","RED")

		switch(L.guessed_color)
			if("GREEN")
				new /obj/effect/fd_sword/goldensword_greencard(get_turf(L))
			else
				new /obj/effect/fd_sword/goldensword_redcard(get_turf(L))

	sleep(5 SECONDS)

	for(var/mob/living/L in players)

		if(L.guessed_color != correct_color)
			playsound_client(L.client, 'code/modules/fd_sword/sounds/failure.wav', L, 100, 0, 1)
			shake_camera(L, 2, 1)

			L.add_filter("wrong", 1, list("type" = "outline", "color" = "#ff0000", "size" = 1))

		switch(correct_color)
			if("GREEN")
				L.play_screen_text(text = "...И ЭТО <span class='corp_label_green'><b>[correct_color]</b></span>!", alert_type = /atom/movable/screen/text/screen_text/command_order/centered, override_color = "#ffae00")
			if("RED")
				L.play_screen_text(text = "...И ЭТО <span class='corp_label_red'><b>[correct_color]</b></span>!", alert_type = /atom/movable/screen/text/screen_text/command_order/centered, override_color = "#ffae00")

	sleep(5 SECONDS)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	if(connected_weapon.new_soul.guessed_color != correct_color && connected_weapon.new_soul.collected_gold >= reroll_cost)
		connected_weapon.new_soul.play_screen_text(text = "ХОТИТЕ СДЕЛАТЬ <b>ПОВТОРНУЮ СТАВКУ</b>?", alert_type = /atom/movable/screen/text/screen_text/command_order, override_color = "#ffffff")
		var/answer = show_radial_menu(connected_weapon.new_soul, connected_weapon.new_soul, afteroptions, tooltips = TRUE, radius = 30)

		if(answer)
			switch(answer)
				if("REROLL")
					for(var/mob/living/L in players)
						L.play_screen_text(text = "<b>[connected_weapon.new_soul]</b> КРУТИТ БАРАБАН СНОВА!", alert_type = /atom/movable/screen/text/screen_text/command_order/centered, override_color = "#ffae00")
						connected_weapon.new_soul.remove_status_value("gold", reroll_cost)

						playsound_client(L.client, 'sound/machines/slotmachine/rolling-slotmachine.ogg', L, 50)

						L.remove_filter("wrong", 1, list("type" = "outline", "color" = "#ff0000", "size" = 1))
						L.clear_fullscreen("domain")
						L.plane = initial(L.plane)

						REMOVE_TRAIT(L, TRAIT_IMMOBILIZED, GOLDENCASINO_TRAIT)
						L.mouse_opacity = TRUE
						L.anchored = FALSE

						if(L.client)
							animate(L.client, pixel_x = 0, pixel_y = 0, time = 6 SECONDS, easing = CUBIC_EASING)

					rerolling = TRUE
					keep_spinning = FALSE
					qdel(fakesword)
					sleep(4 SECONDS)

					aoe_ability_check()
					return FALSE
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	for(var/mob/living/L in players)

		L.remove_filter("wrong", 1, list("type" = "outline", "color" = "#ff0000", "size" = 1))
		L.clear_fullscreen("domain")
		L.plane = initial(L.plane)

		REMOVE_TRAIT(L, TRAIT_IMMOBILIZED, GOLDENCASINO_TRAIT)
		L.mouse_opacity = TRUE
		L.anchored = FALSE

		if(L.client)
			animate(L.client, pixel_x = 0, pixel_y = 0, time = 6 SECONDS, easing = CUBIC_EASING)

		if(L.guessed_color != correct_color)

			// ДЛЯ СОЮЗНИКОВ //
			if(L.srd_faction == connected_weapon.new_soul.srd_faction && L != connected_weapon.new_soul)
				continue
			// ДЛЯ СОЮЗНИКОВ //

			L.gambling_debuff()
		else
			if(L == connected_weapon.new_soul)
				// вставить сюда визуальную отметку джекпота
				L.gambling_ownerbuff()
			else
				// вставить сюда визуальную отметку успеха
				L.gambling_buff()

	qdel(fakesword)
	keep_spinning = FALSE

/obj/structure/machinery/vending/proc/throw_item_until_empty()
	var/obj/throw_item = null

	for(var/datum/data/vending_product/product in product_records)
		if (product.amount <= 0) //Try to use a record that actually has something to dump.
			continue
		var/dump_path = product.product_path
		if (!dump_path)
			continue

		product.amount--
		throw_item = release_item(product, 0)
		break
	if (!throw_item)
		return 0

	animate(src, transform = matrix(rand(-3,3), rand(-3,3), MATRIX_TRANSLATE), time = 0.5, easing = EASE_IN)
	for(var/i in 0 to 10)
		animate(transform = matrix(rand(-4,4), rand(-4,4), MATRIX_TRANSLATE), time = 1)
	animate(transform = matrix(0, 0, MATRIX_TRANSLATE), time = 0.5, easing = EASE_OUT)

	INVOKE_ASYNC(throw_item, /atom/movable/proc/throw_atom, get_step(src, pick(GLOB.cardinals)), 16, SPEED_AVERAGE, src)
	playsound(src, "sound/machines/vending.ogg", 40, TRUE)

	spawn(0.5 SECONDS)
		throw_item_until_empty()

/datum/sword_tech/goldensword/use_targeted_ability(atom/target)
	if(!connected_weapon.new_soul.get_active_hand())

		if(istype(target, /obj/structure/machinery/vending))
			var/obj/structure/machinery/vending/V = target
			if(get_dist(V, connected_weapon.new_soul) <= 1)

				new /obj/effect/fd_sword/targeted_ability(get_turf(V))
				V.throw_item_until_empty()

				connected_weapon.new_soul.add_sword_usage(1)

				connected_weapon.new_soul.hud_used.sword_usage_stat.update_stat(connected_weapon.new_soul)
				connected_weapon.new_soul.hud_used.sword_limit_stat.update_stat(connected_weapon.new_soul)

		if(istype(target, /turf/))
			if(get_dist(target, connected_weapon.new_soul) > 1)
				if(connected_weapon.new_soul.collected_gold < 5)
					new /obj/effect/fd_sword/cannot_cast_ability(get_turf(connected_weapon.new_soul))
					connected_weapon.new_soul.balloon_alert(connected_weapon.new_soul, "Недостаточно средств!", COLOR_RED)
					shake_camera(connected_weapon.new_soul, 2, 1)
					return FALSE

				var/turf/open/floor/T = target

				var/obj/effect/fd_sword/gold_bomb/G = new /obj/effect/fd_sword/gold_bomb(get_turf(connected_weapon.new_soul))
				G.related_faction = connected_weapon.new_soul.srd_faction
				bombs_pool += G

				G.throw_atom(T, get_dist(T, connected_weapon.new_soul), SPEED_FAST, src, FALSE, HIGH_LAUNCH, PASS_ALL)

				connected_weapon.new_soul.remove_status_value("gold", 5)

		if(istype(target, /mob/living/))
			var/mob/living/H = target

			if(get_dist(target, connected_weapon.new_soul) > 1 || target == connected_weapon.new_soul)
				new /obj/effect/fd_sword/targeted_ability(get_turf(H))

				if(isnull(swap_target_1))
					swap_target_1 = H
					connected_weapon.new_soul.balloon_alert(connected_weapon.new_soul, "Ты выделил [H] первым участником!", COLOR_ORANGE)
					return TRUE
				if(isnull(swap_target_2))
					if(H == swap_target_1)
						return FALSE
					swap_target_2 = H
					connected_weapon.new_soul.balloon_alert(connected_weapon.new_soul, "Ты выделил [H] вторым участником!", COLOR_ORANGE)
					return TRUE

				if(!isnull(swap_target_1) && !isnull(swap_target_2))
					swap_target_1 = H
					swap_target_2 = null
					connected_weapon.new_soul.balloon_alert(connected_weapon.new_soul, "Ты выделил [H] первым участником!", COLOR_ORANGE)
					return TRUE
