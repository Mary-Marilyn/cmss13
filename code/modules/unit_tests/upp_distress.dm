/// Each test restores the running mode and human roster even after an assertion fails.
/datum/unit_test/upp_distress
	var/saved_master_mode
	var/datum/game_mode/saved_mode
	var/list/saved_humans
	var/datum/map_config/saved_ship_config
	var/datum/map_config/test_ship_config
	var/datum/game_mode/colonialmarines/upp/upp_mode

/datum/unit_test/upp_distress/New()
	. = ..()
	saved_master_mode = GLOB.master_mode
	saved_mode = SSticker.mode
	saved_humans = GLOB.alive_human_list
	saved_ship_config = SSmapping.configs[SHIP_MAP]
	test_ship_config = allocate(/datum/map_config)
	test_ship_config.map_name = MAP_ROSTOCK
	SSmapping.configs[SHIP_MAP] = test_ship_config
	GLOB.master_mode = GAMEMODE_UPP_DISTRESS_SIGNAL
	GLOB.alive_human_list = list()
	upp_mode = allocate(/datum/game_mode/colonialmarines/upp)
	upp_mode.round_modifiers = saved_mode.round_modifiers
	SSticker.mode = upp_mode

/datum/unit_test/upp_distress/Destroy()
	. = ..()
	GLOB.master_mode = saved_master_mode
	SSticker.mode = saved_mode
	GLOB.alive_human_list = saved_humans
	SSmapping.configs[SHIP_MAP] = saved_ship_config

/datum/unit_test/upp_distress/Run()
	var/list/roles = upp_mode.get_roles_list()
	TEST_ASSERT(JOB_UPP in roles, "UPP Distress must offer Union infantry.")
	TEST_ASSERT(JOB_UPP_CO_OFFICER in roles, "UPP Distress must offer Union command.")
	TEST_ASSERT(JOB_XENOMORPH in roles, "UPP Distress must retain xenomorph selection.")
	TEST_ASSERT(JOB_SURVIVOR in roles, "UPP Distress must retain survivor selection.")
	for(var/role in GLOB.ROLES_USCM)
		TEST_ASSERT(!(role in roles), "UPP Distress unexpectedly offers USCM role [role].")
	TEST_ASSERT_EQUAL(upp_mode.role_mappings[/datum/job/antag/upp/rifleman], JOB_SQUAD_MARINE, "Union infantry must replace the normal rifleman fallback.")
	var/datum/job/soldier_job = GLOB.RoleAuthority.roles_by_name[JOB_UPP]
	TEST_ASSERT_NOTNULL(soldier_job, "Union infantry must have a selectable job datum.")
	TEST_ASSERT_EQUAL(initial(soldier_job.total_positions), -1, "Union infantry must remain available after one soldier joins.")
	TEST_ASSERT_EQUAL(initial(soldier_job.spawn_positions), -1, "Union infantry must allow more than one roundstart soldier.")

	var/datum/game_mode/colonialmarines/normal_mode = allocate(/datum/game_mode/colonialmarines)
	normal_mode.round_modifiers = saved_mode.round_modifiers
	var/list/normal_roles = normal_mode.get_roles_list()
	TEST_ASSERT(JOB_SQUAD_MARINE in normal_roles, "Normal Distress must still offer USCM infantry.")
	TEST_ASSERT(!(JOB_UPP in normal_roles), "Normal Distress unexpectedly offers Union infantry.")

/datum/unit_test/upp_distress/proc/make_human(faction, job, with_id = FALSE, with_mind = FALSE)
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	human.faction = faction
	human.job = job
	if(with_id)
		var/obj/item/card/id/card = allocate(/obj/item/card/id, human)
		card.access = list()
		human.wear_id = card
	if(with_mind)
		var/datum/mind/mind = allocate(/datum/mind)
		mind.current = human
		mind.active = TRUE
		human.mind = mind
	return human

