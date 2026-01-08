
/datum/equipment_preset/bureau
	name = JOB_BUREAU_AGENT
	flags = EQUIPMENT_PRESET_EXTRA
	assignment = JOB_BUREAU_AGENT
	job_title = JOB_BUREAU_AGENT
	faction = FACTION_NEUTRAL

	access = list(ACCESS_LIST_GLOBAL) // Поменять позже по ситуации
	skills = /datum/skills/general
	idtype = /obj/item/card/id/lanyard

	minimap_icon = "cl"

/datum/equipment_preset/bureau/load_gear(mob/living/carbon/human/new_human)
	new_human.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel(new_human), WEAR_BACK)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/under/colonist/white_service(new_human), WEAR_BODY)
	new_human.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(new_human), WEAR_FEET)

/datum/equipment_preset/bureau/load_id(mob/living/carbon/human/new_human, client/mob_client)
	var/obj/item/clothing/under/uniform = new_human.w_uniform
	if(istype(uniform))
		uniform.has_sensor = UNIFORM_HAS_SENSORS
	return ..()
