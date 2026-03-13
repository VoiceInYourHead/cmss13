/// данилкус и его обсессия по бэнди и чернильной машине strikes back 
/obj/item/weapon/sword/fd_sword/inksword
	icon_state = "inksword"
	techniques = list(/datum/sword_tech/inksword)

/datum/sword_tech/inksword
	name = "КОНЦЕПЦИЯ: Чернила"

	traverse_ability_cost = 0
	traverse_ability_cooldown = 2 SECONDS

	traverse_ability_name = "ПОГРУЖЕНИЕ" // дайверы шедоуран отсылко
	traverse_ability_desc = ""

	ranged_ability_cooldown = 10 SECONDS
	ranged_ability_cost = 0

	ranged_ability_name = "ПРЫГУЧАЯ СФЕРА" // слоп флоп
	ranged_ability_desc = ""

	aoe_ability_cooldown = 10 SECONDS
	aoe_ability_cost = 0

	aoe_ability_name = "ЗОВ" // ебать SIN'ов
	aoe_ability_desc = ""

	targeted_ability_cost = 0

	targeted_ability_name = "ХЛЮП" // хз чё тут сделать ещё надо подумать
	targeted_ability_desc = ""

	var/image/diving_alpha_mask

/datum/sword_tech/inksword/New(obj/item/weapon/sword/fd_sword/weapon)
	. = ..()
	diving_alpha_mask = image('code/modules/fd_sword/icons/alpha_mask.dmi', "mask")
	diving_alpha_mask.appearance_flags = KEEP_APART
	RegisterSignal(connected_weapon, COMSIG_MOVABLE_MOVED, PROC_REF(on_weapon_drop))

/datum/sword_tech/inksword/proc/on_weapon_drop(atom/A, dir, forced)
	toggle_dive(FALSE)

/datum/sword_tech/inksword/proc/swordspin(invert)
	var/turn_angle = invert ? -120 : 120
	var/matrix/transform = matrix().Turn(turn_angle)
	animate(connected_weapon, transform = transform, time = 0.3 SECONDS, easing = SINE_EASING|EASE_IN)
	transform.Turn(turn_angle)
	animate(transform = transform, time = 0.2 SECONDS, easing = LINEAR_EASING)
	transform.Turn(turn_angle)
	animate(transform = transform, time = 0.3 SECONDS, easing = SINE_EASING|EASE_OUT)

/datum/sword_tech/inksword/traverse_ability_check()
	var/mob/living/user = connected_weapon.new_soul
	if(!HAS_TRAIT(user, ON_INK_TRAIT) && !HAS_TRAIT(user, INK_SUBMERGED_TRAIT))
		new /obj/effect/fd_sword/cannot_cast_ability(get_turf(user))
		user.balloon_alert(user, "Вам необходимо находиться НА ЧЕРНИЛАХ", COLOR_RED)
		shake_camera(user, 1, 1)
		return FALSE

	. = ..()

/datum/sword_tech/inksword/use_traverse_ability()
	toggle_dive()

/datum/sword_tech/inksword/proc/toggle_dive(state = -1)
	var/mob/living/user = connected_weapon.new_soul
	var/anim_duration = 0.5 SECONDS
	if(HAS_TRAIT(user, INK_SUBMERGED_TRAIT) && state != FALSE)
		user.mouse_opacity = 1
		user.remove_traits(list(TRAIT_UNDENSE, INK_SUBMERGED_TRAIT), INK_SUBMERGED_TRAIT)
		UnregisterSignal(user, COMSIG_MOVABLE_TURF_ENTER)
		UnregisterSignal(user, COMSIG_MOB_PRE_CLICK)
		animate(user, time = anim_duration, easing = SINE_EASING, pixel_y = 0, alpha = 255)
		swordspin(TRUE)
		//spawn(anim_duration) user.remove_filter("submerged")
	else if(state != TRUE)
		user.mouse_opacity = 0
		user.forceMove(get_turf(user))
		user.add_traits(list(TRAIT_UNDENSE, INK_SUBMERGED_TRAIT), INK_SUBMERGED_TRAIT)
		RegisterSignal(user, COMSIG_MOVABLE_TURF_ENTER, PROC_REF(move_override))
		RegisterSignal(user, COMSIG_MOB_PRE_CLICK, PROC_REF(click_override))
		animate(user, time = anim_duration, easing = SINE_EASING, pixel_y = -32, alpha = 0)
		swordspin()
		//user.add_filter("submerged", 1, alpha_mask_filter(icon = diving_alpha_mask))