/datum/unit_test/upp_distress/access/Run()
	for(var/role in list(JOB_UPP, JOB_UPP_PILOT, JOB_UPP_KPT_OFFICER, JOB_UPP_CO_OFFICER))
		var/datum/job/job = GET_MAPPED_ROLE(role)
		TEST_ASSERT_NOTNULL(job, "Union role [role] must have a valid job datum.")
		var/datum/equipment_preset/preset = allocate(job.gear_preset)
		var/mob/living/carbon/human/human = make_human(FACTION_UPP, role)
		human.create_hud()
		human.equip_to_slot_or_del(allocate(/obj/item/clothing/under/marine/veteran/UPP), WEAR_BODY)
		preset.load_id(human)
		var/obj/item/card/id/card = human.get_idcard()
		TEST_ASSERT_NOTNULL(card, "Union role [role] must receive a usable ID from its actual equipment preset.")
		TEST_ASSERT(ACCESS_UPP_GENERAL in card.access, "Union role [role] must receive general ship access.")
		if(role == JOB_UPP)
			TEST_ASSERT(!(ACCESS_UPP_FLIGHT in card.access), "Union infantry must not inherit flight access from the preset constructor.")
			TEST_ASSERT(!(ACCESS_UPP_SENIOR_LEAD in card.access), "Union infantry must not inherit senior command access from the preset constructor.")
		else
			TEST_ASSERT(ACCESS_UPP_FLIGHT in card.access, "Union role [role] must receive flight access from its equipment preset.")
			if(role == JOB_UPP_PILOT)
				TEST_ASSERT(!(ACCESS_UPP_SENIOR_LEAD in card.access), "Union pilots must not inherit senior command access from the preset constructor.")
			else
				TEST_ASSERT(ACCESS_UPP_SENIOR_LEAD in card.access, "Union role [role] must receive senior command access from its equipment preset.")

/datum/unit_test/upp_distress/population/Run()
	var/datum/job/soldier_job = GLOB.RoleAuthority.roles_by_name[JOB_UPP]
	var/datum/job/officer_job = GLOB.RoleAuthority.roles_by_name[JOB_UPP_LT_OFFICER]
	TEST_ASSERT_NOTNULL(soldier_job, "Union infantry must have a selectable job datum.")
	TEST_ASSERT_NOTNULL(officer_job, "Union officers must have a selectable job datum.")
	TEST_ASSERT_EQUAL(GLOB.RoleAuthority.calculate_role_weight(soldier_job), 1, "Union infantry must fund the same xeno population as marine infantry.")
	TEST_ASSERT_EQUAL(GLOB.RoleAuthority.calculate_role_weight(officer_job), 0.25, "Union shipside officers must use shipside population weight.")

	for(var/index in 1 to 52)
		make_human(FACTION_UPP, JOB_UPP)
	make_human(FACTION_UPP, JOB_UPP_LT_OFFICER)
	make_human(FACTION_MARINE, JOB_SQUAD_MARINE)
	make_human(FACTION_SURVIVOR, JOB_SURVIVOR)
	var/mob/living/carbon/human/absent_soldier = make_human(FACTION_UPP, JOB_UPP)
	absent_soldier.moveToNullspace()

	var/list/test_levels = list(run_loc_floor_bottom_left.z)
	TEST_ASSERT_EQUAL(upp_mode.count_marines(test_levels), 53, "Shipside survival must count Union personnel and reject other factions or nullspace.")
	GLOB.alive_human_list -= absent_soldier
	TEST_ASSERT_EQUAL(upp_mode.init_gear_scale(), 52.25 / MARINE_GEAR_SCALING_NORMAL, "Union personnel must increase available supplies, with shipside role weighting and no foreign-faction contribution.")

	GLOB.master_mode = GAMEMODE_DISTRESS_SIGNAL
	test_ship_config.map_name = MAIN_SHIP_DEFAULT_NAME
	var/datum/game_mode/colonialmarines/normal_mode = allocate(/datum/game_mode/colonialmarines)
	normal_mode.round_modifiers = saved_mode.round_modifiers
	SSticker.mode = normal_mode
	TEST_ASSERT_EQUAL(normal_mode.count_marines(test_levels), 1, "Normal Distress must count marines rather than Union personnel.")
	TEST_ASSERT_EQUAL(normal_mode.init_gear_scale(), 1, "Union personnel must not inflate normal Distress supplies.")

