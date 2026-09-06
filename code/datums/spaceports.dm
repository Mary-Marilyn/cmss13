/datum/spaceport
	/// The name that will be displayed while on route to this destination
	var/name = ""

	/// The message that will be sent when docking is initiated
	var/docking_message = "Attention, USCM vessel. We are launching umbilical cords and deploying a squad to investigate the nature of your distress."

	/// The allies that will be spawned by arriving at this station (only one entry chosen randomly per call)
	var/list/allies

	/// Excluded from random destinations
	var/hostile = FALSE

/datum/spaceport/uscm
	name = "Mont-Blanc 41 LG Station"
	docking_message = "Attention, USS Almayer. This is Captain Pereira with the Solar Devils Battalion, for a ship from the Falcons you're far off course.. Initiate docking procedures, we're sending in a team now."
	allies = list(
		/datum/emergency_call/solar_devils,
		/datum/emergency_call/solar_devils_full,
	)

/datum/spaceport/cmb
	name = "Anchorpoint Station"
	docking_message = "This is Chief Deputy Marshal Whittaker with the Colonial Marshal Bureau, Anchorpoint Station. We're investigating the nature of your distress signal. Initiate docking procedures at tower four."
	allies = list(
		/datum/emergency_call/cmb/riot_control,
		/datum/emergency_call/cmb,
	)

/datum/spaceport/upp
	name = "Znoy Outpost"
	docking_message = "Attention, USCM vessel. You have encroached on UPP territory. We are launching umbilical cords and deploying a squad to investigate the nature of your distress."
	allies = list(
		/datum/emergency_call/upp/friendly,
	)

/datum/spaceport/upp/hostile
	name = "Altai Station"
	hostile = TRUE
	docking_message = "American ship, this is Altai Station of the Union of Progressive Peoples, 17th 'Smoldering Sons' Battalion. By order of Kolonel Ganbaatar, disarm your crew and prepare to surrender the ship. Our boarding parties are on their way."
	allies = list(
		/datum/emergency_call/upp/hostile,
	)

/datum/spaceport/clf
	name = "New Xibou Outpost"
	hostile = TRUE
	docking_message = "Well, look what they dragged in. You remember Tychon Tackle? We do. Funny how things turn around, never thought we'd get the Almayer handed to us like this. Bring 'em in. We've got a few scores to settle."
	allies = list(
		/datum/emergency_call/clf,
	)

/datum/spaceport/vanguard
	name = "Irkala Station"
	docking_message = "Attention, USCM vessel. We are launching umbilical cords and deploying a squad to investigate the nature of your distress in accordance with the Military Aid Act of 2177."
	allies = list(
		/datum/emergency_call/contractors,
		/datum/emergency_call/contractors/covert,
	)

/datum/spaceport/vanguard/lancer
	name = "Geldmann Outpost"
	allies = list(
		/datum/emergency_call/mercs/friendly, //left out elite since they're way too OP.
	)

/datum/spaceport/vanguard/lancer/hostile
	name = "Port Gallows"
	hostile = TRUE
	docking_message = "Holy shit, you actually got us a whole warship! Boys, get the cutters ready. Somebody wake the yard crews and tell them we just hit the fucking jackpot. We're going to be stripping this thing for months."
	allies = list(
		/datum/emergency_call/mercs/hostile,
	)

/datum/spaceport/royal_commandos
	name = "Port Yamanashi"
	docking_message = "Attention, USCM vessel. Initiate docking procedures immediately, we are deploying a squad to investigate the nature of your distress in accordance with the Military Aid Act of 2177." //i liked the idea of the almayer docking itself to a port
	allies = list(
		/datum/emergency_call/royal_marines,
	)

/datum/spaceport/pmc
	name = "Tenshoku Station"
	docking_message = "Attention, USCM vessel. Initiate docking procedures immediately, we are deploying a squad to investigate the nature of your distress in accordance with the Military Aid Act of 2177."
	allies = list(
		/datum/emergency_call/pmc,
	)

/datum/spaceport/pmc/hostile
	name = "USCSS Royce"
	hostile = TRUE
	docking_message = "Almayer, this is Director Kessler, Special Projects Division. We're glad to see you've made it here. Maintain your present course and keep your personnel clear of the docking areas. A company team will meet you shortly."
	allies = list(
		/datum/emergency_call/wy_commando/hostile,
	)