/datum/sword_tech/inksword/proc/move_override(mob/self, turf/to_enter)
	for(var/atom/movable/thing in to_enter)
		if(istype(thing, /obj/effect/alien/weeds/black_slop) || istype(thing, /obj/effect/alien/weeds/node/black_slop))
			return COMPONENT_TURF_ALLOW_MOVEMENT

	try_undive(self)
	return COMPONENT_TURF_DENY_MOVEMENT

/datum/sword_tech/inksword/proc/try_undive(mob/self)
	set waitfor = FALSE
	if(do_after(self, 2 SECONDS, INTERRUPT_MOVED, BUSY_ICON_HOSTILE))
		traverse_ability_check()

/datum/sword_tech/inksword/proc/click_override(mob/living/carbon/human/user, atom/target, mods)
	if(target.z != 0) // худ, инвентарь
		return COMPONENT_INTERRUPT_CLICK

/mob/living/carbon/human/drop_inv_item_on_ground(obj/item/I, nomoveupdate, force)
	CAN_BE_REDEFINED(TRUE)
	if(HAS_TRAIT(src, INK_SUBMERGED_TRAIT))
		return
	..()

/mob/living/carbon/human/ex_act(severity, direction, datum/cause_data/cause_data, pierce=0, enviro=FALSE)
	CAN_BE_REDEFINED(TRUE)
	if(HAS_TRAIT(src, INK_SUBMERGED_TRAIT))
		return
	..()

/mob/living/carbon/human/attack_hand()
	CAN_BE_REDEFINED(TRUE)
	if(HAS_TRAIT(src, INK_SUBMERGED_TRAIT))
		return
	..()

/mob/living/carbon/human/attackby()
	CAN_BE_REDEFINED(TRUE)
	if(HAS_TRAIT(src, INK_SUBMERGED_TRAIT))
		return
	. = ..()

/mob/living/carbon/human/get_projectile_hit_chance()
	CAN_BE_REDEFINED(TRUE)
	. = ..()
	if(HAS_TRAIT(src, INK_SUBMERGED_TRAIT))
		return 0

/datum/sword_tech/inksword/use_ranged_ability()
	set waitfor = FALSE

	var/mob/user = connected_weapon.new_soul
	var/cast_dir = user.dir

	playsound(user, 'sound/effects/squelch1.ogg', 100, TRUE)
	swordspin()

	if(!do_after(user, 0.5 SECONDS, INTERRUPT_UNCONSCIOUS, BUSY_ICON_HOSTILE))
		return
	new /obj/effect/slop_ball(get_turf(user), cast_dir, connected_weapon)

/datum/sword_tech/inksword/aoe_ability_check()

/datum/sword_tech/inksword/use_aoe_ability()

/datum/sword_tech/inksword/use_targeted_ability(atom/target)

#define COLOR_INK "#111111"

/obj/effect/slop_ball
	name = "black mass"
	icon_state = "foam_ball"
	color = COLOR_BLACK
	throw_speed = SPEED_SLOW
	layer = ABOVE_FLY_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/bounce_amount = 2
	var/bounce_range = 5
	var/obj/item/weapon/sword/fd_sword/inksword/inksword

/obj/effect/slop_ball/Initialize(mapload, fly_dir, new_sword, ...)
	. = ..()
	dir = fly_dir
	inksword = new_sword
	transform = matrix(2, MATRIX_SCALE)

	alpha = 0
	animate(src, time = 0.5 SECONDS, alpha = 255, flags = ANIMATION_PARALLEL)

	fly_forward()

