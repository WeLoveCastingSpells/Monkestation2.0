#define PARTY_COOLDOWN_LENGTH_MIN (6 MINUTES)
#define PARTY_COOLDOWN_LENGTH_MAX (12 MINUTES)


/datum/station_trait/lucky_winner
	name = "Lucky winner"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 1
	show_in_report = TRUE
	report_message = "Your station has won the grand prize of the annual station charity event. Free snacks will be delivered to the bar every now and then."
	trait_processes = TRUE
	COOLDOWN_DECLARE(party_cooldown)

/datum/station_trait/lucky_winner/on_round_start()
	. = ..()
	COOLDOWN_START(src, party_cooldown, rand(PARTY_COOLDOWN_LENGTH_MIN, PARTY_COOLDOWN_LENGTH_MAX))

/datum/station_trait/lucky_winner/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, party_cooldown))
		return

	COOLDOWN_START(src, party_cooldown, rand(PARTY_COOLDOWN_LENGTH_MIN, PARTY_COOLDOWN_LENGTH_MAX))

	var/area/area_to_spawn_in = pick(GLOB.bar_areas)
	var/turf/T = pick(area_to_spawn_in.contents)

	var/obj/structure/closet/supplypod/centcompod/toLaunch = new()
	var/obj/item/pizzabox/pizza_to_spawn = pick(list(/obj/item/pizzabox/margherita, /obj/item/pizzabox/mushroom, /obj/item/pizzabox/meat, /obj/item/pizzabox/vegetable, /obj/item/pizzabox/pineapple))
	new pizza_to_spawn(toLaunch)
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/cup/glass/bottle/beer(toLaunch)
	new /obj/effect/pod_landingzone(T, toLaunch)

/datum/station_trait/galactic_grant
	name = "Galactic grant"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Your station has been selected for a special grant. Some extra funds has been made available to your cargo department."

/datum/station_trait/galactic_grant/on_round_start()
	var/datum/bank_account/cargo_bank = SSeconomy.get_dep_account(ACCOUNT_CAR)
	cargo_bank.adjust_money(rand(2000, 5000))

/datum/station_trait/premium_internals_box
	name = "Premium internals boxes"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "The internals boxes for your crew have been upsized and filled with bonus equipment."
	trait_to_give = STATION_TRAIT_PREMIUM_INTERNALS

/datum/station_trait/bountiful_bounties
	name = "Bountiful bounties"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "It seems collectors in this system are extra keen to on bounties, and will pay more to see their completion."

/datum/station_trait/bountiful_bounties/on_round_start()
	SSeconomy.bounty_modifier *= 1.2

/datum/station_trait/strong_supply_lines
	name = "Strong supply lines"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Prices are low in this system, BUY BUY BUY!"
	blacklist = list(/datum/station_trait/distant_supply_lines)


/datum/station_trait/strong_supply_lines/on_round_start()
	SSeconomy.pack_price_modifier *= 0.8

/datum/station_trait/filled_maint
	name = "Filled up maintenance"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Our workers accidentally forgot more of their personal belongings in the maintenace areas."
	blacklist = list(/datum/station_trait/empty_maint)
	trait_to_give = STATION_TRAIT_FILLED_MAINT

	// This station trait is checked when loot drops initialize, so it's too late
	can_revert = FALSE

/datum/station_trait/quick_shuttle
	name = "Quick Shuttle"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Due to proximity to our supply station, the cargo shuttle will have a quicker flight time to your cargo department."
	blacklist = list(/datum/station_trait/slow_shuttle)

/datum/station_trait/quick_shuttle/on_round_start()
	. = ..()
	SSshuttle.supply.callTime *= 0.5

/datum/station_trait/deathrattle_department
	name = "deathrattled department"
	trait_type = STATION_TRAIT_POSITIVE
	show_in_report = TRUE
	trait_flags = STATION_TRAIT_ABSTRACT
	blacklist = list(/datum/station_trait/deathrattle_all)

	var/department_to_apply_to
	var/department_name = "department"
	var/datum/deathrattle_group/deathrattle_group

/datum/station_trait/deathrattle_department/New()
	. = ..()
	deathrattle_group = new("[department_name] group")
	blacklist += subtypesof(/datum/station_trait/deathrattle_department) - type //All but ourselves
	report_message = "All members of [department_name] have received an implant to notify each other if one of them dies. This should help improve job-safety!"
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))


