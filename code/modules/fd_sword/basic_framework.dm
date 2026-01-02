//// MOB ////

/mob/living/carbon/human
	var/list/datum/sword_tech/swords_technique = list(/datum/sword_tech/pyrokinesis)
	var/datum/sword_tech/current_active_technique = null

	var/sword_usage_limit = 10
	var/sword_usage_current = 0

	var/sword_combat_active = FALSE // Больше никаких рандомклик взрывов школы

//// SCHOOL ////

/datum/sword_tech
	var/name = "ТЕХНИКА: Ничего"

	var/tech_level = 1

	var/traverse_ability_cooldown = 0 // Q keybind
	var/traverse_ability_ready = TRUE
	var/traverse_ability_cost = 1
	var/traverse_ability_charges = -1

	var/ranged_ability_cooldown = 0 // E keybind
	var/ranged_ability_ready = TRUE
	var/ranged_ability_cost = 1
	var/ranged_ability_charges = -1

	var/aoe_ability_cooldown = 0 // Shift+E keybind
	var/aoe_ability_ready = TRUE
	var/aoe_ability_cost = 1
	var/aoe_ability_charges = -1

	var/targeted_ability_cooldown = 0 // LMB по объектам
	var/targeted_ability_ready = TRUE
	var/targeted_ability_cost = 1
	var/targeted_ability_charges = -1

	var/mob/living/carbon/human/new_soul

/datum/sword_tech/New(mob/living/carbon/human/soul)
	. = ..()

	new_soul = soul
	new_soul.swords_technique += src

	Initialize()

/datum/sword_tech/Destroy()
	new_soul.swords_technique -= src
	new_soul = null
	. = ..()

/datum/sword_tech/proc/Initialize()

	if(name)
		src.name = name

/datum/sword_tech/proc/traverse_ability_check()
	if(!traverse_ability_ready)
		return FALSE

	new_soul.sword_usage_current += traverse_ability_cost
	use_traverse_ability()

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
		return FALSE

	new_soul.sword_usage_current += ranged_ability_cost
	use_ranged_ability()

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
		return FALSE

	new_soul.sword_usage_current += aoe_ability_cost
	use_aoe_ability()

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
		return FALSE

	new_soul.sword_usage_current += targeted_ability_cost
	use_targeted_ability(target)

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

#define CATEGORY_SWORD "ТЕХНИКА МЕЧА"

/datum/keybinding/human/sword_technique
	category = CATEGORY_SWORD

/datum/keybinding/human/sword_technique/can_use(client/user)

	var/mob/living/carbon/human/human_mob = user.mob

	if(!human_mob.sword_combat_active)
		return FALSE

	if(human_mob.sword_usage_current >= human_mob.sword_usage_limit)
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

/datum/keybinding/human/meta_ability/traverse/up(client/user)
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
	hotkey_keys = list("Shift+Q")
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
