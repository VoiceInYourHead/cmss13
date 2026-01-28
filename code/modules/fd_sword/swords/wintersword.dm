#define COMSIG_KB_HUMAN_WINTERSWORD_TRAVERSE_UP "keybinding_human_wintersword_traverse_up"
#define COMSIG_KB_HUMAN_WINTERSWORD_TRAVERSE_DOWN "keybinding_human_wintersword_traverse_down"

/atom/
	var/cold = FALSE

/obj/proc/chill_out()
	cold = TRUE

	overlays += image('code/modules/fd_sword/icons/visuals.dmi', icon_state = "empdisable")
	add_filter("chilled", 1, list("type" = "outline", "color" = "#aefff4", "size" = 1))

	addtimer(CALLBACK(src, PROC_REF(heat_up)), 1 MINUTES)

/obj/structure/machinery/door/airlock/chill_out()
	locked = TRUE

	. = ..()

/obj/proc/heat_up()
	cold = FALSE

	overlays -= image('code/modules/fd_sword/icons/visuals.dmi', icon_state = "empdisable")
	remove_filter("chilled", 1, list("type" = "outline", "color" = "#aefff4", "size" = 1))

/obj/structure/machinery/door/airlock/heat_up()
	locked = FALSE

	. = ..()

/obj/get_examine_text(mob/user)
	. = ..()

	if(cold)
		. += SPAN_BLUE("На поверхности [src] виднеется едва заметная ледяная корка.")

/mob/living
	var/tripped = FALSE

/mob/living/proc/turn_to_ice()
	overlays += image('code/modules/fd_sword/icons/visuals.dmi', icon_state = "ice_cube")
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, ICECAGE_TRAIT)
	ADD_TRAIT(src, TRAIT_TEMPORARILY_MUTED, ICECAGE_TRAIT)

	mouse_opacity = FALSE

	cold = TRUE
	bodytemperature = 190

	addtimer(CALLBACK(src, PROC_REF(unfreeze)), 5 SECONDS)

/mob/living/proc/unfreeze()
	overlays -= image('code/modules/fd_sword/icons/visuals.dmi', icon_state = "ice_cube")
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, ICECAGE_TRAIT)
	REMOVE_TRAIT(src, TRAIT_TEMPORARILY_MUTED, ICECAGE_TRAIT)

	cold = FALSE
	bodytemperature = T37C

	mouse_opacity = TRUE
	set_status_value("cold", 0)

/mob/living/proc/standup()
	animate(src, time = 0.5 SECONDS, transform = matrix(0, MATRIX_ROTATE), easing = SINE_EASING)
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, ICESLIDE_TRAIT)
	REMOVE_TRAIT(src, TRAIT_UNDENSE, ICESLIDE_TRAIT)
	tripped = FALSE

/datum/ammo/bullet/shotgun/iceshard
	name = "ice spike"
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "ice_proj"
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/ice_spread

	accuracy_var_low = PROJECTILE_VARIANCE_TIER_5
	accuracy_var_high = PROJECTILE_VARIANCE_TIER_5
	accurate_range = 8
	max_range = 11
	damage = 30
	damage_var_low = PROJECTILE_VARIANCE_TIER_8
	damage_var_high = PROJECTILE_VARIANCE_TIER_8
	penetration = ARMOR_PENETRATION_TIER_4
	bonus_projectiles_amount = EXTRA_PROJECTILES_TIER_9
	shell_speed = AMMO_SPEED_TIER_2

/datum/ammo/bullet/shotgun/ice_spread
	name = "ice spike"
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "ice_proj"

	accuracy_var_low = PROJECTILE_VARIANCE_TIER_6
	accuracy_var_high = PROJECTILE_VARIANCE_TIER_6
	accurate_range = 6
	max_range = 8
	damage = 30
	damage_var_low = PROJECTILE_VARIANCE_TIER_8
	damage_var_high = PROJECTILE_VARIANCE_TIER_8
	penetration = ARMOR_PENETRATION_TIER_4
	shell_speed = AMMO_SPEED_TIER_2
	scatter = SCATTER_AMOUNT_TIER_1

