/mob/living
	var/collected_gold = 0
	var/gold_worth = 0

	var/guessed_number = 1

	var/havent_seen_goldensword_dom = TRUE
	var/jackpot_status = FALSE

/atom/movable/screen/text/screen_text/command_order/centered
	screen_loc = "CENTER,CENTER"

/mob/living/proc/gambling_buff()

/mob/living/proc/gambling_ownerbuff()

	for(var/mob/living/L in view(src))
		if(havent_seen_goldensword_dom)
			L.havent_seen_goldensword_dom = FALSE

			L.play_screen_text(text = "Успешно угадав заданное число во время действия воплощённого концепта...", alert_type = /atom/movable/screen/text/screen_text/command_order/centered, override_color = "#ffffff")

			spawn(1 SECONDS)
				L.play_screen_text(text = "...в качестве выигрыша [src] получает 3 минуты и 33 секунды...", alert_type = /atom/movable/screen/text/screen_text/command_order/centered, override_color = "#ffffff")

			spawn(2 SECONDS)
				L.play_screen_text(text = "ПОЛНОЙ НЕУЯЗВИМОСТИ", alert_type = /atom/movable/screen/text/screen_text/command_order/centered, override_color = "#ffae00")

	rejuvenate()

	jackpot_status = TRUE
	status_flags |= GODMODE
	RegisterSignal(src, list(COMSIG_LIVING_FLAMER_CROSSED, COMSIG_LIVING_FLAMER_FLAMED), PROC_REF(handle_fire_protection))

	addtimer(CALLBACK(src, PROC_REF(remove_ownerbuff)), 213 SECONDS)
/mob/living/proc/remove_ownerbuff()
	var/mob/living/carbon/human/H = src

	H.rejuvenate()
	H.sword_usage_current = 0

	H.jackpot_status = FALSE

	H.status_flags &= ~(GODMODE)
	UnregisterSignal(H, list(COMSIG_LIVING_FLAMER_CROSSED, COMSIG_LIVING_FLAMER_FLAMED))

/mob/living/proc/gambling_debuff()

/atom/movable/screen/fullscreen/goldensword_dom
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "hakari_domain"

	plane = 44
	layer = 3

/obj/effect/fd_sword/goldensword_fake
	name = "combat sword"
	icon = 'code/modules/fd_sword/icons/swords.dmi'
	icon_state = "goldensword"

	anchored = TRUE
	mouse_opacity = FALSE
	layer = 5
	plane = 45

	alpha = 0

/obj/item/weapon/sword/fd_sword/goldensword
	icon_state = "goldensword"
	techniques = list(/datum/sword_tech/goldensword)

/datum/sword_tech/goldensword
	name = "КОНЦЕПЦИЯ: Богатство"

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

	aoe_ability_name = "СТАВКА"
	aoe_ability_desc = "Останавливает мир вокруг вас на время вращения рулетки. Загадывается случайное число в диапазоне от 1 до 6 и все участники включая вас должны угадать какое. В зависимости от результата ставки вы можете как получить определённые бонусы, так и серьёзно пострадать"

	targeted_ability_cost = 0

	targeted_ability_name = "КОНТРАКТ"
	targeted_ability_desc = "Нажимая по другому живому существу - вы заключаете с ним единоразовый страховой контракт, который затем можете применить в любой удобный для вас момент. Даже с того света"

/datum/sword_tech/goldensword/proc/swordspin()

	if(!keep_spinning)
		qdel(fakesword)

	animate(fakesword, transform = matrix(30, MATRIX_ROTATE), time = 0.3 SECONDS, easing = EASE_IN)
	swordspin()

