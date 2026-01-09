#define COMSIG_KB_HUMAN_WINTERSWORD_TRAVERSE_UP "keybinding_human_wintersword_traverse_up"
#define COMSIG_KB_HUMAN_WINTERSWORD_TRAVERSE_DOWN "keybinding_human_wintersword_traverse_down"

/mob/living/carbon/human/Move(NewLoc, direct)
	if(istype(current_active_technique, /datum/sword_tech/wintersword))
		var/datum/sword_tech/wintersword/icewalk = current_active_technique
		if(icewalk.traverse_active)
			next_move_slowdown = -0.5
			flags_atom |= NO_ZFALL
			new /obj/structure/fd_sword/ice_bridge(get_turf(NewLoc))

	. = ..()

	flags_atom &= ~NO_ZFALL

/mob/living
	var/tripped = FALSE

/obj/structure/fd_sword/ice_bridge
	name = "Лёд"

	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "ice_bridge"

	anchored = TRUE
	density = FALSE

/obj/structure/fd_sword/ice_bridge/Initialize(mapload, ...)
	. = ..()
	spawn(3 SECONDS)
		animate(src, alpha = 0, time = 1 SECONDS)
	spawn(4 SECONDS)
		qdel(src)

/obj/structure/fd_sword/ice_bridge/Crossed(O)
	. = ..()

	if(istype(O, /mob/living))
		var/mob/living/L = O
		if(!L.tripped)

			if(!ishuman(L))
				tripover(L)
				return TRUE
			else
				var/mob/living/carbon/human/H = O
				if(!istype(H.current_active_technique, /datum/sword_tech/wintersword))
					tripover(H)
					return TRUE

/obj/structure/fd_sword/ice_bridge/proc/tripover(mob/living/M)
	M.tripped = TRUE
	if(M.buckled)
		return FALSE
	M.stop_pulling()
	playsound(src.loc, 'sound/misc/slip.ogg', 25, 1)

	var/turf/slide = get_step(M, M.dir)
	animate(M, time = 0.5 SECONDS, transform = matrix(90, MATRIX_ROTATE), easing = SINE_EASING)

	M.forceMove(slide)
	ADD_TRAIT(M, TRAIT_IMMOBILIZED, ICESLIDE_TRAIT)
	ADD_TRAIT(M, TRAIT_UNDENSE, ICESLIDE_TRAIT)

	addtimer(CALLBACK(src, PROC_REF(standup), M), 1 SECONDS)

/obj/structure/fd_sword/ice_bridge/proc/standup(mob/living/M)
	animate(M, time = 0.5 SECONDS, transform = matrix(0, MATRIX_ROTATE), easing = SINE_EASING)
	REMOVE_TRAIT(M, TRAIT_IMMOBILIZED, ICESLIDE_TRAIT)
	REMOVE_TRAIT(M, TRAIT_UNDENSE, ICESLIDE_TRAIT)
	M.tripped = FALSE

/obj/item/weapon/sword/fd_sword/wintersword
	techniques = list(/datum/sword_tech/wintersword)
	icon_state = "wintersword"

/datum/keybinding/human/sword_technique/wintersword_traverse_up
	hotkey_keys = list("Northeast")
	classic_keys = list("Unbound")
	name = "wintersword_traverse_up"
	full_name = "ТЕХНИКА: Леденящая поступь, ВВЕРХ (Зима)"
	description = "Поднимает пользователя специального меча вверх."
	keybind_signal = COMSIG_KB_HUMAN_WINTERSWORD_TRAVERSE_UP

/datum/keybinding/human/sword_technique/wintersword_traverse_up/can_use(client/user)
	. = ..()

	var/mob/living/carbon/human/human_mob = user.mob

	if(istype(human_mob.current_active_technique, /datum/sword_tech/wintersword))
		var/datum/sword_tech/wintersword/icewalk = human_mob.current_active_technique
		if(!icewalk.traverse_active)
			return FALSE
	else
		return FALSE

/datum/keybinding/human/sword_technique/wintersword_traverse_up/up(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/human_mob = user.mob
	var/turf/above = SSmapping.get_turf_above(get_turf(human_mob))

	if(istype(above, /turf/open_space))
		human_mob.flags_atom |= NO_ZFALL
		new /obj/structure/fd_sword/ice_bridge(above)
		human_mob.forceMove(above)
		human_mob.flags_atom &= ~NO_ZFALL
		return TRUE
	else
		new /obj/effect/fd_sword/cannot_cast_ability(get_turf(human_mob))
		human_mob.balloon_alert(human_mob, "Потолок мешает подняться выше!", COLOR_RED)
		return FALSE

/datum/keybinding/human/sword_technique/wintersword_traverse_down
	hotkey_keys = list("Southeast")
	classic_keys = list("Unbound")
	name = "wintersword_traverse_down"
	full_name = "ТЕХНИКА: Леденящая поступь, ВНИЗ (Зима)"
	description = "Опускает пользователя специального меча на уровень ниже."
	keybind_signal = COMSIG_KB_HUMAN_WINTERSWORD_TRAVERSE_DOWN

/datum/keybinding/human/sword_technique/wintersword_traverse_down/can_use(client/user)
	. = ..()

	var/mob/living/carbon/human/human_mob = user.mob

	if(istype(human_mob.current_active_technique, /datum/sword_tech/wintersword))
		var/datum/sword_tech/wintersword/icewalk = human_mob.current_active_technique
		if(!icewalk.traverse_active)
			return FALSE
	else
		return FALSE

/datum/keybinding/human/sword_technique/wintersword_traverse_down/up(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/human_mob = user.mob
	var/turf/below = get_turf(human_mob)

	if(istype(below, /turf/open_space))
		var/turf/even_lower = SSmapping.get_turf_below(get_turf(below))

		human_mob.flags_atom |= NO_ZFALL
		new /obj/structure/fd_sword/ice_bridge(even_lower)
		human_mob.forceMove(even_lower)
		human_mob.flags_atom &= ~NO_ZFALL
		return TRUE
	else
		new /obj/effect/fd_sword/cannot_cast_ability(get_turf(human_mob))
		human_mob.balloon_alert(human_mob, "Пол мешает опуститься ниже!", COLOR_RED)
		return FALSE

/datum/sword_tech/wintersword
	name = "ТЕХНИКА: Зима"

	traverse_ability_cooldown = 30 SECONDS
	traverse_ability_cost = 2
	var/traverse_active = FALSE
	var/traverse_active_time = 15 SECONDS

	traverse_ability_name = "ЛЕДЕНЯЩАЯ ПОСТУПЬ"
	traverse_ability_desc = "Создаёт под ногами твёрдую ледяную корку, которая исчезает со временем, но может быть использована для быстрого перемещения по обеим осям координат. Другие люди подскальзываются на ней!"

/datum/sword_tech/wintersword/use_traverse_ability()
	traverse_active = TRUE

	var/time_left = traverse_active_time - 5 SECONDS

	addtimer(CALLBACK(src, PROC_REF(time_left)), time_left)
	addtimer(CALLBACK(src, PROC_REF(stop_traverse)), traverse_active_time)

/datum/sword_tech/wintersword/proc/time_left()
	new /obj/effect/fd_sword/ability_on_cooldown(get_turf(connected_weapon.new_soul))
	connected_weapon.new_soul.balloon_alert(connected_weapon.new_soul, "Способность почти кончилась!", COLOR_ORANGE)

/datum/sword_tech/wintersword/proc/stop_traverse()
	traverse_active = FALSE
