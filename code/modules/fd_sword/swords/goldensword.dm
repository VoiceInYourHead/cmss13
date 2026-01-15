/mob/living
	var/collected_gold = 0
	var/gold_worth = 0

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
	ranged_ability_desc = "Притягивает к вам первого противника стоящего на прямой линии вашего взгляда"

	aoe_ability_cooldown = 10 SECONDS
	aoe_ability_cost = 4
	var/bet_cost = 10
	var/reroll_cost = 5

	aoe_ability_name = "СТАВКА"
	aoe_ability_desc = "Останавливает мир вокруг вас на время вращения рулетки. Загадывается случайное число в диапазоне от 1 до 6 и все участники включая вас должны угадать какое. В зависимости от результата ставки вы можете как получить определённые бонусы, так и серьёзно пострадать"

	targeted_ability_cost = 0

	targeted_ability_name = "КОНТРАКТ"
	targeted_ability_desc = "Нажимая по другому живому существу - вы заключаете с ним единоразовый страховой контракт, который затем можете применить в любой удобный для вас момент. Даже с того света"