/datum/sword_tech/goldensword/use_aoe_ability()
	keep_spinning = TRUE
	fakesword = new /obj/effect/fd_sword/goldensword_fake(get_turf(connected_weapon.new_soul))

	ADD_TRAIT(connected_weapon.new_soul, TRAIT_IMMOBILIZED, GOLDENCASINO_TRAIT)

	animate(fakesword, alpha = 255, time = 1 SECONDS, flags = ANIMATION_PARALLEL)
	animate(fakesword, pixel_y = 32, time = 1 SECONDS, easing = SINE_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)

	connected_weapon.new_soul.say("Воплощение концепта...")

	sleep(1 SECONDS)
	swordspin()

	for(var/mob/living/L in view(connected_weapon.new_soul))

		var/x_offset = (connected_weapon.new_soul.x - L.x) * 32
		var/y_offset = (connected_weapon.new_soul.y - L.y) * 32

		if(L != connected_weapon.new_soul)
			animate(L.client, pixel_x = x_offset, pixel_y = y_offset, time = 6 SECONDS, easing = CUBIC_EASING)

		ADD_TRAIT(L, TRAIT_IMMOBILIZED, GOLDENCASINO_TRAIT)
		L.mouse_opacity = FALSE
		L.anchored = TRUE

		L.overlay_fullscreen("domain", /atom/movable/screen/fullscreen/goldensword_dom)
		L.plane = 45

		L.play_screen_text(text = "...ЗОЛОТО ДУРАКОВ!", alert_type = /atom/movable/screen/text/screen_text/command_order/centered, override_color = "#ffae00")

	var/list/players = list()
	var/correct_number = pick("1","2","3","4","5","6") // Я боюсь что иначе оно не поймёт

	var/list/number_selection = list("1" = image(icon = 'code/modules/fd_sword/icons/visuals.dmi', icon_state = "dice_1"),
									"2" = image(icon = 'code/modules/fd_sword/icons/visuals.dmi', icon_state = "dice_2"),
									"3" = image(icon = 'code/modules/fd_sword/icons/visuals.dmi', icon_state = "dice_3"),
									"4" = image(icon = 'code/modules/fd_sword/icons/visuals.dmi', icon_state = "dice_4"),
									"5" = image(icon = 'code/modules/fd_sword/icons/visuals.dmi', icon_state = "dice_5"),
									"6" = image(icon = 'code/modules/fd_sword/icons/visuals.dmi', icon_state = "dice_6"),)

	var/list/afteroptions = list("REROLL" = image(icon = 'code/modules/fd_sword/icons/visuals.dmi', icon_state = "reroll"),
								"PASS" = image(icon = 'code/modules/fd_sword/icons/visuals.dmi', icon_state = "pass"))

	for(var/mob/living/L in view(connected_weapon.new_soul))

		if(L.client)
			L.play_screen_text(text = "КАЗИНО НАЗВАЛО ЦИФРУ...", alert_type = /atom/movable/screen/text/screen_text/command_order, override_color = "#ffffff")

			L.guessed_number = show_radial_menu(L, L, number_selection, tooltips = TRUE, radius = 60)
			if(!L.guessed_number)
				L.guessed_number = pick("1","2","3","4","5","6")

			players += L

		else
			players += L
			L.guessed_number = pick("1","2","3","4","5","6")

	for(var/mob/living/L in players)
		L.play_screen_text(text = "...И ЭТО ЦИФРА [correct_number]!", alert_type = /atom/movable/screen/text/screen_text/command_order/centered, override_color = "#ffae00")

	if(connected_weapon.new_soul.guessed_number != correct_number && connected_weapon.new_soul.collected_gold >= reroll_cost)
		connected_weapon.new_soul.play_screen_text(text = "ХОТИТЕ СОВЕРШИТЬ ПОВТОРНУЮ КРУТКУ?", alert_type = /atom/movable/screen/text/screen_text/command_order, override_color = "#ffffff")
		var/answer = show_radial_menu(connected_weapon.new_soul, connected_weapon.new_soul, afteroptions, tooltips = TRUE, radius = 30)

		if(answer)
			switch(answer)
				if("REROLL")
					for(var/mob/living/L in players)
						L.play_screen_text(text = "[connected_weapon.new_soul] КРУТИТ БАРАБАН СНОВА!", alert_type = /atom/movable/screen/text/screen_text/command_order/centered, override_color = "#ffae00")
						connected_weapon.new_soul.collected_gold -= reroll_cost
						keep_spinning = FALSE

						aoe_ability_check()
						return FALSE

	for(var/mob/living/L in players)
		if(L.guessed_number != correct_number)
			// вставить сюда визуальную отметку проигрыша
			L.gambling_debuff()
		else
			if(L == connected_weapon.new_soul)
				// вставить сюда визуальную отметку джекпота
				L.gambling_ownerbuff()
			else
				// вставить сюда визуальную отметку успеха
				L.gambling_buff()

		L.clear_fullscreen("domain")
		L.plane = initial(L.plane)

		REMOVE_TRAIT(L, TRAIT_IMMOBILIZED, GOLDENCASINO_TRAIT)
		L.mouse_opacity = TRUE
		L.anchored = FALSE

		animate(L.client, pixel_x = 0, pixel_y = 0, time = 6 SECONDS, easing = CUBIC_EASING)

	keep_spinning = FALSE