/datum/station_trait/deathrattle_department/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER

	if(!(job.departments_bitflags & department_to_apply_to))
		return

	var/obj/item/implant/deathrattle/implant_to_give = new()
	deathrattle_group.register(implant_to_give)
	implant_to_give.implant(spawned, spawned, TRUE, TRUE)


/datum/station_trait/deathrattle_department/service
	name = "Deathrattled Service"
	trait_flags = NONE
	weight = 1
	department_to_apply_to = DEPARTMENT_BITFLAG_SERVICE
	department_name = "Service"

/datum/station_trait/deathrattle_department/cargo
	name = "Deathrattled Cargo"
	trait_flags = NONE
	weight = 1
	department_to_apply_to = DEPARTMENT_BITFLAG_CARGO
	department_name = "Cargo"

/datum/station_trait/deathrattle_department/engineering
	name = "Deathrattled Engineering"
	trait_flags = NONE
	weight = 1
	department_to_apply_to = DEPARTMENT_BITFLAG_ENGINEERING
	department_name = "Engineering"

/datum/station_trait/deathrattle_department/command
	name = "Deathrattled Command"
	trait_flags = NONE
	weight = 1
	department_to_apply_to = DEPARTMENT_BITFLAG_COMMAND
	department_name = "Command"

/datum/station_trait/deathrattle_department/science
	name = "Deathrattled Science"
	trait_flags = NONE
	weight = 1
	department_to_apply_to = DEPARTMENT_BITFLAG_SCIENCE
	department_name = "Science"

/datum/station_trait/deathrattle_department/security
	name = "Deathrattled Security"
	trait_flags = NONE
	weight = 1
	department_to_apply_to = DEPARTMENT_BITFLAG_SECURITY
	department_name = "Security"

/datum/station_trait/deathrattle_department/medical
	name = "Deathrattled Medical"
	trait_flags = NONE
	weight = 1
	department_to_apply_to = DEPARTMENT_BITFLAG_MEDICAL
	department_name = "Medical"

/datum/station_trait/deathrattle_all
	name = "Deathrattled Station"
	trait_type = STATION_TRAIT_POSITIVE
	show_in_report = TRUE
	weight = 1
	report_message = "All members of the station have received an implant to notify each other if one of them dies. This should help improve job-safety!"
	var/datum/deathrattle_group/deathrattle_group


/datum/station_trait/deathrattle_all/New()
	. = ..()
	deathrattle_group = new("station group")
	blacklist = subtypesof(/datum/station_trait/deathrattle_department)
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))


/datum/station_trait/deathrattle_all/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER

	var/obj/item/implant/deathrattle/implant_to_give = new()
	deathrattle_group.register(implant_to_give)
	implant_to_give.implant(spawned, spawned, TRUE, TRUE)

