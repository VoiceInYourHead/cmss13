/datum/sword_tech/pyrokinesis
	name = "ТЕХНИКА: Пирокинез"

	traverse_ability_cooldown = 0.5 SECONDS
	var/basic_traverse_range = 2
	var/additional_traverse_range = 0
	var/cooling = FALSE

/datum/sword_tech/pyrokinesis/Initialize()

	. = ..()
	START_PROCESSING(SSfasteffects, src)

/datum/sword_tech/pyrokinesis/process()

	if(cooling && additional_traverse_range < (tech_level + 3))
		additional_traverse_range += 1

/datum/sword_tech/pyrokinesis/use_traverse_ability()
	var/final_traverse_range = basic_traverse_range + additional_traverse_range
	var/turf/ending = get_ranged_target_turf(connected_weapon.new_soul, connected_weapon.new_soul.dir, final_traverse_range)
	var/list/affected_turfs = list()
	var/datum/reagent/chemical = GLOB.chemical_reagents_list["utnapthal"]

	for(var/turf/T in get_line(connected_weapon.new_soul, ending))
		if(T == ending)
			continue
		affected_turfs += T

	for(var/turf/T in affected_turfs)
		new /obj/flamer_fire(T, null, chemical)
	connected_weapon.new_soul.throw_atom(get_edge_target_turf(connected_weapon.new_soul, connected_weapon.new_soul.dir), final_traverse_range, SPEED_VERY_FAST, src, FALSE)

/datum/sword_tech/pyrokinesis/traverse_ability_reset()
	additional_traverse_range = 0
	. = ..()