/obj/effect/slop_ball/proc/fly_forward()
	set waitfor = FALSE

	pixel_y = -8

	for(var/i in 0 to bounce_amount)
		/// 10/throw_speed-0.5 = делей между движениями по тайлам в полёте, хз могли бы ещё в слонах блять посчитать ну что это такое почему так
		var/midair_move_delay = 10 / throw_speed - 0.5

		var/anim_duration = midair_move_delay * bounce_range
		var/bounce_height = 32 + 16 * bounce_amount - i * 16

		animate(src, time = anim_duration / 2, pixel_y = bounce_height, easing = QUAD_EASING|EASE_OUT)
		spawn(anim_duration / 2)
			animate(src, time = anim_duration / 2, pixel_y = -8, easing = QUAD_EASING|EASE_IN)

		var/mob/living/user = inksword.new_soul

		sleep(midair_move_delay) // Задержка первого шага перед каждым "броском"

		var/turf/target = get_turf(src)
		for(var/step in 1 to bounce_range)
			if(step == 1 && LinkBlocked(src, get_turf(src), get_step(target, dir), list(user)))
				dir = pick(reverse_nearby_direction(dir))
			target = get_step(target, dir)

		throw_atom(target, bounce_range, throw_speed, src, TRUE, HIGH_LAUNCH)

		new /obj/effect/alien/weeds/node/black_slop(src.loc, null, null, null, inksword)

		for(var/turf/hit_turf in range(1,loc))
			for(var/mob/living/hit_mob in hit_turf)
				if(hit_mob.srd_faction != user.srd_faction)
					hit_mob.apply_damage(40, BRUTE)

		if(i < bounce_amount)
			playsound(src, 'sound/effects/pierce1.ogg', 100, TRUE)
		else
			playsound(src, 'sound/effects/pierce2.ogg', 100, TRUE)

	qdel(src)


/obj/effect/alien/weeds/weedwall/black_slop
	name = "black slop"
	desc = "Weird black mess..."
	color = COLOR_INK
	spread_on_semiweedable = TRUE
	node_range = 4

/obj/effect/alien/weeds/weedwall/black_slop/Initialize(mapload, obj/effect/alien/weeds/node/node, use_node_strength, do_spread)
	. = ..()
	alpha = 0
	animate(src, time = rand(4,6), alpha = 255, easing = SINE_EASING|EASE_OUT)

/obj/effect/alien/weeds/weedwall/black_slop/avoid_orphanage()
	return

/obj/effect/alien/weeds/weedwall/black_slop/attackby(obj/item/attacking_item, mob/living/user)
	if(explo_proof)
		return FALSE

	if(QDELETED(attacking_item) || QDELETED(user) || (attacking_item.flags_item & NOBLUDGEON))
		return 0

	to_chat(user, SPAN_WARNING("You cut \the [src] away with \the [attacking_item]."))

	var/damage = (attacking_item.force * attacking_item.demolition_mod) / 3
	playsound(loc, "alien_resin_move", 25)

	if(iswelder(attacking_item))
		var/obj/item/tool/weldingtool/WT = attacking_item
		if(WT.remove_fuel(2))
			damage = WEED_HEALTH_STANDARD
			playsound(loc, 'sound/items/Welder.ogg', 25, 1)
	else
		playsound(loc, "alien_resin_move", 25)

	user.animation_attack_on(src)

	take_damage(damage)
	return (ATTACKBY_HINT_NO_AFTERATTACK|ATTACKBY_HINT_UPDATE_NEXT_MOVE)

/obj/effect/alien/weeds/weedwall/black_slop/attack_alien(mob/living/carbon/xenomorph/attacking_xeno)
	if(!explo_proof && !HIVE_ALLIED_TO_HIVE(attacking_xeno.hivenumber, hivenumber))
		attacking_xeno.animation_attack_on(src)
		attacking_xeno.visible_message(SPAN_DANGER("\The [attacking_xeno] slashes [src]!"),
		SPAN_DANGER("You slash [src]!"), null, 5)
		playsound(loc, "alien_resin_move", 25)
		take_damage(attacking_xeno.melee_damage_lower*WEED_XENO_DAMAGEMULT)
		return XENO_ATTACK_ACTION