/datum/unit_test/upp_distress/succession/Run()
	var/mob/living/carbon/human/foreign_commander = make_human(FACTION_MARINE, JOB_UPP_CO_OFFICER, TRUE, TRUE)
	var/mob/living/carbon/human/unconscious_commander = make_human(FACTION_UPP, JOB_UPP_CO_OFFICER, TRUE, TRUE)
	unconscious_commander.set_stat(UNCONSCIOUS)
	make_human(FACTION_UPP, JOB_UPP_KPT_OFFICER, FALSE, TRUE)
	make_human(FACTION_UPP, JOB_UPP_SRLT_OFFICER, TRUE, FALSE)
	var/mob/living/carbon/human/cryo_commander = make_human(FACTION_UPP, JOB_UPP_SRLT_OFFICER, TRUE, TRUE)
	var/obj/structure/machinery/cryopod/pod = allocate(/obj/structure/machinery/cryopod)
	cryo_commander.forceMove(pod)
	var/mob/living/carbon/human/lieutenant = make_human(FACTION_UPP, JOB_UPP_LT_OFFICER, TRUE, TRUE)
	var/obj/item/card/id/card = lieutenant.get_idcard()
	card.access = list(ACCESS_UPP_LEADERSHIP)

	upp_mode.ares_command_check()
	TEST_ASSERT_EQUAL(upp_mode.acting_commander, lieutenant, "Succession must select an available Union officer with a mind and usable ID.")
	TEST_ASSERT(ACCESS_UPP_SENIOR_LEAD in card.access, "The acting commander must be able to use senior Union controls.")
	TEST_ASSERT(!(ACCESS_MARINE_SENIOR in card.access), "Union promotion must not grant USCM command access.")
	TEST_ASSERT(!(ACCESS_UPP_SENIOR_LEAD in foreign_commander.get_idcard().access), "Succession must not promote a foreign-faction officer.")
	TEST_ASSERT(!(ACCESS_UPP_SENIOR_LEAD in unconscious_commander.get_idcard().access), "Succession must not promote an unconscious officer.")

	unconscious_commander.set_stat(CONSCIOUS)
	upp_mode.ares_command_check()
	TEST_ASSERT_EQUAL(upp_mode.acting_commander, lieutenant, "Automatic succession must preserve an existing acting commander.")
	upp_mode.ares_command_check(force = TRUE)
	TEST_ASSERT_EQUAL(upp_mode.acting_commander, unconscious_commander, "Forced succession must honor the highest available Union rank.")

/datum/unit_test/upp_distress/endings
	var/list/saved_hives
	var/datum/hive_status/test_hive

/datum/unit_test/upp_distress/endings/New()
	. = ..()
	saved_hives = GLOB.hive_datum
	test_hive = new
	GLOB.hive_datum = list(XENO_HIVE_NORMAL = test_hive)

/datum/unit_test/upp_distress/endings/Destroy()
	. = ..()
	GLOB.hive_datum = saved_hives
	QDEL_NULL(test_hive.hive_ui)
	QDEL_NULL(test_hive.mark_ui)
	QDEL_NULL(test_hive.faction_ui)
	QDEL_NULL(test_hive)