/obj/item/weapon/sword/fd_sword/wintersword
	techniques = list(/datum/sword_tech/wintersword)
	icon_state = "wintersword"

/obj/item/weapon/sword/fd_sword/wintersword/attack(mob/target, mob/user)
	. = ..()
	var/mob/living/carbon/human/H = user

	if(istype(target, /mob/living) && H.sword_combat_active)
		if(target != user)
			var/mob/living/L = target

			L.add_status_value("cold", 2)

			if(L.ice_stacks >= 10)
				L.turn_to_ice()

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
	name = "КОНЦЕПЦИЯ: Зима"

	traverse_ability_cooldown = 30 SECONDS
	traverse_ability_cost = 2
	var/traverse_active = FALSE
	var/traverse_active_time = 15 SECONDS

	traverse_ability_name = "ЛЕДЕНЯЩАЯ ПОСТУПЬ"
	traverse_ability_desc = "Создаёт под ногами твёрдую ледяную корку, которая исчезает со временем, но может быть использована для быстрого перемещения по обеим осям координат. Другие люди подскальзываются на ней!"

	ranged_ability_cooldown = 1 MINUTES
	ranged_ability_cost = 1
	ranged_ability_charges = 9
	var/shards_type = /datum/ammo/bullet/shotgun/iceshard

	ranged_ability_name = "МОРОЗНЫЕ ИГЛЫ"
	ranged_ability_desc = "Выпускает свору крайне острых ледяных пик с внушительным уроном"

	aoe_ability_cooldown = 30 SECONDS
	aoe_ability_cost = 4

	aoe_ability_name = "ЛАВИНА"
	aoe_ability_desc = "Создаёт вокруг группу ледяных шипов, наносящих средний урон всему, что окажется в месте их появления"

	targeted_ability_cost = 0
	targeted_ability_cooldown = 2 SECONDS

	targeted_ability_name = "ОБМОРОЖЕНИЕ"
	targeted_ability_desc = "Систематические удары данным оружием заставляют цель замёрзнуть. Касание пустой рукой в боевом режиме может привести к самым разным последствиям в зависимости от выбранной цели"

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

/datum/sword_tech/wintersword/use_ranged_ability()
	var/turf/shoot_angle = get_step(connected_weapon.new_soul, connected_weapon.new_soul.dir)
	var/obj/effect/fd_sword/shards_creation/former_projectile
	ADD_TRAIT(connected_weapon.new_soul, TRAIT_IMMOBILIZED, ICESPIKES_TRAIT)
	former_projectile = new /obj/effect/fd_sword/shards_creation(shoot_angle)

	spawn(1.2 SECONDS)
		former_projectile.forceMove(get_turf(get_step(former_projectile, connected_weapon.new_soul.dir)))
		var/obj/projectile/projectile = new /obj/projectile(connected_weapon.new_soul.loc)

		var/datum/ammo/shards_datum = GLOB.ammo_list[shards_type]
		projectile.generate_bullet(shards_datum)

		shake_camera(connected_weapon.new_soul, 2, 1)
		connected_weapon.new_soul.animation_attack_on(shoot_angle)
		projectile.fire_at(shoot_angle, connected_weapon.new_soul, connected_weapon.new_soul, shards_datum.max_range, shards_datum.shell_speed)
		REMOVE_TRAIT(connected_weapon.new_soul, TRAIT_IMMOBILIZED, ICESPIKES_TRAIT)