/obj/effect/alien/weeds/black_slop
	name = "black slop"
	desc = "Weird black mess..."
	color = COLOR_INK
	spread_on_semiweedable = TRUE
	node_range = 4
	spread_delay_mod = 0.3
	var/obj/item/weapon/sword/fd_sword/inksword/inksword

/obj/effect/alien/weeds/black_slop/Initialize(mapload, obj/effect/alien/weeds/node/node, use_node_strength, do_spread, sword_used)
	. = ..()
	inksword = sword_used
	alpha = 0
	animate(src, time = rand(4,6), alpha = 255, easing = SINE_EASING|EASE_OUT)

/obj/effect/alien/weeds/black_slop/Crossed(atom/movable/atom_movable)
	if(!isliving(atom_movable))
		return

	var/mob/living/crossing_mob = atom_movable
	if(crossing_mob.srd_faction == inksword.new_soul.srd_faction)
		ADD_TRAIT(crossing_mob, ON_INK_TRAIT, ON_INK_TRAIT)
		return

	var/list/slowdata = list("movement_slowdown" = 5)
	SEND_SIGNAL(crossing_mob, COMSIG_MOB_WEED_SLOWDOWN, slowdata, src)
	var/final_slowdown = slowdata["movement_slowdown"]

	crossing_mob.next_move_slowdown = max(crossing_mob.next_move_slowdown, POSITIVE(final_slowdown))
	crossing_mob.apply_effect(0.5, ROOT)

/obj/effect/alien/weeds/black_slop/Uncrossed(atom/movable/atom_movable)
	if(!isliving(atom_movable))
		return

	var/mob/living/crossing_mob = atom_movable
	REMOVE_TRAIT(crossing_mob, ON_INK_TRAIT, ON_INK_TRAIT)

/obj/effect/alien/weeds/black_slop/avoid_orphanage()
	return

/obj/effect/alien/weeds/black_slop/weed_expand()
	var/obj/effect/alien/weeds/node/node = parent
	var/turf/U = get_turf(src)

	if(!istype(U))
		return

	var/list/weeds = list()
	for(var/dirn in GLOB.cardinals)
		var/turf/T = get_step(src, dirn)
		if(!istype(T))
			continue

		var/obj/effect/alien/weeds/W = locate() in T
		if(W)
			if(!W.spread_on_semiweedable)
				qdel(W)
			else
				continue

		T.clean_cleanables()

		if(T.density)
			if(istype(T, /turf/closed/wall))
				continue
			else if(istype(T, /turf/closed))
				weeds.Add(new /obj/effect/alien/weeds/black_slop(T, node, TRUE, FALSE, inksword))
				continue

		if(!weed_expand_objects(T, dirn))
			continue

		var/obj/effect/alien/weeds/black_slop/new_weed = new(T, node, null, null, inksword)
		weeds += new_weed

	on_weed_expand(src, weeds)
	if(parent)
		parent.on_weed_expand(src, weeds)

	return weeds

/obj/effect/alien/weeds/black_slop/weed_expand_objects(turf/T, direction)
	for(var/obj/structure/platform/P in src.loc)
		if(P.dir == reverse_direction(direction))
			return FALSE
	for(var/obj/structure/barricade/from_blocking_cade in loc) //cades on tile we're coming from
		if(from_blocking_cade.density && from_blocking_cade.dir == direction && from_blocking_cade.health >= (from_blocking_cade.maxhealth / 4))
			return FALSE

	for(var/obj/O in T)
		if(istype(O, /obj/structure/platform))
			if(O.dir == direction)
				return FALSE

		if(istype(O, /obj/structure/barricade)) //cades on tile we're trying to expand to
			var/obj/structure/barricade/to_blocking_cade = O
			if(to_blocking_cade.density && to_blocking_cade.dir == GLOB.reverse_dir[direction] && to_blocking_cade.health >= (to_blocking_cade.maxhealth / 4))
				return FALSE

		if(istype(O, /obj/structure/window/framed))
			new /obj/effect/alien/weeds/weedwall/black_slop(T, parent)
			return FALSE
		else if(istype(O, /obj/structure/window_frame))
			new /obj/effect/alien/weeds/weedwall/black_slop(T, parent)
			return FALSE
	return TRUE