/datum/station_trait/cybernetic_revolution
	name = "Cybernetic Revolution"
	trait_type = STATION_TRAIT_POSITIVE
	show_in_report = TRUE
	weight = 2 // monkestation edit
	report_message = "The new trends in cybernetics have come to the station! Everyone has some form of cybernetic implant."
	trait_to_give = STATION_TRAIT_CYBERNETIC_REVOLUTION
	/// List of all job types with the cybernetics they should receive.
	var/static/list/job_to_cybernetic = list(
		/datum/job/assistant = list(/obj/item/organ/internal/cyberimp/leg/table_glider, /obj/item/organ/internal/cyberimp/leg/table_glider/l),
		/datum/job/atmospheric_technician = /obj/item/organ/internal/cyberimp/arm/item_set/atmospherics,
		/datum/job/barber = /obj/item/organ/internal/cyberimp/arm/item_set/barber,
		/datum/job/bartender = /obj/item/organ/internal/liver/cybernetic/tier3,
		/datum/job/bitrunner = /obj/item/organ/internal/eyes/robotic/thermals,
		/datum/job/blueshield = /obj/item/organ/internal/cyberimp/arm/ammo_counter,
		/datum/job/brig_physician = /obj/item/organ/internal/cyberimp/arm/item_set/surgery,
		/datum/job/botanist = /obj/item/organ/internal/cyberimp/arm/item_set/botany,
		/datum/job/candysalesman =  /obj/item/organ/internal/cyberimp/chest/nutriment/plus,
		/datum/job/captain = /obj/item/organ/internal/heart/cybernetic/tier3,
		/datum/job/cargo_technician = list(/obj/item/organ/internal/cyberimp/leg/sprinter, /obj/item/organ/internal/cyberimp/leg/sprinter/l),
		/datum/job/chaplain = /obj/item/organ/internal/cyberimp/brain/anti_drop,
		/datum/job/chemist = /obj/item/organ/internal/liver/cybernetic/tier3,
		/datum/job/chief_engineer = /obj/item/organ/internal/cyberimp/chest/thrusters,
		/datum/job/chief_medical_officer = /obj/item/organ/internal/cyberimp/brain/linked_surgery/perfect/nt,
		/datum/job/clown = /obj/item/organ/internal/cyberimp/chest/knockout,
		/datum/job/cook = /obj/item/organ/internal/cyberimp/arm/item_set/cook,
		/datum/job/curator = /obj/item/organ/internal/eyes/robotic/glow,
		/datum/job/detective = /obj/item/organ/internal/cyberimp/arm/item_set/detective,
		/datum/job/explorer = /obj/item/organ/internal/eyes/robotic/meson,
		/datum/job/godzilla = /obj/item/organ/internal/cyberimp/brain/anti_stun,
		/datum/job/doctor = /obj/item/organ/internal/cyberimp/arm/item_set/surgery,
		/datum/job/geneticist = /obj/item/organ/internal/fly,
		/datum/job/gorilla = /obj/item/organ/internal/cyberimp/arm/strongarm,
		/datum/job/head_of_personnel = /obj/item/organ/internal/cyberimp/eyes/hud/security,
		/datum/job/head_of_security = /obj/item/organ/internal/cyberimp/arm/item_set/combat,
		/datum/job/janitor = /obj/item/organ/internal/cyberimp/arm/item_set/janitor,
		/datum/job/lawyer = /obj/item/organ/internal/heart/cybernetic/tier2,
		/datum/job/mime = /obj/item/organ/internal/tongue/robot,
		/datum/job/nanotrasen_representative = list(/obj/item/organ/internal/cyberimp/leg/shove_resist, /obj/item/organ/internal/cyberimp/leg/shove_resist/l),
		/datum/job/paramedic = /obj/item/organ/internal/cyberimp/arm/item_set/paramedic,
		/datum/job/prisoner = /obj/item/organ/internal/eyes/robotic/shield,
		/datum/job/psychologist = /obj/item/organ/internal/ears/cybernetic/whisper,
		/datum/job/quartermaster = /obj/item/organ/internal/stomach/cybernetic/tier3,
		/datum/job/research_director = /obj/item/organ/internal/cyberimp/bci,
		/datum/job/roboticist = /obj/item/organ/internal/cyberimp/eyes/hud/diagnostic,
		/datum/job/scientist = /obj/item/organ/internal/cyberimp/eyes/fakehud/science,
		/datum/job/security_assistant = list(/obj/item/organ/internal/cyberimp/leg/accelerator, /obj/item/organ/internal/cyberimp/leg/accelerator/l),
		/datum/job/security_officer = /obj/item/organ/internal/cyberimp/arm/item_set/flash,
		/datum/job/shaft_miner = /obj/item/organ/internal/cyberimp/arm/item_set/mining_drill/diamond,
		/datum/job/signal_technician = /obj/item/organ/internal/cyberimp/arm/heater,
		/datum/job/station_engineer = /obj/item/organ/internal/cyberimp/arm/item_set/toolset,
		/datum/job/virologist = /obj/item/organ/internal/cyberimp/eyes/hud/pathology,
		/datum/job/warden = /obj/item/organ/internal/cyberimp/eyes/hud/security,
		/datum/job/yellowclown = /obj/item/organ/internal/cyberimp/chest/knockout,
	)

