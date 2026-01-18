/mob
	var/collected_gold = 0
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
			G.throw_atom(get_edge_target_turf(G, get_dir(src, G)), 3, SPEED_SLOW, src, TRUE, HIGH_LAUNCH, PASS_ALL)


/obj/effect/fd_sword/gold
	name = "money"
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "money"

	anchored = TRUE
	mouse_opacity = FALSE

	alpha = 0

/obj/effect/fd_sword/gold/Initialize(mapload, ...)
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS)

	spawn(5 SECONDS)
		animate(src, alpha = 0, time = 0.2 SECONDS)
	spawn(5.2 SECONDS)
		qdel(src)

/obj/effect/fd_sword/gold/Crossed(O)
	. = ..()

	if(istype(O, /mob/living))
		var/mob/living/L = O
		L.collected_gold += 1

		playsound_client(L.client, 'sound/machines/pda_ping.ogg', L, 25)

	animate(src, alpha = 0, time = 0.2 SECONDS)
	spawn(0.3 SECONDS)
		qdel(src)

/mob/living/proc/heal_parts_of_damage()

	spawn(2 SECONDS)

		apply_damage(-30, BRUTE)
		apply_damage(-30, BURN)
		apply_damage(-30, TOX)

		apply_damage(2, OXY)

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

/mob/living/proc/gambling_ownerbuff()
	var/list/tempo_list = list()

	for(var/mob/living/L in range(14, src))
		tempo_list += L

	rejuvenate()
	jackpot_status = TRUE

	for(var/mob/living/L in tempo_list)
		if(L == src && !havent_seen_goldensword_dom_explanation)
			playsound_client(L.client, 'code/modules/fd_sword/sounds/invincible_gambler2.mp3', L, 25, 0)

		if(havent_seen_goldensword_dom_explanation)
			L.havent_seen_goldensword_dom_explanation = FALSE

			L.play_screen_text(text = "Успешно раскрыв заданный цвет во время действия <b>воплощённого концепта</b> богатства...", alert_type = /atom/movable/screen/text/screen_text/command_order/centered, override_color = "#ffffff")

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

/mob/living/proc/gambling_debuff()

/atom/movable/screen/fullscreen/goldensword_dom
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "hakari_domain"

	screen_loc = "WEST,SOUTH to EAST,NORTH"

	plane = 4
	layer = 4

/obj/effect/fd_sword/goldensword_fake
	name = "combat sword"
	icon = 'code/modules/fd_sword/icons/swords.dmi'
	icon_state = "goldensword"

	anchored = TRUE
	mouse_opacity = FALSE
	layer = 5
	plane = 5

	alpha = 0

/obj/effect/fd_sword/goldensword_greencard
	name = "GREEN"
	icon = 'code/modules/fd_sword/icons/swords.dmi'
	icon_state = "green"

	anchored = TRUE
	mouse_opacity = FALSE
	layer = 5
	plane = 5

	alpha = 0

/obj/effect/fd_sword/goldensword_greencard/Initialize(mapload, ...)
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS, flags = ANIMATION_PARALLEL)
	animate(src, pixel_y = 32, time = 0.5 SECONDS, easing = SINE_EASING|EASE_IN, flags = ANIMATION_PARALLEL)

	spawn(0.5 SECONDS)
		animate(src, alpha = 0, time = 0.3 SECONDS)

	spawn(0.8 SECONDS)
		qdel(src)

/obj/effect/fd_sword/goldensword_redcard
	name = "RED"
	icon = 'code/modules/fd_sword/icons/swords.dmi'
	icon_state = "red"

	anchored = TRUE
	mouse_opacity = FALSE
	layer = 5
	plane = 5

	alpha = 0

/obj/effect/fd_sword/goldensword_redcard/Initialize(mapload, ...)
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS, flags = ANIMATION_PARALLEL)
	animate(src, pixel_y = 32, time = 0.5 SECONDS, easing = SINE_EASING|EASE_IN, flags = ANIMATION_PARALLEL)

	spawn(0.5 SECONDS)
		animate(src, alpha = 0, time = 0.3 SECONDS)

	spawn(0.8 SECONDS)
		qdel(src)

/obj/item/weapon/sword/fd_sword/goldensword
	icon_state = "goldensword"
	techniques = list(/datum/sword_tech/goldensword)