/datum/unit_test/upp_distress/endings/Run()
	var/mob/living/carbon/xenomorph/fourth_xeno
	for(var/index in 1 to 4)
		fourth_xeno = allocate(/mob/living/carbon/xenomorph/drone)
	upp_mode.check_queen_status(XENO_HIVE_NORMAL, immediately = TRUE)
	TEST_ASSERT_EQUAL(upp_mode.round_finished, MODE_FACTION_CLASH_UPP_MINOR, "A collapsed hive with more than three survivors must give Union forces a minor victory.")
	TEST_ASSERT(upp_mode.check_finished(), "Union victory must actually end the parent Distress game mode.")
	TEST_ASSERT_EQUAL(upp_mode.end_round_message(), "Round has ended. [MODE_FACTION_CLASH_UPP_MINOR].", "The status panel must show a Union victory after hive collapse.")

	var/datum/game_mode/colonialmarines/normal_mode = allocate(/datum/game_mode/colonialmarines)
	normal_mode.round_modifiers = saved_mode.round_modifiers
	normal_mode.check_queen_status(XENO_HIVE_NORMAL, immediately = TRUE)
	TEST_ASSERT_EQUAL(normal_mode.round_finished, MODE_INFESTATION_M_MINOR, "Normal Distress hive collapse must still give a marine minor victory.")

	qdel(fourth_xeno)
	upp_mode.round_finished = null
	upp_mode.check_queen_status(XENO_HIVE_NORMAL, immediately = TRUE)
	TEST_ASSERT_EQUAL(upp_mode.round_finished, MODE_FACTION_CLASH_UPP_MAJOR, "A collapsed hive with at most three survivors must give Union forces a major victory.")
	normal_mode.round_finished = null
	normal_mode.check_queen_status(XENO_HIVE_NORMAL, immediately = TRUE)
	TEST_ASSERT_EQUAL(normal_mode.round_finished, MODE_INFESTATION_M_MAJOR, "Normal Distress hive collapse must still give a marine major victory.")

/datum/unit_test/upp_distress/shuttles
	var/list/saved_stationary
	var/list/saved_associations

/datum/unit_test/upp_distress/shuttles/New()
	. = ..()
	saved_stationary = SSshuttle.stationary
	saved_associations = SSshuttle.assoc_stationary
	SSshuttle.stationary = list()
	SSshuttle.assoc_stationary = list()

/datum/unit_test/upp_distress/shuttles/Destroy()
	. = ..()
	SSshuttle.stationary = saved_stationary
	SSshuttle.assoc_stationary = saved_associations

/datum/unit_test/upp_distress/shuttles/Run()
	var/obj/docking_port/stationary/marine_dropship/lz1/lz = allocate(/obj/docking_port/stationary/marine_dropship/lz1)
	var/obj/docking_port/stationary/marine_dropship/upp/hangar_1/hangar = allocate(/obj/docking_port/stationary/marine_dropship/upp/hangar_1)
	var/obj/docking_port/stationary/marine_dropship/yautja_hangar_1/hunter_hangar = allocate(/obj/docking_port/stationary/marine_dropship/yautja_hangar_1)
	var/obj/structure/machinery/computer/shuttle/dropship/flight/lz1/remote = allocate(/obj/structure/machinery/computer/shuttle/dropship/flight/lz1)
	var/mob/living/carbon/human/pilot = make_human(FACTION_UPP, JOB_UPP_PILOT, TRUE)
	var/obj/item/card/id/card = pilot.get_idcard()
	card.access = list(ACCESS_UPP_FLIGHT)
	TEST_ASSERT(remote.allowed(pilot), "Union pilots must be able to use the shared ground landing-zone console.")
	TEST_ASSERT(lz in remote.compatible_landing_zones, "Union landing-zone controls must find the shared ground pad.")
	TEST_ASSERT(hangar in remote.compatible_landing_zones, "Union landing-zone controls must find the Rostock hangar.")
	TEST_ASSERT(!(hunter_hangar in remote.compatible_landing_zones), "Union landing-zone controls must exclude Yautja hangars.")
	card.access = list(ACCESS_MARINE_DROPSHIP)
	TEST_ASSERT(!remote.allowed(pilot), "USCM pilot access must not unlock Union landing-zone controls.")

	GLOB.master_mode = GAMEMODE_DISTRESS_SIGNAL
	test_ship_config.map_name = MAIN_SHIP_DEFAULT_NAME
	var/obj/docking_port/stationary/marine_dropship/lz2/normal_lz = allocate(/obj/docking_port/stationary/marine_dropship/lz2)
	var/obj/structure/machinery/computer/shuttle/dropship/flight/lz2/normal_remote = allocate(/obj/structure/machinery/computer/shuttle/dropship/flight/lz2)
	TEST_ASSERT(normal_remote.allowed(pilot), "Normal Distress must preserve USCM pilot access to shared landing-zone controls.")
	TEST_ASSERT(normal_lz in normal_remote.compatible_landing_zones, "Normal Distress must preserve the marine ground-pad route.")
	TEST_ASSERT(!(hangar in normal_remote.compatible_landing_zones), "Normal Distress ground controls must exclude Union hangars.")