/datum/station_trait/cybernetic_revolution/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/cybernetic_revolution/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER
	if(/datum/quirk/body_purist::name in player_client.prefs?.all_quirks)
		return
	var/list/cybernetics_to_give = job_to_cybernetic[job.type]
	if(!cybernetics_to_give)
		if(isAI(spawned))
			var/mob/living/silicon/ai/ai = spawned
			ai.eyeobj.relay_speech = TRUE //surveillance upgrade. the ai gets cybernetics too.
		return
	if(!islist(cybernetics_to_give))
		cybernetics_to_give = list(cybernetics_to_give)
	for(var/cybernetic_type in cybernetics_to_give)
		var/obj/item/organ/internal/cybernetic = new cybernetic_type
		cybernetic.Insert(spawned, special = TRUE, drop_if_replaced = FALSE)


/datum/station_trait/luxury_escape_pods
	name = "Luxury Escape Pods"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Due to good performance, we've provided your station with luxury escape pods."
	trait_to_give = STATION_TRAIT_BIGGER_PODS
	blacklist = list(/datum/station_trait/cramped_escape_pods)

/datum/station_trait/medbot_mania
	name = "Advanced Medbots"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Your station's medibots have recieved a hardware upgrade, enabling expanded healing capabilities."
	trait_to_give = STATION_TRAIT_MEDBOT_MANIA

/datum/station_trait/random_event_weight_modifier/shuttle_loans
	name = "Loaner Shuttle"
	report_message = "Due to an uptick in pirate attacks around your sector, there are few supply vessels in nearby space willing to assist with special requests. Expect to recieve more shuttle loan opportunities, with slightly higher payouts."
	trait_type = STATION_TRAIT_POSITIVE
	weight = 4
	event_control_path = /datum/round_event_control/shuttle_loan
	weight_multiplier = 2.5
	max_occurrences_modifier = 5 //All but one loan event will occur over the course of a round.
	trait_to_give = STATION_TRAIT_LOANER_SHUTTLE

/datum/station_trait/random_event_weight_modifier/wise_cows
	name = "Wise Cow Invasion"
	report_message = "Bluespace harmonic readings show unusual interpolative signals between your sector and agricultural sector MMF-D-02. Expect an increase in cow encounters. Encownters, if you will."
	trait_type = STATION_TRAIT_POSITIVE
	weight = 1
	event_control_path = /datum/round_event_control/wisdomcow
	weight_multiplier = 3
	max_occurrences_modifier = 10 //lotta cows

/datum/station_trait/shuttle_sale
	name = "Shuttle Firesale"
	report_message = "The Nanotrasen Emergency Dispatch team is celebrating a record number of shuttle calls in the recent quarter. Some of your emergency shuttle options have been discounted!"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 4
	trait_to_give = STATION_TRAIT_SHUTTLE_SALE
	show_in_report = TRUE

/datum/station_trait/missing_wallet
	name = "Misplaced Wallet"
	report_message = "A repair technician left their wallet in a locker somewhere. They would greatly appreciate if you could locate and return it to them when the shift has ended."
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE

/datum/station_trait/missing_wallet/on_round_start()
	. = ..()

	var/obj/structure/closet/locker_to_fill = pick(GLOB.roundstart_station_closets)

	var/obj/item/storage/wallet/new_wallet = new(locker_to_fill)

	new /obj/item/stack/spacecash/c500(new_wallet)
	if(prob(25)) //Jackpot!
		new /obj/item/stack/spacecash/c1000(new_wallet)

	new /obj/item/card/id/advanced/technician_id(new_wallet)
	new_wallet.refreshID()

	if(prob(35))
		report_message += " The technician reports they last remember having their wallet around [get_area_name(new_wallet)]."

	message_admins("A missing wallet has been placed in the [locker_to_fill] locker, in the [get_area_name(locker_to_fill)] area.")

/obj/item/card/id/advanced/technician_id
	name = "Repair Technician ID"
	desc = "Repair Technician? We don't have those in this sector, just a bunch of lazy engineers! This must have been from the between-shift crew..."
	registered_name = "Pluoxium LXVII"
	registered_age = 67
	trim = /datum/id_trim/technician_id

/datum/id_trim/technician_id
	access = list(ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MAINT_TUNNELS)
	assignment = "Repair Technician"
	trim_state = "trim_stationengineer"
	department_color = COLOR_ASSISTANT_GRAY

#undef PARTY_COOLDOWN_LENGTH_MIN
#undef PARTY_COOLDOWN_LENGTH_MAX
