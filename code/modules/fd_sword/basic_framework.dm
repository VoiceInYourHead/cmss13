//// SWORD ////

/obj/effect/fd_sword/targeted_ability
	name = "CLICK ME"
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "spellwarning"

	anchored = TRUE
	mouse_opacity = FALSE

/obj/effect/fd_sword/targeted_ability/Initialize(mapload, ...)
	. = ..()
	spawn(1 SECONDS)
		qdel(src)

/obj/effect/fd_sword/sanity_effect
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "stabilized"

	anchored = TRUE
	mouse_opacity = FALSE
	alpha = 0

/obj/effect/fd_sword/sanity_effect/Initialize(mapload, ...)
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS, flags = ANIMATION_PARALLEL)
	animate(src, pixel_y = 48, time = 0.5 SECONDS, easing = SINE_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)

	spawn(1 SECONDS)
		animate(src, alpha = 0, time = 0.5 SECONDS)

	spawn(1.5 SECONDS)
		qdel(src)

/obj/effect/fd_sword/sanity_effect/full
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "full"

/obj/effect/fd_sword/sanity_effect/overflow
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "overflow"

/obj/effect/fd_sword/hit_effect
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "wham"

	anchored = TRUE
	mouse_opacity = FALSE
	alpha = 0

/obj/effect/fd_sword/hit_effect/Initialize(mapload, ...)
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS, flags = ANIMATION_PARALLEL)
	animate(src, pixel_x = rand(-32,32), pixel_y = rand(-32,32), time = 0.5 SECONDS, easing = BOUNCE_EASING, flags = ANIMATION_PARALLEL)

	spawn(0.5 SECONDS)
		animate(src, alpha = 0, time = 0.5 SECONDS)

	spawn(1 SECONDS)
		qdel(src)

/obj/effect/fd_sword/hit_effect/alt1
	icon_state = "pow"

/obj/effect/fd_sword/hit_effect/alt2
	icon_state = "bonk"

/obj/item/weapon/sword/fd_sword
	var/list/datum/sword_tech/techniques = list()
	var/datum/sword_tech/technique_attached = null
	icon = 'code/modules/fd_sword/icons/swords.dmi'
	icon_state = "timesword"

	var/awakend = FALSE
	var/mob/living/carbon/human/new_soul = null

/obj/item/weapon/sword/fd_sword/Initialize(mapload, ...)
	. = ..()

	var/list/tech_creation = techniques.Copy()
	techniques.Cut()
	for(var/techs in tech_creation)
		new techs(src)

	if(length(techniques))
		technique_attached = techniques[1]

	START_PROCESSING(SSobj, src)

/obj/item/weapon/sword/fd_sword/process()

	if(new_soul.sword_combat_active && new_soul.current_active_technique == technique_attached)

		var/pre_overcharge = new_soul.sword_usage_limit - 2
		if(new_soul.sword_usage_current >= pre_overcharge && !new_soul.danger_zone_reached)
			new_soul.danger_zone_reached = TRUE
			new /obj/effect/fd_sword/sanity_effect/full(get_turf(new_soul))

		if(new_soul.sword_usage_current > new_soul.sword_usage_limit && !new_soul.overcharged)
			trigger_overcharge()

/obj/item/weapon/sword/fd_sword/attack(mob/target, mob/user)
	. = ..()

	var/impact_effect = pick(1,2)
	switch(impact_effect)
		if(1)
			new /obj/effect/fd_sword/hit_effect/alt1(get_turf(target))
		if(2)
			new /obj/effect/fd_sword/hit_effect/alt2(get_turf(target))

/obj/item/weapon/sword/fd_sword/proc/trigger_overcharge()
	new /obj/effect/fd_sword/sanity_effect/overflow(get_turf(new_soul))
	new_soul.add_filter("overcharged", 1, list("type" = "outline", "color" = "#a200ff", "size" = 1))
	new_soul.overlays += image('code/modules/fd_sword/icons/visuals.dmi', icon_state = "dementation")

	new_soul.overcharged = TRUE

	new_soul.reagents.add_reagent("speed_stimulant", 10)
	new_soul.reagents.add_reagent("brain_stimulant", 10)

	addtimer(CALLBACK(src, PROC_REF(resolve_overcharge)), 10 SECONDS)

/obj/item/weapon/sword/fd_sword/proc/resolve_overcharge()
	new /obj/effect/fd_sword/sanity_effect(get_turf(new_soul))
	new_soul.remove_filter("overcharged", 1, list("type" = "outline", "color" = "#a200ff", "size" = 1))
	new_soul.overlays -= image('code/modules/fd_sword/icons/visuals.dmi', icon_state = "dementation")

	new_soul.danger_zone_reached = FALSE
	new_soul.overcharged = FALSE
	new_soul.sword_usage_limit -= 2
	new_soul.sword_usage_current = 0

	new_soul.reagents.del_reagent("speed_stimulant")
	new_soul.reagents.del_reagent("brain_stimulant")

	technique_attached.overcharge_debuffs()

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
			return FALSE

		awakend = TRUE
		add_filter("awakend", 1, list("type" = "outline", "color" = "#ffffff", "size" = 1))

		soul.current_active_technique = technique_attached
		soul.sword_combat_active = TRUE
		if(isnull(new_soul))
			new_soul = soul

		return TRUE

	if(awakend)
		awakend = FALSE
		remove_filter("awakend", 1, list("type" = "outline", "color" = "#ffffff", "size" = 1))

		soul.current_active_technique = null
		soul.sword_combat_active = FALSE

		return TRUE

//// MOB ////

/mob/living/carbon/human
	var/datum/sword_tech/current_active_technique = null

	var/sword_usage_limit = 10
	var/sword_usage_current = 0

	var/sword_combat_active = FALSE // Больше никаких рандомклик взрывов школы

	var/danger_zone_reached = FALSE
	var/overcharged = FALSE

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

/datum/sword_tech/proc/overcharge_debuffs()
	return TRUE

/datum/sword_tech/proc/traverse_ability_check()
	if(!traverse_ability_ready)
		return FALSE

	connected_weapon.new_soul.sword_usage_current += traverse_ability_cost
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

	connected_weapon.new_soul.sword_usage_current += ranged_ability_cost
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

	connected_weapon.new_soul.sword_usage_current += aoe_ability_cost
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

	connected_weapon.new_soul.sword_usage_current += targeted_ability_cost
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

// VARIOUS TEST STUFF //

/mob/living/simple_animal/hostile/alien/fd_sword_test
	icon = 'code/modules/fd_sword/icons/mob.dmi'
	icon_gib = "behemoth"

	name = "Entity"

	health = 50
	pixel_x = 0
	old_x = 0

/mob/living/simple_animal/hostile/alien/fd_sword_test/update_wounds()
	return