/// Run these assertions when the real Rostock ship is loaded, without damaging it.
/datum/unit_test/upp_distress_map/Run()
	var/datum/map_config/ship_config = SSmapping.configs[SHIP_MAP]
	if(ship_config?.map_name != MAP_ROSTOCK)
		return
	TEST_ASSERT(length(GLOB.observer_starts), "Rostock must provide a safe observer spawn.")
	TEST_ASSERT(istype(SSticker.mode, /datum/game_mode/colonialmarines/upp), "Loading Rostock for Union Distress must select the actual Union game mode.")
	TEST_ASSERT_EQUAL(GLOB.master_mode, GAMEMODE_UPP_DISTRESS_SIGNAL, "The loaded Rostock round must retain the selected Union Distress mode.")
	var/datum/job/fallback_job = GET_MAPPED_ROLE(JOB_SQUAD_MARINE)
	TEST_ASSERT_NOTNULL(fallback_job, "The loaded Union round must have a usable infantry fallback.")
	TEST_ASSERT_EQUAL(fallback_job.title, JOB_UPP, "Players choosing the rifleman fallback must become Union infantry in the loaded round.")
	TEST_ASSERT_EQUAL(GLOB.RoleAuthority.roles_for_mode[JOB_UPP], fallback_job, "The Union infantry fallback must be a selectable role in the loaded round.")
	TEST_ASSERT_EQUAL(fallback_job.total_positions, -1, "The loaded Union round must retain unlimited infantry slots.")
	TEST_ASSERT_EQUAL(GET_DEFAULT_ROLE(JOB_UPP_MEDIC), JOB_UPP_MEDIC, "Union medics must retain their Union squad specialty key.")
	TEST_ASSERT_EQUAL(GET_DEFAULT_ROLE(JOB_UPP_ENGI), JOB_UPP_ENGI, "Union sappers must retain their Union squad specialty key.")
	for(var/squad_type in list(/datum/squad/upp/one, /datum/squad/upp/two, /datum/squad/upp/three, /datum/squad/upp/four))
		var/datum/squad/upp/squad = GLOB.RoleAuthority.squads_by_type[squad_type]
		TEST_ASSERT_NOTNULL(squad, "Union squad [squad_type] must be available in the loaded round.")
		TEST_ASSERT_EQUAL(squad.roles_cap[GET_DEFAULT_ROLE(JOB_UPP_MEDIC)], 4, "Union squads must retain four medic slots.")
		TEST_ASSERT_EQUAL(squad.roles_cap[GET_DEFAULT_ROLE(JOB_UPP_ENGI)], 3, "Union squads must retain three sapper slots.")
		TEST_ASSERT(GET_DEFAULT_ROLE(JOB_UPP) in squad.roles_cap, "Union infantry must participate in squad balancing after fallback mapping.")
	TEST_ASSERT_EQUAL(SSmapping.get_main_faction(), FACTION_UPP, "The loaded Rostock must be the Union's main ship.")
	var/has_ship_ai = FALSE
	for(var/mob/living/silicon/decoy/ship_ai/upp/ai in GLOB.ai_mob_list)
		if(!is_mainship_level(ai.z))
			continue
		has_ship_ai = TRUE
		TEST_ASSERT_EQUAL(ai.ai_headset?.frequency, UPP_FREQ, "The Union ship AI must broadcast on Union radio.")
	TEST_ASSERT(has_ship_ai, "Rostock must register its Union ship AI for automated announcements.")
	TEST_ASSERT(istype(SShijack.spaceport, /datum/spaceport/upp/rostock), "Rostock must have a friendly Union rescue destination.")
	TEST_ASSERT(length(SShijack.apcs), "Rostock APCs must participate in hijack damage and power handling.")
	TEST_ASSERT(length(SShijack.powernets), "Rostock power networks must participate in hijack power handling.")
	var/has_fuel_pump = FALSE
	for(var/area_key, machine in SShijack.area_machinery_lookup)
		var/obj/structure/machinery/fuelpump/pump = machine
		if(istype(pump) && is_mainship_level(pump.z))
			has_fuel_pump = TRUE
			TEST_ASSERT_EQUAL(get_area(pump), area_key, "Rostock's fuel pump must register under its mapped area.")
	TEST_ASSERT(has_fuel_pump, "Rostock's mapped fuel pump must participate in hijack and self-destruct handling.")
	TEST_ASSERT_EQUAL(length(SShijack.progress_areas), 2, "Rostock must have both powered evacuation objectives.")
	TEST_ASSERT_NOTNULL(SSshuttle.getShuttle(MOBILE_SHUTTLE_LIFEBOAT_ROSTOCK, FALSE), "Rostock's lifeboat must be loaded.")
	for(var/role in UPP_JOB_LIST)
		var/datum/job/job = GET_MAPPED_ROLE(role)
		TEST_ASSERT_NOTNULL(job, "Union role [role] must have a valid job datum.")
		var/has_spawns = length(GLOB.spawns_by_job[job.type])
		for(var/squad in GLOB.spawns_by_squad_and_job)
			has_spawns = has_spawns || length(GLOB.spawns_by_squad_and_job[squad][job.type])
		TEST_ASSERT(has_spawns, "Union role [role] must have an actual roundstart landmark on Rostock.")
	var/datum/dropship_hijack/almayer/hijack = allocate(/datum/dropship_hijack/almayer)
	for(var/section in GLOB.almayer_ship_sections)
		var/turf/crash_turf = hijack.get_crashsite_turf(section)
		TEST_ASSERT_NOTNULL(crash_turf, "Rostock crash section [section] has no mapped target.")
		TEST_ASSERT(is_mainship_level(crash_turf.z), "Rostock crash section [section] targets the wrong z-level.")
	for(var/shuttle_id in list(DROPSHIP_MORANA, DROPSHIP_DEVANA))
		var/obj/docking_port/mobile/marine_dropship/dropship = SSshuttle.getShuttle(shuttle_id, FALSE)
		TEST_ASSERT_NOTNULL(dropship, "Rostock dropship [shuttle_id] must be loaded.")
		var/obj/structure/machinery/computer/shuttle/dropship/flight/console = dropship.getControlConsole()
		TEST_ASSERT_NOTNULL(console, "Rostock dropship [shuttle_id] must have a working flight console.")
		TEST_ASSERT_EQUAL(console.faction, FACTION_UPP, "Rostock dropship [shuttle_id] must use Union flight routes.")
		TEST_ASSERT(length(console.compatible_landing_zones) > 1, "Rostock dropship [shuttle_id] must be able to route between ship and colony.")
		var/obj/structure/machinery/computer/dropship_weapons/upp/equipment_console
		for(var/obj/structure/machinery/computer/dropship_weapons/upp/candidate in GLOB.machines)
			if(candidate.shuttle_tag == shuttle_id && is_mainship_level(candidate.z))
				equipment_console = candidate
				break
		TEST_ASSERT_NOTNULL(equipment_console, "Rostock dropship [shuttle_id] must have Union equipment controls.")
