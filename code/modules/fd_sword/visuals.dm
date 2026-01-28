/// BASIC ONES ///

/obj/effect/fd_sword/telegraph_basic
	name = "ТЕЛЕГРАФИЯ АТАКИ"

	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "target_tile"

	anchored = TRUE
	mouse_opacity = FALSE
	var/delete_after = 1 SECONDS

/obj/effect/fd_sword/telegraph_basic/Initialize(mapload, ...)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(remove)), delete_after)

/obj/effect/fd_sword/telegraph_basic/proc/remove()
	animate(src, alpha = 0, time = 0.5 SECONDS)
	spawn(0.6 SECONDS)
		qdel(src)

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

/obj/effect/fd_sword/ability_on_cooldown
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "cooldown"

	anchored = TRUE
	mouse_opacity = FALSE
	alpha = 0

/obj/effect/fd_sword/ability_on_cooldown/Initialize(mapload, ...)
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS, flags = ANIMATION_PARALLEL)
	animate(src, pixel_y = 48, time = 0.5 SECONDS, easing = SINE_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)

	spawn(1.5 SECONDS)
		animate(src, alpha = 0, time = 0.5 SECONDS)

	spawn(2 SECONDS)
		qdel(src)

/obj/effect/fd_sword/parry
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "mech_sparks"

	anchored = TRUE
	mouse_opacity = FALSE
	alpha = 0
	layer = ABOVE_MOB_LAYER

/obj/effect/fd_sword/parry/Initialize(mapload, ...)
	. = ..()
	animate(src, alpha = 255, time = 0.3 SECONDS)
	spawn(1 SECONDS)
		animate(src, alpha = 0, time = 0.5 SECONDS)

	spawn(1.5 SECONDS)
		qdel(src)

/obj/effect/fd_sword/cannot_cast_ability
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "cantdoit"

	anchored = TRUE
	mouse_opacity = FALSE
	alpha = 0

/obj/effect/fd_sword/cannot_cast_ability/Initialize(mapload, ...)
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS, flags = ANIMATION_PARALLEL)
	animate(src, pixel_y = 48, time = 0.5 SECONDS, easing = SINE_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)

	spawn(1.5 SECONDS)
		animate(src, alpha = 0, time = 0.5 SECONDS)

	spawn(2 SECONDS)
		qdel(src)

/obj/effect/fd_sword/stunned
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "stun"

	anchored = TRUE
	mouse_opacity = FALSE
	alpha = 0
	layer = BELOW_MOB_LAYER

/obj/effect/fd_sword/stunned/Initialize(mapload, ...)
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS, flags = ANIMATION_PARALLEL)
	animate(src, pixel_x = rand(-32,32), pixel_y = rand(-32,32), time = 0.5 SECONDS, easing = BOUNCE_EASING, flags = ANIMATION_PARALLEL)

	spawn(0.5 SECONDS)
		animate(src, alpha = 0, time = 0.5 SECONDS)

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

/obj/effect/fd_sword/hit_text
	icon_state = ""

	anchored = TRUE
	mouse_opacity = FALSE

	layer = ABOVE_MOB_LAYER

/obj/effect/fd_sword/hit_text/New(loc, damage_number)
	if(damage_number > 0)
		maptext = "<span class='langchat' style=font-size:14pt;text-align:center valign='top'>[damage_number]</span>"

	animate(src, transform = matrix(0.01, MATRIX_SCALE), time = 0)

	. = ..()

/obj/effect/fd_sword/hit_text/Initialize(mapload, ...)
	. = ..()

	animate(src, pixel_y = rand(-64,64), pixel_x = rand(-64,64), time = 1 SECONDS, easing = BOUNCE_EASING, flags = ANIMATION_PARALLEL)
	animate(src, transform = matrix(1.5, MATRIX_SCALE), time = 1 SECONDS, easing = BOUNCE_EASING, flags = ANIMATION_PARALLEL)

	spawn(1 SECONDS)
		animate(src, alpha = 0, time = 0.3 SECONDS)

	spawn(1.3 SECONDS)
		qdel(src)

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

/// TIMESWORD ///

/obj/effect/fd_sword/timeaoe
	name = "ЧАС РАСПЛАТЫ"

	icon = 'code/modules/fd_sword/icons/160x160.dmi'
	icon_state = "time"

	anchored = TRUE
	layer = 5
	pixel_x = -64
	pixel_y = -64

