/obj/item/weapon/sword/fd_sword/huntersword
	techniques = list(/datum/sword_tech/huntersword)
	icon_state = "huntersword"

/obj/item/weapon/sword/fd_sword/huntersword/attack(mob/target, mob/user)
	. = ..()

	if(istype(target, /mob/living))
		if(target != user)
			var/mob/living/L = target

			L.add_status_value("bleed", 5)

/datum/sword_tech/huntersword
	name = "КОНЦЕПЦИЯ: Настойчивость"

	traverse_ability_cooldown = 5 SECONDS
	traverse_ability_cost = 2
	traverse_ability_name = "ДЕРЖАТЬ ДИСТАНЦИЮ"
	traverse_ability_desc = "Делает мощный взмах, разрывающий дистанцию между вами и противником"

	ranged_ability_cooldown = 5 SECONDS
	ranged_ability_cost = 2
	ranged_ability_charges = 2
	ranged_ability_name = "СОБРАТЬ ТРОФЕИ"
	ranged_ability_desc = "Набрасывается на первую цель по линии взгляда, мгновенно убивая её, если количество её здоровья меньше двух сотен. В ином случае - просто фиксирует её на месте"

	aoe_ability_cooldown = 2 SECONDS
	aoe_ability_cost = 0

	targeted_ability_cost = 0
	targeted_ability_cooldown = 2 SECONDS

/obj/effect/fd_sword/telegraph_basic/huntersword_traverse
	delete_after = 0.5 SECONDS

/datum/sword_tech/huntersword/use_traverse_ability()
	var/mob/living/carbon/human/H = connected_weapon.new_soul

	var/sx
	var/sy
	var/ex
	var/ey

	switch(H.dir)
		if(NORTH)
			sy = 0
			ey = 2
			ex = 3
			sx = 3
		if(SOUTH)
			ey = 0
			sy = 2
			ex = 3
			sx = 3
		if(WEST)
			ex = 0
			sx = 2
			sy = 3
			ey = 3
		if(EAST)
			sx = 0
			ex = 2
			sy = 3
			ey = 3

	for(var/turf in block(H.x-sx, H.y-sy, H.z, H.x+ex, H.y+ey, H.z))
		new /obj/effect/fd_sword/telegraph_basic/huntersword_traverse(turf)
		for(var/mob/living/L in turf)
			if(L == connected_weapon.new_soul)
				continue
			if(L.srd_faction == H.srd_faction)
				continue
			var/reverse_facing = get_dir(H, L)
			L.throw_atom(get_edge_target_turf(L, reverse_facing), 6, SPEED_VERY_FAST, src, TRUE)

	var/turf/target_turf = get_turf(get_step(H, H.dir))
	var/reverse_facing = get_dir(target_turf, H)

	H.throw_atom(get_edge_target_turf(H, reverse_facing), 1, SPEED_AVERAGE, src, FALSE)
	H.face_atom(target_turf)
	H.cool_sword_attack_on(target_turf)
