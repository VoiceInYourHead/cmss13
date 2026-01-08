/datum/timelock/bureau
	name = "Bureau Roles"

/datum/timelock/bureau/New(name, time_required, list/roles)
	. = ..()
	src.roles = JOB_BUREAU_ROLES_LIST

/datum/job/bureau/agent
	title = JOB_BUREAU_AGENT
	total_positions = -1
	spawn_positions = -1
	selection_class = "job_cl"
	supervisors = "no one"
	gear_preset = /datum/equipment_preset/bureau
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT

/obj/effect/landmark/start/bureau/agent
	name = JOB_BUREAU_AGENT
	icon_state = "cl_spawn"
	job = /datum/job/bureau/agent