/obj/effect/fd_sword/timeaoe/Initialize(mapload, ...)
	. = ..()
	spawn(1 SECONDS)
		animate(src, alpha = 0, time = 1 SECONDS)
	spawn(2 SECONDS)
		qdel(src)

/obj/effect/fd_sword/timetentacles
	name = "ВРЕМЕННОЙ РАЗРЫВ"

	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "dreamfiend"

	anchored = TRUE
	alpha = 0

/obj/effect/fd_sword/timetentacles/Initialize(mapload, ...)
	. = ..()
	animate(src, alpha = 255, time = 1 SECONDS, flags = ANIMATION_PARALLEL)
	animate(src, pixel_x = -32, time = 1 SECONDS, easing = SINE_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)

	spawn(1.5 SECONDS)
		animate(src, alpha = 0, time = 1 SECONDS)

	spawn(2.5 SECONDS)
		qdel(src)

/obj/effect/fd_sword/timeanchor
	name = "ВРЕМЕННОЙ ЯКОРЬ"

	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "void_conduit_tg"

	anchored = TRUE
	alpha = 0

/obj/effect/fd_sword/timeanchor/Initialize(mapload, ...)
	. = ..()
	animate(src, alpha = 255, time = 1 SECONDS)

/obj/effect/fd_sword/timeanchor/proc/timecurse(mob/living/M)
	M.add_filter("timestopped", 1, list("type" = "blur", "size" = 1))

	M.anchored = TRUE
	ADD_TRAIT(M, TRAIT_IMMOBILIZED, TIMECURSE_TRAIT)
	ADD_TRAIT(M, TRAIT_UNDENSE, TIMECURSE_TRAIT)

	addtimer(CALLBACK(M, TYPE_PROC_REF(/mob/living, reset_timeanchor)), 4 SECONDS)

/obj/effect/fd_sword/timewave
	name = "ВРЕМЕННАЯ ВОЛНА"

	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "summoning"

	anchored = TRUE
	mouse_opacity = FALSE
	layer = ABOVE_MOB_LAYER

/obj/effect/fd_sword/timewave/Initialize(mapload, ...)
	. = ..()
	animate(src, alpha = 0, time = 1 SECONDS)
	spawn(1 SECONDS)
		qdel(src)

/obj/effect/fd_sword/anchored
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "restrained"

	anchored = TRUE
	mouse_opacity = FALSE
	alpha = 0
	layer = BELOW_MOB_LAYER

/obj/effect/fd_sword/anchored/Initialize(mapload, ...)
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS, flags = ANIMATION_PARALLEL)
	animate(src, pixel_y = 48, time = 0.5 SECONDS, easing = SINE_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)

	spawn(0.5 SECONDS)
		animate(src, alpha = 0, time = 0.5 SECONDS)

	spawn(1 SECONDS)
		qdel(src)

/obj/effect/fd_sword/timeanchor/alter
	icon_state = "void_chill_oh_fuck_tg"
	layer = ABOVE_MOB_LAYER

/obj/effect/fd_sword/telegraph_basic/timesword/ranged
	delete_after = 0.5 SECONDS

/obj/effect/fd_sword/telegraph_basic/timesword/aoe
	delete_after = 1 SECONDS

/// WINTERSWORD ///

/obj/effect/fd_sword/ice_aoe
	name = "Ледяная пика"

	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "spike"

	anchored = TRUE
	alpha = 0

/obj/effect/fd_sword/ice_aoe/Initialize(mapload, ...)
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS, flags = ANIMATION_PARALLEL)
	animate(src, pixel_y = 18, time = 0.5 SECONDS, easing = BACK_EASING|EASE_IN, flags = ANIMATION_PARALLEL)

	for(var/mob/living/L in get_turf(src))
		animate(L, pixel_z = 23, time = 0.5 SECONDS, easing = BACK_EASING|EASE_IN)
		new /obj/effect/fd_sword/hit_effect(get_turf(L))
		new /obj/effect/fd_sword/hit_text(get_turf(L), 50)

		L.apply_damage(50, BRUTE)
		shake_camera(L, 2, 1)

	spawn(0.5 SECONDS)
		animate(src, pixel_y = 0, time = 0.2 SECONDS, easing = SINE_EASING|EASE_IN)

		for(var/mob/living/L in get_turf(src))
			animate(L, pixel_z = 0, time = 0.2 SECONDS, easing = SINE_EASING|EASE_IN)

	spawn(0.7 SECONDS)
		animate(src, alpha = 0, time = 0.3 SECONDS)

	spawn(1 SECONDS)
		qdel(src)