/datum/sword_tech/goldensword
	name = "КОНЦЕПЦИЯ: Богатство"

	var/already_spawned_some_gold = FALSE

	traverse_ability_cost = 2
	var/mob/living/insurance_agent = null
	var/insurance_cost = 5
	var/additional_death_penalty = 5

	traverse_ability_name = "СТРАХОВКА"
	traverse_ability_desc = "Возвращает вас к предварительно помеченному страховому агенту, восстанавливая всё здоровье в обмен на некоторую часть вашего капитала. Применимо даже после смерти!"

	ranged_ability_cooldown = 10 SECONDS
	ranged_ability_cost = 2

	ranged_ability_name = "ОСОБОЕ ПРЕДЛОЖЕНИЕ"
	ranged_ability_desc = "Притягивает к вам первого противника стоявшего на прямой линии вашего взгляда"

	aoe_ability_cooldown = 10 SECONDS
	aoe_ability_cost = 4
	var/bet_cost = 10
	var/reroll_cost = 5

	var/keep_spinning = FALSE
	var/obj/effect/fd_sword/goldensword_fake/fakesword = null
	var/additional_angle = 0

	aoe_ability_name = "СТАВКА"
	aoe_ability_desc = "Останавливает мир вокруг вас на время вращения рулетки. Загадывается случайное число в диапазоне от 1 до 6 и все участники включая вас должны угадать какое. В зависимости от результата ставки вы можете как получить определённые бонусы, так и серьёзно пострадать"

	targeted_ability_cost = 0

	targeted_ability_name = "КОНТРАКТ"
	targeted_ability_desc = "Нажимая по другому живому существу - вы заключаете с ним единоразовый страховой контракт, который затем можете применить в любой удобный для вас момент. Даже с того света"

/datum/sword_tech/goldensword/Initialize()
	. = ..()

	START_PROCESSING(SSobj, src)

/datum/sword_tech/goldensword/process(delta_time)

	if(connected_weapon.new_soul.sword_combat_active && connected_weapon.new_soul.current_active_technique == src)
		if(!already_spawned_some_gold)
			spawn_gold()

/datum/sword_tech/goldensword/proc/spawn_gold()
	already_spawned_some_gold = TRUE
	var/list/turfs = list()

	for(var/turf/T in orange(9, connected_weapon.new_soul))
		if(T.density)
			continue
		turfs += T

	for(var/i=0, i<5, i++)
		var/turf/place_on = pick(turfs)

		turfs -= place_on
		new /obj/effect/fd_sword/gold(place_on)

	addtimer(CALLBACK(src, PROC_REF(reset_goldspawn)), 5 SECONDS)

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

/datum/sword_tech/goldensword/aoe_ability_check()
	if(connected_weapon.new_soul.collected_gold < bet_cost)
		new /obj/effect/fd_sword/cannot_cast_ability(get_turf(connected_weapon.new_soul))
		connected_weapon.new_soul.balloon_alert(connected_weapon.new_soul, "Недостаточно средств!", COLOR_RED)
		shake_camera(connected_weapon.new_soul, 2, 1)
		return FALSE

	. = ..()

/datum/sword_tech/goldensword/use_aoe_ability()
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
			L.play_screen_text(text = "...<b>ЗОЛОТО ДУРАКОВ</b>!", alert_type = /atom/movable/screen/text/screen_text/command_order/centered, override_color = "#ffae00")
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
						connected_weapon.new_soul.collected_gold -= reroll_cost

						playsound_client(L.client, 'sound/machines/slotmachine/rolling-slotmachine.ogg', L, 50)

						L.remove_filter("wrong", 1, list("type" = "outline", "color" = "#ff0000", "size" = 1))
						keep_spinning = FALSE
						qdel(fakesword)

						sleep(4 SECONDS)

						aoe_ability_check()
						return FALSE
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	for(var/mob/living/L in players)
		if(L.guessed_color != correct_color)
			// вставить сюда визуальную отметку проигрыша
			L.gambling_debuff()
		else
			if(L == connected_weapon.new_soul)
				// вставить сюда визуальную отметку джекпота
				L.gambling_ownerbuff()
			else
				// вставить сюда визуальную отметку успеха
				L.gambling_buff()

		L.remove_filter("wrong", 1, list("type" = "outline", "color" = "#ff0000", "size" = 1))
		L.clear_fullscreen("domain")
		L.plane = initial(L.plane)

		REMOVE_TRAIT(L, TRAIT_IMMOBILIZED, GOLDENCASINO_TRAIT)
		L.mouse_opacity = TRUE
		L.anchored = FALSE

		animate(L.client, pixel_x = 0, pixel_y = 0, time = 6 SECONDS, easing = CUBIC_EASING)

	qdel(fakesword)
	keep_spinning = FALSE