/obj/effect/alien/weeds/black_slop/attackby(obj/item/attacking_item, mob/living/user)
	if(explo_proof)
		return FALSE

	if(QDELETED(attacking_item) || QDELETED(user) || (attacking_item.flags_item & NOBLUDGEON))
		return 0

	to_chat(user, SPAN_WARNING("You cut \the [src] away with \the [attacking_item]."))

	var/damage = (attacking_item.force * attacking_item.demolition_mod) / 3
	playsound(loc, "alien_resin_move", 25)

	if(iswelder(attacking_item))
		var/obj/item/tool/weldingtool/WT = attacking_item
		if(WT.remove_fuel(2))
			damage = WEED_HEALTH_STANDARD
			playsound(loc, 'sound/items/Welder.ogg', 25, 1)
	else
		playsound(loc, "alien_resin_move", 25)


	user.animation_attack_on(src)

	take_damage(damage)
	return (ATTACKBY_HINT_NO_AFTERATTACK|ATTACKBY_HINT_UPDATE_NEXT_MOVE)

/obj/effect/alien/weeds/black_slop/attack_alien(mob/living/carbon/xenomorph/attacking_xeno)
	if(!explo_proof && !HIVE_ALLIED_TO_HIVE(attacking_xeno.hivenumber, hivenumber))
		attacking_xeno.animation_attack_on(src)
		attacking_xeno.visible_message(SPAN_DANGER("\The [attacking_xeno] slashes [src]!"),
		SPAN_DANGER("You slash [src]!"), null, 5)
		playsound(loc, "alien_resin_move", 25)
		take_damage(attacking_xeno.melee_damage_lower*WEED_XENO_DAMAGEMULT)
		return XENO_ATTACK_ACTION


/obj/effect/alien/weeds/node/black_slop
	name = "black slop"
	desc = "Weird black mess..."
	color = COLOR_INK
	overlay_node = FALSE
	spread_on_semiweedable = TRUE
	node_range = 4
	spread_delay_mod = 0
	var/obj/item/weapon/sword/fd_sword/inksword/inksword

/obj/effect/alien/weeds/node/black_slop/Initialize(mapload, obj/effect/alien/weeds/node/node, mob/living/carbon/xenomorph/xeno, datum/hive_status/hive, sword_used)
	. = ..()
	inksword = sword_used

/obj/effect/alien/weeds/node/black_slop/Crossed(atom/movable/atom_movable)
	if(!isliving(atom_movable))
		return

	var/mob/living/crossing_mob = atom_movable
	if(crossing_mob.srd_faction == inksword.new_soul.srd_faction)
		ADD_TRAIT(crossing_mob, ON_INK_TRAIT, ON_INK_TRAIT)
		return

	var/list/slowdata = list("movement_slowdown" = 5)
	SEND_SIGNAL(crossing_mob, COMSIG_MOB_WEED_SLOWDOWN, slowdata, src)
	var/final_slowdown = slowdata["movement_slowdown"]

	crossing_mob.next_move_slowdown = max(crossing_mob.next_move_slowdown, POSITIVE(final_slowdown))
	crossing_mob.apply_effect(0.5, ROOT)

/obj/effect/alien/weeds/node/black_slop/Uncrossed(atom/movable/atom_movable)
	if(!isliving(atom_movable))
		return

	var/mob/living/crossing_mob = atom_movable
	REMOVE_TRAIT(crossing_mob, ON_INK_TRAIT, ON_INK_TRAIT)

/obj/effect/alien/weeds/node/black_slop/avoid_orphanage()
	return