/datum/sword_tech/wintersword/use_aoe_ability()
	var/list/inner_circle = list()
	var/list/outer_circle = list()

	var/inner_circle_area = 1 + tech_level
	var/outer_circle_area = inner_circle_area + 1

	connected_weapon.new_soul.anchored = TRUE
	ADD_TRAIT(connected_weapon.new_soul, TRAIT_IMMOBILIZED, ICECAGE_TRAIT)

	for(var/turf/T in orange(inner_circle_area, connected_weapon.new_soul))
		if(connected_weapon.new_soul in T)
			continue

		new /obj/effect/fd_sword/telegraph_basic/wintersword/aoe(T)
		inner_circle += T

		// ДЛЯ СОЮЗНИКОВ //
		for(var/mob/living/L in T)
			if(L.srd_faction == connected_weapon.new_soul.srd_faction && L != connected_weapon.new_soul)
				L.forceMove(get_turf(connected_weapon.new_soul))
				L.anchored = TRUE
				ADD_TRAIT(L, TRAIT_IMMOBILIZED, ICECAGE_TRAIT)
		// ДЛЯ СОЮЗНИКОВ //

	spawn(1 SECONDS)
		for(var/turf/T in inner_circle)
			new /obj/effect/fd_sword/ice_aoe(T)

		for(var/turf/T in orange(outer_circle_area, connected_weapon.new_soul))
			if(connected_weapon.new_soul in T)
				continue
			if(T in inner_circle)
				continue

			new /obj/effect/fd_sword/telegraph_basic/wintersword/aoe(T)
			outer_circle += T

	spawn(2 SECONDS)
		for(var/turf/T in outer_circle)

			for(var/mob/living/M in T)
				if(M.parry_protection)
					playsound(M, pick(GLOB.parry_sound), 50)
					new /obj/effect/block(get_turf(M))

					var/reverse_facing = get_dir(get_edge_target_turf(M, M.dir), M)

					M.throw_atom(get_edge_target_turf(M, reverse_facing), 9, SPEED_AVERAGE, src, FALSE)
					continue

			new /obj/effect/fd_sword/ice_aoe(T)

		for(var/mob/living/L in get_turf(connected_weapon.new_soul))
			if(L != connected_weapon.new_soul)
				L.anchored = FALSE
				REMOVE_TRAIT(L, TRAIT_IMMOBILIZED, ICECAGE_TRAIT)

		connected_weapon.new_soul.anchored = FALSE
		REMOVE_TRAIT(connected_weapon.new_soul, TRAIT_IMMOBILIZED, ICECAGE_TRAIT)

/datum/sword_tech/wintersword/use_targeted_ability(atom/target)
	if(!connected_weapon.new_soul.get_active_hand())

		if(istype(target, /obj/) && target != connected_weapon)
			var/obj/O = target
			if(!O.cold)

				O.chill_out()

				new /obj/effect/fd_sword/targeted_ability(get_turf(target))
				connected_weapon.new_soul.sword_usage_current += 1

				check_overcharge()
				connected_weapon.new_soul.hud_used.sword_usage_stat.update_stat(connected_weapon.new_soul)
				connected_weapon.new_soul.hud_used.sword_limit_stat.update_stat(connected_weapon.new_soul)

		if(istype(target, /mob/living/carbon/human) && get_dist(target, connected_weapon.new_soul) <= 1)
			var/mob/living/carbon/human/H = target

			new /obj/effect/fd_sword/sparkles(get_turf(H))

			for(var/obj/limb/L in H)
				L.remove_all_bleeding(TRUE)

			H.apply_damage(-30, BRUTE)
			H.apply_damage(-30, BURN)
			connected_weapon.new_soul.balloon_alert_to_viewers("*[connected_weapon.new_soul] прикладывает руку к ранам [H], помогая им затянуться*", null, DEFAULT_MESSAGE_RANGE, null, COLOR_CYAN)

			new /obj/effect/fd_sword/targeted_ability(get_turf(H))
			new /obj/effect/fd_sword/heal_effect(get_turf(H))
			connected_weapon.new_soul.sword_usage_current += 1

			check_overcharge()
			connected_weapon.new_soul.hud_used.sword_usage_stat.update_stat(connected_weapon.new_soul)
			connected_weapon.new_soul.hud_used.sword_limit_stat.update_stat(connected_weapon.new_soul)
