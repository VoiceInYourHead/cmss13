/mob/living
	var/collected_gold = 0
	var/gold_worth = 0

	var/guessed_number = 1

/mob/living/proc/gambling_buff()
/mob/living/proc/gambling_ownerbuff()
/mob/living/proc/gambling_debuff()

/atom/movable/screen/fullscreen/goldensword_dom
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "hakari_domain"

	plane = 44
	layer = 3

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

	aoe_ability_name = "СТАВКА"
	aoe_ability_desc = "Останавливает мир вокруг вас на время вращения рулетки. Загадывается случайное число в диапазоне от 1 до 6 и все участники включая вас должны угадать какое. В зависимости от результата ставки вы можете как получить определённые бонусы, так и серьёзно пострадать"

	targeted_ability_cost = 0

	targeted_ability_name = "КОНТРАКТ"
	targeted_ability_desc = "Нажимая по другому живому существу - вы заключаете с ним единоразовый страховой контракт, который затем можете применить в любой удобный для вас момент. Даже с того света"

/datum/sword_tech/goldensword/proc/swordspin()

	animate(connected_weapon, transform = matrix(90, MATRIX_ROTATE), time = 0.5 SECONDS, easing = EASE_IN)

	if(keep_spinning)
		swordspin()

/datum/sword_tech/goldensword/use_aoe_ability()
	keep_spinning = TRUE
	swordspin()

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
		L.overlay_fullscreen("domain", /atom/movable/screen/fullscreen/goldensword_dom)
		L.plane = 45

		ADD_TRAIT(L, TRAIT_IMMOBILIZED, GOLDENCASINO_TRAIT)

		if(L.client)
			L.play_screen_text(text = "КАЗИНО НАЗВАЛО ЦИФРУ...", alert_type = /atom/movable/screen/text/screen_text/command_order, override_color = "#ffae00")

			L.guessed_number = show_radial_menu(L, L, number_selection, tooltips = TRUE, radius = 60)
			if(!L.guessed_number)
				L.guessed_number = pick("1","2","3","4","5","6")

			players += L

		else
			players += L
			L.guessed_number = pick("1","2","3","4","5","6")

	for(var/mob/living/L in players)
		L.play_screen_text(text = "...И ЭТО ЦИФРА [correct_number]!", alert_type = /atom/movable/screen/text/screen_text/command_order, override_color = "#ffae00")

	for(connected_weapon.new_soul in players)
		if(connected_weapon.new_soul.guessed_number != correct_number && connected_weapon.new_soul.collected_gold >= reroll_cost)
			connected_weapon.new_soul.play_screen_text(text = "ХОТИТЕ СОВЕРШИТЬ ПОВТОРНУЮ КРУТКУ?", alert_type = /atom/movable/screen/text/screen_text/command_order, override_color = "#ffae00")
			var/answer = show_radial_menu(connected_weapon.new_soul, connected_weapon.new_soul, afteroptions, tooltips = TRUE, radius = 30)

			if(!answer)
				continue
			switch(answer)
				if("REROLL")
					for(var/mob/living/L in players)
						L.play_screen_text(text = "[connected_weapon.new_soul] КРУТИТ БАРАБАН СНОВА!", alert_type = /atom/movable/screen/text/screen_text/command_order, override_color = "#ffae00")
						connected_weapon.new_soul.collected_gold -= reroll_cost

						aoe_ability_check()
						return FALSE
				if("PASS")
					continue

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

	keep_spinning = FALSE