/obj/structure/fd_sword/ice_bridge
	name = "Лёд"

	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "ice_bridge"

	anchored = TRUE
	density = FALSE
	var/related_faction = "what"

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
					if(H.srd_faction != related_faction)
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

	if(!slide.density)
		M.forceMove(slide)

	ADD_TRAIT(M, TRAIT_IMMOBILIZED, ICESLIDE_TRAIT)
	ADD_TRAIT(M, TRAIT_UNDENSE, ICESLIDE_TRAIT)

	for(var/i = 0, i <= 3, i++)
		new /obj/effect/fd_sword/stunned(get_turf(M))

	addtimer(CALLBACK(M, TYPE_PROC_REF(/mob/living, standup)), 1 SECONDS)

/obj/effect/fd_sword/sparkles
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "empdisable"

	anchored = TRUE
	mouse_opacity = FALSE
	layer = ABOVE_MOB_LAYER

/obj/effect/fd_sword/sparkles/Initialize(mapload, ...)
	. = ..()
	spawn(1 SECONDS)
		animate(src, alpha = 0, time = 0.5 SECONDS)

	spawn(1.5 SECONDS)
		qdel(src)

/obj/effect/fd_sword/shards_creation
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "ice_shards"

	anchored = TRUE
	mouse_opacity = FALSE
	alpha = 0

/obj/effect/fd_sword/shards_creation/Initialize(mapload, ...)
	. = ..()
	var/matrix/base_matrix = matrix(base_transform)
	update_base_transform(base_matrix.Scale(0.5,0.5))

	animate(src, alpha = 255, time = 1 SECONDS)

	spawn(1.4 SECONDS)
		animate(src, alpha = 0, time = 0.5 SECONDS, flags = ANIMATION_PARALLEL)

	spawn(2 SECONDS)
		qdel(src)

/obj/effect/fd_sword/telegraph_basic/wintersword/aoe
	delete_after = 1 SECONDS

/// GOLDENSWORD ///

/obj/effect/fd_sword/gold
	name = "money"
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "money"

	anchored = TRUE
	mouse_opacity = FALSE

	alpha = 0

/obj/effect/fd_sword/gold/Initialize(mapload, ...)
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS)

	spawn(5 SECONDS)
		animate(src, alpha = 0, time = 0.2 SECONDS)
	spawn(5.2 SECONDS)
		qdel(src)

/obj/effect/fd_sword/gold/Crossed(O)
	. = ..()

	if(istype(O, /mob/living))
		var/mob/living/L = O
		L.add_status_value("gold", 1)

		playsound_client(L.client, 'sound/machines/pda_ping.ogg', L, 25)

	animate(src, alpha = 0, time = 0.2 SECONDS)
	spawn(0.3 SECONDS)
		qdel(src)

/obj/effect/fd_sword/puff
	name = "puff"
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "puff"

	anchored = TRUE
	mouse_opacity = FALSE
	layer = ABOVE_MOB_LAYER

/obj/effect/fd_sword/puff/Initialize(mapload, ...)
	. = ..()
	spawn(0.5 SECONDS)
		qdel(src)

/obj/effect/fd_sword/heal_effect
	name = "healing"
	icon = 'icons/mob/do_afters.dmi'
	icon_state = "busy_medical"

	anchored = TRUE
	mouse_opacity = FALSE
	layer = ABOVE_MOB_LAYER

/obj/effect/fd_sword/heal_effect/Initialize(mapload, ...)
	. = ..()
	spawn(1 SECONDS)
		animate(src, alpha = 0, time = 0.5 SECONDS)

	spawn(1.5 SECONDS)
		qdel(src)

/obj/effect/fd_sword/gold_bomb
	name = "money"
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "money"

	anchored = TRUE
	mouse_opacity = FALSE
	var/related_faction = "what"