/obj/effect/alien/weeds/node/black_slop/weed_expand()
	var/obj/effect/alien/weeds/node/node = parent
	var/turf/U = get_turf(src)

	if(!istype(U))
		return

	var/list/weeds = list()
	for(var/dirn in GLOB.cardinals)
		var/turf/T = get_step(src, dirn)
		if(!istype(T))
			continue

		var/obj/effect/alien/weeds/W = locate() in T
		if(W)
			if(!W.spread_on_semiweedable)
				qdel(W)
			else
				continue

		T.clean_cleanables()

		if(T.density)
			if(istype(T, /turf/closed/wall))
				weeds.Add(new /obj/effect/alien/weeds/weedwall/black_slop(T, node))
				continue
			else if(istype(T, /turf/closed))
				weeds.Add(new /obj/effect/alien/weeds/black_slop(T, node, TRUE, FALSE, inksword))
				continue

		if(!weed_expand_objects(T, dirn))
			continue

		var/obj/effect/alien/weeds/black_slop/new_weed = new(T, node, null, null, inksword)
		weeds += new_weed

	on_weed_expand(src, weeds)
	if(parent)
		parent.on_weed_expand(src, weeds)

	return weeds

/obj/effect/alien/weeds/node/black_slop/weed_expand_objects(turf/T, direction)
	for(var/obj/structure/platform/P in src.loc)
		if(P.dir == reverse_direction(direction))
			return FALSE
	for(var/obj/structure/barricade/from_blocking_cade in loc) //cades on tile we're coming from
		if(from_blocking_cade.density && from_blocking_cade.dir == direction && from_blocking_cade.health >= (from_blocking_cade.maxhealth / 4))
			return FALSE

	for(var/obj/O in T)
		if(istype(O, /obj/structure/platform))
			if(O.dir == direction)
				return FALSE

		if(istype(O, /obj/structure/barricade)) //cades on tile we're trying to expand to
			var/obj/structure/barricade/to_blocking_cade = O
			if(to_blocking_cade.density && to_blocking_cade.dir == GLOB.reverse_dir[direction] && to_blocking_cade.health >= (to_blocking_cade.maxhealth / 4))
				return FALSE

		if(istype(O, /obj/structure/window/framed))
			new /obj/effect/alien/weeds/weedwall/black_slop(T, parent)
			return FALSE
		else if(istype(O, /obj/structure/window_frame))
			new /obj/effect/alien/weeds/weedwall/black_slop(T, parent)
			return FALSE
	return TRUE

/obj/effect/alien/weeds/node/black_slop/attackby(obj/item/attacking_item, mob/living/user)
	if(explo_proof)
		return FALSE

	if(QDELETED(attacking_item) || QDELETED(user) || (attacking_item.flags_item & NOBLUDGEON))
		return 0

	to_chat(user, SPAN_WARNING("You cut \the [src] away with \the [attacking_item]."))

	var/damage = (attacking_item.force * attacking_item.demolition_mod) / 3
	playsound(loc, "alien_resin_move", 25)

	if(iswelder(attacking_item))
		var/obj/item/tool/weldingtool/WT = attacking_item
		if(WT.remove_fuel(2))
			damage = WEED_HEALTH_STANDARD
			playsound(loc, 'sound/items/Welder.ogg', 25, 1)
	else
		playsound(loc, "alien_resin_move", 25)


	user.animation_attack_on(src)

	take_damage(damage)
	return (ATTACKBY_HINT_NO_AFTERATTACK|ATTACKBY_HINT_UPDATE_NEXT_MOVE)

/obj/effect/alien/weeds/node/black_slop/attack_alien(mob/living/carbon/xenomorph/attacking_xeno)
	if(!explo_proof && !HIVE_ALLIED_TO_HIVE(attacking_xeno.hivenumber, hivenumber))
		attacking_xeno.animation_attack_on(src)
		attacking_xeno.visible_message(SPAN_DANGER("\The [attacking_xeno] slashes [src]!"),
		SPAN_DANGER("You slash [src]!"), null, 5)
		playsound(loc, "alien_resin_move", 25)
		take_damage(attacking_xeno.melee_damage_lower*WEED_XENO_DAMAGEMULT)
		return XENO_ATTACK_ACTION
