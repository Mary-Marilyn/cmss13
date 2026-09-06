/obj/structure/machinery/computer/astronav
	name = "astronavigation console"
	desc = "A navigation computer linked to the ship's FTL drive."
	icon_state = "terminal"

/obj/structure/machinery/computer/astronav/attack_alien(mob/living/carbon/xenomorph/user)
	INVOKE_ASYNC(src, TYPE_PROC_REF(/atom, attack_hand), user)
	return XENO_ATTACK_ACTION

/obj/structure/machinery/computer/astronav/attack_hand(mob/living/user)
	if((!ishuman(user) && !isxeno(user)) || user.is_mob_incapacitated() || user.is_mob_restrained() || user.action_busy || !Adjacent(user))
		return
	add_fingerprint(user)

	if(SShijack.hack_status == HIJACK_HACK_COMPLETE)
		to_chat(user, SPAN_WARNING("The new destination has been accepted by ARES. The course can no longer be changed."))
		return
	if(SShijack.hack_status == HIJACK_HACK_LOCKED)
		to_chat(user, SPAN_WARNING("ARES has permanently locked out unauthorized course changes."))
		return

	if(SShijack.hack_status == HIJACK_HACK_ACTIVE)
		if(SShijack.hack_console != src)
			return
		var/can_cancel = isxeno(user)
		if(ishuman(user))
			var/mob/living/carbon/human/human_user = user
			can_cancel = !human_user.ert_type && (human_user.faction in FACTION_LIST_MARINE)
		if(can_cancel)
			user.visible_message(SPAN_WARNING("[user] begins stopping [src]'s the navigation hack!"), SPAN_WARNING("You begin stopping the hack. Stay still."))
			var/interrupt_flags = isxeno(user) ? INTERRUPT_NO_NEEDHAND : INTERRUPT_ALL
			if(!do_after(user, 5 SECONDS, interrupt_flags, BUSY_ICON_HOSTILE, src))
				return
			if(SShijack.hack_status != HIJACK_HACK_ACTIVE || user.is_mob_restrained())
				return
			log_game("[key_name(user)] permanently blocked the hostile navigation upload at [AREACOORD(src)].")
			SShijack.stop_hostile_hack("Unauthorized course upload terminated. Original destination retained.")
			return
		to_chat(user, SPAN_NOTICE("The course upload has [ceil(SShijack.hack_time_remaining / (1 SECONDS))] seconds remaining. Keep the console powered and prevent anyone from touching it."))
		return

	SShijack.start_hostile_hack(src, user)