/obj/effect/fd_sword/gold_bomb/Initialize(mapload, ...)
	. = ..()

	addtimer(CALLBACK(src, PROC_REF(remove_from_world)), 3 MINUTES)

/obj/effect/fd_sword/gold_bomb/proc/remove_from_world()
	animate(src, alpha = 0, time = 0.2 SECONDS)
	spawn(0.3 SECONDS)
		qdel(src)

/obj/effect/fd_sword/gold_bomb/proc/trigger()
	var/list/target_turfs = list()

	add_filter("detonation", 1, list("type" = "outline", "color" = "#ff0000", "size" = 1))

	spawn(0.5 SECONDS)
		for(var/turf/attack_zone in range(1,src))
			new /obj/effect/fd_sword/telegraph_basic/goldensword/ranged(attack_zone)

			target_turfs += attack_zone

	spawn(1 SECONDS)
		new /obj/effect/block(get_turf(src))
		animate(src, alpha = 0, time = 0.3 SECONDS)

		for(var/turf/T in target_turfs)
			for(var/mob/living/L in T)
				shake_camera(L, 2, 1)
				new /obj/effect/fd_sword/puff(get_turf(L))

				if(L.srd_faction != related_faction)
					if(L.parry_protection)
						playsound(L, pick(GLOB.parry_sound), 50)
						new /obj/effect/block(get_turf(L))
						continue

					for(var/i = 0, i <= 3, i++)
						var/impact_effect = pick(1,2)
						switch(impact_effect)
							if(1)
								new /obj/effect/fd_sword/hit_effect/alt1(get_turf(L))
							if(2)
								new /obj/effect/fd_sword/hit_effect/alt2(get_turf(L))

					new /obj/effect/fd_sword/hit_text(get_turf(L), 20)

					L.set_effect(10, STUN)
					L.apply_damage(20, BRUTE)

				else
					new /obj/effect/fd_sword/heal_effect(get_turf(L))
					L.apply_damage(-20, BRUTE)

	spawn(1.5 SECONDS)
		qdel(src)

/obj/effect/fd_sword/goldensword_fake
	name = "combat sword"
	icon = 'code/modules/fd_sword/icons/swords.dmi'
	icon_state = "goldensword"

	anchored = TRUE
	mouse_opacity = FALSE
	layer = 5
	plane = 5

	alpha = 0

/obj/effect/fd_sword/goldensword_greencard
	name = "GREEN"
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "green"

	anchored = TRUE
	mouse_opacity = FALSE
	layer = 5
	plane = 5

	alpha = 0

/obj/effect/fd_sword/goldensword_greencard/Initialize(mapload, ...)
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS, flags = ANIMATION_PARALLEL)
	animate(src, pixel_y = 32, time = 0.5 SECONDS, easing = SINE_EASING|EASE_IN, flags = ANIMATION_PARALLEL)

	spawn(0.5 SECONDS)
		animate(src, alpha = 0, time = 0.3 SECONDS)

	spawn(0.8 SECONDS)
		qdel(src)

/obj/effect/fd_sword/lightning
	name = "ZZIP"
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "lightning_tg"

	anchored = TRUE
	mouse_opacity = FALSE
	layer = 5
	plane = 5

/obj/effect/fd_sword/lightning/Initialize(mapload, ...)
	. = ..()
	animate(src, alpha = 0, time = 0.5 SECONDS)

	spawn(0.5 SECONDS)
		qdel(src)

/obj/effect/fd_sword/goldensword_redcard
	name = "RED"
	icon = 'code/modules/fd_sword/icons/visuals.dmi'
	icon_state = "red"

	anchored = TRUE
	mouse_opacity = FALSE
	layer = 5
	plane = 5

	alpha = 0

/obj/effect/fd_sword/goldensword_redcard/Initialize(mapload, ...)
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS, flags = ANIMATION_PARALLEL)
	animate(src, pixel_y = 32, time = 0.5 SECONDS, easing = SINE_EASING|EASE_IN, flags = ANIMATION_PARALLEL)

	spawn(0.5 SECONDS)
		animate(src, alpha = 0, time = 0.3 SECONDS)

	spawn(0.8 SECONDS)
		qdel(src)

/obj/effect/fd_sword/telegraph_basic/goldensword/ranged
	delete_after = 0.5 SECONDS
