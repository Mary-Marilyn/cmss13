/datum/spaceport
	/// The name that will be displayed while on route to this destination
	var/name = ""

	/// The message that will be sent when docking is initiated
	var/docking_message = "Attention, USCM vessel. We are launching umbilical cords and deploying a squad to investigate the nature of your distress."
	/// The message that will be sent when the station undocks the ship
	var/undocking_message = "Boarding operations have failed. This station will make no further recovery attempts."

	/// The allies that will be spawned by arriving at this station (only one entry chosen randomly per call)
	var/list/allies

	/// Excluded from random destinations
	var/hostile = FALSE

/datum/spaceport/uscm
	name = "Mont-Blanc 41 LG Station"
	docking_message = "Attention, USS Almayer. This is Captain Pereira with the Solar Devils Battalion, for a ship from the Falcons you're far off course.. Initiate docking procedures, we're sending in a team now."
	undocking_message = "Almayer, this is Pereira. I sent good Marines over there to bring your people home. Now they're all dead. We're cutting the umbilical before that thing reaches Mont-Blanc. I'm sorry. I will not lose another Marine to your ship. Pereira out."
	allies = list(
		/datum/emergency_call/solar_devils,
		/datum/emergency_call/solar_devils_full,
	)

/datum/spaceport/cmb
	name = "Anchorpoint Station"
	docking_message = "This is Chief Deputy Marshal Whittaker with the Colonial Marshal Bureau, Anchorpoint Station. We're investigating the nature of your distress signal. Initiate docking procedures at tower four."
	undocking_message = "Almayer, this is Whittaker. My deputies aren't answering, and your decks are crawling with those things. Tower four, disengage the umbilical. Do it now. The vessel is under permanent quarantine. God help anyone still aboard."
	allies = list(
		/datum/emergency_call/cmb/riot_control,
		/datum/emergency_call/cmb,
	)

/datum/spaceport/upp
	name = "Znoy Outpost"
	docking_message = "Attention, USCM vessel. You have encroached on UPP territory. We are launching umbilical cords and deploying a squad to investigate the nature of your distress."
	undocking_message = "American vessel. Znoy is cutting you loose. You will alter course away from Union territory immediately. If you drift back toward this outpost, or make any attempt to reconnect, we will launch anti-ship missiles and reduce the Almayer to debris."
	allies = list(
		/datum/emergency_call/upp/friendly,
	)

/datum/spaceport/upp/hostile
	name = "Altai Station"
	hostile = TRUE
	docking_message = "American ship, this is Altai Station of the Union of Progressive Peoples, 17th 'Smoldering Sons' Battalion. By order of Kolonel Ganbaatar, disarm your crew and prepare to surrender the ship. Our boarding parties are on their way."
	undocking_message = "Cut the American ship loose and bring the jammers to full power so they don't find it. We will notify the Ministry of Space Security and give them everything we have. They will deal with the Almayer from here."
	allies = list(
		/datum/emergency_call/upp/hostile,
	)

/datum/spaceport/clf
	name = "New Xibou Outpost"
	hostile = TRUE
	docking_message = "Well, look what they dragged in. You remember Tychon Tackle? We do. Funny how things turn around, never thought we'd get the Almayer handed to us like this. Bring 'em in. We've got a few scores to settle."
	undocking_message = "They're gone... Every last one we sent over. Cut the damn ship off. The Almayer can rot out there with whatever's left aboard. We've lost enough people to that ship already."
	allies = list(
		/datum/emergency_call/clf,
	)

/datum/spaceport/vanguard
	name = "Irkala Station"
	docking_message = "Attention, USCM vessel. We are launching umbilical cords and deploying a squad to investigate the nature of your distress in accordance with the Military Aid Act of 2177."
	undocking_message = "Almayer, Irkala Control. There is nobody left answering us from the inside. We cannot let that ship take this station with it. We're releasing you now, sorry."
	allies = list(
		/datum/emergency_call/contractors,
		/datum/emergency_call/contractors/covert,
	)

/datum/spaceport/vanguard/lancer
	name = "Geldmann Outpost"
	undocking_message = "What the fuck are those things? Whatever is inside your ship is coming for us next. We're blowing the umbilical. Contract's over. I'm sorry"
	allies = list(
		/datum/emergency_call/mercs/friendly, //left out elite since they're way too OP.
	)

/datum/spaceport/vanguard/lancer/hostile
	name = "Port Gallows"
	hostile = TRUE
	docking_message = "Holy shit, you actually got us a whole warship! Boys, get the cutters ready. Somebody wake the yard crews and tell them we just hit the fucking jackpot. We're going to be stripping this thing for months."
	undocking_message = "Fuck the salvage! Blow the umbilical before those things get in here! I'm not losing the whole port over a pile of scrap."
	allies = list(
		/datum/emergency_call/mercs/hostile,
	)

/datum/spaceport/royal_commandos
	name = "Port Yamanashi"
	docking_message = "Attention, USCM vessel. Initiate docking procedures immediately, we are deploying a squad to investigate the nature of your distress in accordance with the Military Aid Act of 2177." //i liked the idea of the almayer docking itself to a port
	undocking_message = "The ship is lost. Dockmaster, cast her off! Quarantine protocols will remain in force, may the dead have peace. Godspeed."
	allies = list(
		/datum/emergency_call/royal_marines,
	)

/datum/spaceport/pmc
	name = "Tenshoku Station"
	docking_message = "Attention, USCM vessel. Initiate docking procedures immediately, we are deploying a squad to investigate the nature of your distress in accordance with the Military Aid Act of 2177."
	undocking_message = "Cut the umbilical, but don't destroy the ship. Contact Director Kessler, Special Projects Division. Tell him we have a live infestation in control of an Arikara-class warship. Yes, intact. He'll want to see this personally."
	allies = list(
		/datum/emergency_call/pmc,
	)

/datum/spaceport/pmc/hostile
	name = "USCSS Royce"
	hostile = TRUE
	docking_message = "Almayer, this is Director Kessler, Special Projects Division. I'm sure the circumstances have left you with a great many questions. Fortunately, you've come to the right place for the answers. Keep your personnel clear of the docking areas. Our team will meet you shortly"
	undocking_message = "Disengage the umbilical and establish a containment perimeter around the Almayer. Do not fire on the vessel unless it threatens the Royce. Special Projects will reassess our options."
	allies = list(
		/datum/emergency_call/wy_commando/hostile,
	)
