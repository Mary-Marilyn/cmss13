/datum/game_mode/colonialmarines/upp
	name = GAMEMODE_UPP_DISTRESS_SIGNAL
	config_tag = GAMEMODE_UPP_DISTRESS_SIGNAL
	human_major = MODE_FACTION_CLASH_UPP_MAJOR
	human_minor = MODE_FACTION_CLASH_UPP_MINOR
	operation_unit = "4th Fleet"
	vote_cycle = 3
	role_mappings = list(
		/datum/job/antag/upp/rifleman = JOB_SQUAD_MARINE,
	)

/datum/game_mode/colonialmarines/upp/get_roles_list()
	return UPP_JOB_LIST + GLOB.ROLES_GROUND

/datum/game_mode/colonialmarines/upp/spawn_lz_sentry(turf/target, list/structures_to_break)
	var/obj/structure/droppod/equipment/sentry_holder/droppod = new(target, /obj/structure/machinery/sentry_holder/landing_zone/upp)
	droppod.special_structures_to_damage = structures_to_break
	droppod.special_structure_damage = 500
	droppod.drop_time = 0
	droppod.launch(target)

/datum/game_mode/colonialmarines/upp/ares_online()
	shipwide_ai_announcement("1VAN/3. Online. Good morning, comrades.", "1VAN/3 Online", 'sound/misc/interference.ogg')

/datum/game_mode/colonialmarines/upp/ares_command_check(mob/living/carbon/human/commander = null, force = FALSE)
	if(acting_commander && !force)
		return

	var/mob/living/carbon/human/person_in_charge = commander
	if(!person_in_charge)
		var/static/list/chain_of_command = list(JOB_UPP_CO_OFFICER, JOB_UPP_KPT_OFFICER, JOB_UPP_SRLT_OFFICER, JOB_UPP_LT_OFFICER, JOB_UPP_PILOT, JOB_UPP_LT_DOKTOR, JOB_UPP_COMMISSAR)
		for(var/role in chain_of_command)
			for(var/mob/living/carbon/human/candidate as anything in GLOB.alive_human_list)
				if(candidate.faction != FACTION_UPP || candidate.job != role || candidate.stat != CONSCIOUS || !candidate.mind || !candidate.get_idcard() || is_mob_cryoing(candidate))
					continue
				person_in_charge = candidate
				break
			if(person_in_charge)
				break

	if(!person_in_charge)
		return log_admin("No valid commander found for automatic promotion.")

	acting_commander = person_in_charge
	if(!commander && (person_in_charge.job in list(JOB_UPP_CO_OFFICER, JOB_UPP_KPT_OFFICER)))
		return

	var/obj/item/card/id/card = person_in_charge.get_idcard()
	if(card)
		card.access |= list(ACCESS_UPP_SENIOR_LEAD)

	shipwide_ai_announcement("Acting Commander authority has been transferred to: [person_in_charge.job] [person_in_charge], who will assume command until further notice. Senior Command access has been added to their ID.", MAIN_AI_SYSTEM, 'sound/misc/interference.ogg')
	message_admins("[key_name(person_in_charge, TRUE)] [ADMIN_JMP_USER(person_in_charge)] has been designated the operation commander.")

/datum/game_mode/colonialmarines/upp/ares_autodoc_check()
	return

/datum/game_mode/colonialmarines/upp/ares_conclude()
	marine_announcement("Bioscan complete. No unknown lifeform signatures detected. Operational report archived. Final systems scan will commence in 3 minutes.", MAIN_AI_SYSTEM)

/datum/game_mode/colonialmarines/upp/end_of_round_ert()
	return

/datum/game_mode/colonialmarines/upp/get_random_call()
	return new /datum/emergency_call/upp/rostock
