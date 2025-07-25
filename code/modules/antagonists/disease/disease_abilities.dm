/*
Abilities that can be purchased by disease mobs. Most are just passive symptoms that will be
added to their disease, but some are active abilites that affect only the target the overmind
is currently following.
*/

GLOBAL_LIST_INIT(disease_ability_singletons, list(
new /datum/disease_ability/action/cough,
new /datum/disease_ability/action/sneeze,
new /datum/disease_ability/action/infect,
new /datum/disease_ability/symptom/mild/cough,
new /datum/disease_ability/symptom/mild/sneeze,
new /datum/disease_ability/symptom/medium/beard,
new /datum/disease_ability/symptom/medium/choking,
new /datum/disease_ability/symptom/medium/confusion,
/* new /datum/disease_ability/symptom/medium/voice_change,*/
new /datum/disease_ability/symptom/powerful/narcolepsy,
/* new /datum/disease_ability/symptom/medium/fever, */
new /datum/disease_ability/symptom/medium/headache,
/* new /datum/disease_ability/symptom/medium/nano_boost,
new /datum/disease_ability/symptom/medium/nano_destroy, */
new /datum/disease_ability/symptom/medium/disfiguration,
new /datum/disease_ability/symptom/medium/polyvitiligo,
new /datum/disease_ability/symptom/medium/itching,
new /datum/disease_ability/symptom/powerful/fire,
new /datum/disease_ability/symptom/powerful/flesh_eating,
new /datum/disease_ability/symptom/powerful/heal/oxygen,
))
/datum/disease_ability
	var/name
	var/cost = 0
	var/required_total_points = 0
	var/start_with = FALSE
	var/short_desc = ""
	var/long_desc = ""
	var/stat_block = ""
	var/threshold_block = list()
	var/category = ""

	var/list/symptoms
	var/list/actions

/datum/disease_ability/New()
	..()
	if(symptoms)
		var/stealth = 0
		var/resistance = 0
		var/stage_speed = 0
		var/transmittable = 0
		for(var/T in symptoms)
			var/datum/symptom/S = T
			stealth += initial(S.stealth)
			resistance += initial(S.resistance)
			stage_speed += initial(S.stage_speed)
			transmittable += initial(S.transmittable)
			threshold_block += initial(S.threshold_descs)
			stat_block = "Resistance: [resistance]<br>Stealth: [stealth]<br>Stage Speed: [stage_speed]<br>Transmissibility: [transmittable]<br><br>"
			if(symptoms.len == 1) //lazy boy's dream
				name = initial(S.name)
				if(short_desc == "")
					short_desc = initial(S.desc)
				if(long_desc == "")
					long_desc = initial(S.desc)

/datum/disease_ability/proc/CanBuy(mob/camera/disease/D)
	if(world.time < D.next_adaptation_time)
		return FALSE
	if(!D.unpurchased_abilities[src])
		return FALSE
	return (D.points >= cost) && (D.total_points >= required_total_points)

/datum/disease_ability/proc/Buy(mob/camera/disease/D, silent = FALSE, trigger_cooldown = TRUE)
	if(!silent)
		to_chat(D, span_notice("Purchased [name]."))
	D.points -= cost
	D.unpurchased_abilities -= src
	if(trigger_cooldown)
		D.adapt_cooldown()
	D.purchased_abilities[src] = TRUE
	for(var/V in (D.disease_instances+D.disease_template))
		var/datum/disease/advance/sentient_disease/SD = V
		if(symptoms)
			for(var/T in symptoms)
				var/datum/symptom/S = new T()
				SD.symptoms += S
				S.OnAdd(SD)
				if(SD.processing)
					if(S.Start(SD))
						S.next_activation = world.time + rand(S.symptom_delay_min * 10, S.symptom_delay_max * 10)
			SD.Refresh()
	for(var/T in actions)
		var/datum/action/A = new T()
		A.Grant(D)


/datum/disease_ability/proc/CanRefund(mob/camera/disease/D)
	if(world.time < D.next_adaptation_time)
		return FALSE
	return D.purchased_abilities[src]

/datum/disease_ability/proc/Refund(mob/camera/disease/D, silent = FALSE, trigger_cooldown = TRUE)
	if(!silent)
		to_chat(D, span_notice("Refunded [name]."))
	D.points += cost
	D.unpurchased_abilities[src] = TRUE
	if(trigger_cooldown)
		D.adapt_cooldown()
	D.purchased_abilities -= src
	for(var/V in (D.disease_instances+D.disease_template))
		var/datum/disease/advance/sentient_disease/SD = V
		if(symptoms)
			for(var/T in symptoms)
				var/datum/symptom/S = locate(T) in SD.symptoms
				if(S)
					SD.symptoms -= S
					S.OnRemove(SD)
					if(SD.processing)
						S.End(SD)
					qdel(S)
			SD.Refresh()
	for(var/T in actions)
		var/datum/action/A = locate(T) in D.actions
		qdel(A)

//these sybtypes are for conveniently separating the different categories, they have no unique code.

/datum/disease_ability/action
	category = "Active"

/datum/disease_ability/symptom
	category = "Symptom"

//active abilities and their associated actions

/datum/disease_ability/action/cough
	name = "Voluntary Coughing"
	actions = list(/datum/action/cooldown/disease_cough)
	cost = 0
	required_total_points = 0
	start_with = TRUE
	short_desc = "Force the host you are following to cough, spreading your infection to those nearby."
	long_desc = "Force the host you are following to cough with extra force, spreading your infection to those within two meters of your host even if your transmissibility is low.<br>Cooldown: 10 seconds"


/datum/action/cooldown/disease_cough
	name = "Cough"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "cough"
	desc = "Force the host you are following to cough with extra force, spreading your infection to those within two meters of your host even if your transmissibility is low.<br>Cooldown: 10 seconds"
	cooldown_time = 100

/datum/action/cooldown/disease_cough/Activate(atom/target)
	StartCooldown(10 SECONDS)
	trigger_cough()
	StartCooldown()
	return TRUE

/*
 * Cause a cough to happen from the host.
 */
/datum/action/cooldown/disease_cough/proc/trigger_cough()
	var/mob/camera/disease/our_disease = owner
	var/mob/living/host = our_disease.following_host
	if(!host)
		return FALSE
	if(host.stat != CONSCIOUS)
		to_chat(our_disease, span_warning("Your host must be conscious to cough."))
		return FALSE
	to_chat(our_disease, span_notice("You force [host.real_name] to cough."))
	host.emote("cough")
	if(host.CanSpreadAirborneDisease()) //don't spread germs if they covered their mouth
		var/datum/disease/advance/sentient_disease/disease_datum = our_disease.hosts[host]
		disease_datum.spread(2)
	return TRUE

/datum/disease_ability/action/sneeze
	name = "Voluntary Sneezing"
	actions = list(/datum/action/cooldown/disease_sneeze)
	cost = 2
	required_total_points = 3
	short_desc = "Force the host you are following to sneeze, spreading your infection to those in front of them."
	long_desc = "Force the host you are following to sneeze with extra force, spreading your infection to any victims in a 4 meter cone in front of your host.<br>Cooldown: 20 seconds"

/datum/action/cooldown/disease_sneeze
	name = "Sneeze"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "sneeze"
	desc = "Force the host you are following to sneeze with extra force, spreading your infection to any victims in a 4 meter cone in front of your host even if your transmissibility is low.<br>Cooldown: 20 seconds"
	cooldown_time = 200

/datum/action/cooldown/disease_sneeze/Activate(atom/target)
	StartCooldown(10 SECONDS)
	trigger_sneeze()
	StartCooldown()
	return TRUE

/*
 * Cause a sneeze to happen from the host.
 */
/datum/action/cooldown/disease_sneeze/proc/trigger_sneeze()
	var/mob/camera/disease/our_disease = owner
	var/mob/living/host = our_disease.following_host
	if(!host)
		return FALSE
	if(host.stat != CONSCIOUS)
		to_chat(our_disease, span_warning("Your host must be conscious to sneeze."))
		return FALSE
	to_chat(our_disease, span_notice("You force [host.real_name] to sneeze."))
	host.emote("sneeze")
	if(host.CanSpreadAirborneDisease()) //don't spread germs if they covered their mouth
		var/datum/disease/advance/sentient_disease/disease_datum = our_disease.hosts[host]
		for(var/mob/living/nearby_mob in oview(4, disease_datum.affected_mob))
			if(!is_source_facing_target(disease_datum.affected_mob, nearby_mob))
				continue
			if(!disease_air_spread_walk(get_turf(disease_datum.affected_mob), get_turf(nearby_mob)))
				continue
			nearby_mob.AirborneContractDisease(disease_datum, TRUE)

	return TRUE

/datum/disease_ability/action/infect
	name = "Secrete Infection"
	actions = list(/datum/action/cooldown/disease_infect)
	cost = 2
	required_total_points = 3
	short_desc = "Cause all objects your host is touching to become infectious for a limited time, spreading your infection to anyone who touches them."
	long_desc = "Cause the host you are following to excrete an infective substance from their pores, causing all objects touching their skin to transmit your infection to anyone who touches them for the next 30 seconds. This includes the floor, if they are not wearing shoes, and any items they are holding, if they are not wearing gloves.<br>Cooldown: 40 seconds"

/datum/action/cooldown/disease_infect
	name = "Secrete Infection"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "infect"
	desc = "Cause the host you are following to excrete an infective substance from their pores, causing all objects touching their skin to transmit your infection to anyone who touches them for the next 30 seconds.<br>Cooldown: 40 seconds"
	cooldown_time = 400

/datum/action/cooldown/disease_infect/Activate(atom/target)
	StartCooldown(10 SECONDS)
	trigger_infection()
	StartCooldown()
	return TRUE

/*
 * Trigger the infection action.
 */
/datum/action/cooldown/disease_infect/proc/trigger_infection()
	var/mob/camera/disease/our_disease = owner
	var/mob/living/carbon/human/host = our_disease.following_host
	if(!host)
		return FALSE
	for(var/obj/thing as anything in host.get_equipped_items(include_accessories = TRUE))
		thing.AddComponent(/datum/component/infective, our_disease.disease_template, 300)
	//no shoes? infect the floor.
	if(!host.shoes)
		var/turf/host_turf = get_turf(host)
		if(host_turf && !isspaceturf(host_turf))
			host_turf.AddComponent(/datum/component/infective, our_disease.disease_template, 300)
	//no gloves? infect whatever we are holding.
	if(!host.gloves)
		for(var/obj/held_thing as anything in host.held_items)
			if(isnull(held_thing))
				continue
			held_thing.AddComponent(/datum/component/infective, our_disease.disease_template, 300)
	return TRUE

/*******************BASE SYMPTOM TYPES*******************/
// cost is for convenience and can be changed. If you're changing req_tot_points then don't use the subtype...
//healing costs more so you have to techswitch from naughty disease otherwise we'd have friendly disease for easy greentext (no fun!)

/datum/disease_ability/symptom/mild
	cost = 2
	required_total_points = 4
	category = "Symptom (Weak)"

/datum/disease_ability/symptom/medium
	cost = 4
	required_total_points = 8
	category = "Symptom"

/datum/disease_ability/symptom/medium/heal
	cost = 5
	category = "Symptom (+)"

/datum/disease_ability/symptom/powerful
	cost = 4
	required_total_points = 16
	category = "Symptom (Strong)"

/datum/disease_ability/symptom/powerful/heal
	cost = 8
	category = "Symptom (Strong+)"

/******MILD******/

/datum/disease_ability/symptom/mild/cough
	name = "Involuntary Coughing"
	symptoms = list(/datum/symptom/cough)
	short_desc = "Cause victims to cough intermittently."
	long_desc = "Cause victims to cough intermittently, spreading your infection."

/datum/disease_ability/symptom/mild/sneeze
	name = "Involuntary Sneezing"
	symptoms = list(/datum/symptom/sneeze)
	short_desc = "Cause victims to sneeze intermittently."
	long_desc = "Cause victims to sneeze intermittently, spreading your infection and also increasing transmissibility and resistance, at the cost of stealth."

/******MEDIUM******/


/datum/disease_ability/symptom/medium/beard
	symptoms = list(/datum/symptom/beard)
	short_desc = "Cause all victims to grow a luscious beard."
	long_desc = "Cause all victims to grow a luscious beard. Ineffective against Santa Claus."

/datum/disease_ability/symptom/medium/choking
	symptoms = list(/datum/symptom/choking)
	short_desc = "Cause victims to choke."
	long_desc = "Cause victims to choke, threatening asphyxiation. Decreases stats, especially transmissibility."

/datum/disease_ability/symptom/medium/confusion
	symptoms = list(/datum/symptom/confusion)
	short_desc = "Cause victims to become confused."
	long_desc = "Cause victims to become confused intermittently."

/* While they are nonfunctional. Keep em codeblocked.
/datum/disease_ability/symptom/medium/voice_change
	symptoms = list(/datum/symptom/voice_change)
	short_desc = "Change the voice of victims."
	long_desc = "Change the voice of victims, causing confusion in communications."

/datum/disease_ability/symptom/medium/fever
	symptoms = list(/datum/symptom/fever)
*/

/datum/disease_ability/symptom/medium/headache
	symptoms = list(/datum/symptom/headache)

/datum/disease_ability/symptom/medium/polyvitiligo
	symptoms = list(/datum/symptom/polyvitiligo)

/datum/disease_ability/symptom/medium/disfiguration
	symptoms = list(/datum/symptom/disfiguration)

/datum/disease_ability/symptom/medium/itching
	symptoms = list(/datum/symptom/itching)
	short_desc = "Cause victims to itch."
	long_desc = "Cause victims to itch, increasing all stats except stealth."

/******POWERFUL******/

/datum/disease_ability/symptom/powerful/fire
	symptoms = list(/datum/symptom/fire)

/datum/disease_ability/symptom/powerful/flesh_eating
	symptoms = list(/datum/symptom/flesh_eating)


/datum/disease_ability/symptom/powerful/narcolepsy
	symptoms = list(/datum/symptom/narcolepsy)

/****HEALING SUBTYPE****/


/datum/disease_ability/symptom/powerful/heal/oxygen
	symptoms = list(/datum/symptom/oxygen)

/* While they are nonfunctional. Keep em codeblocked.
/datum/disease_ability/symptom/medium/nano_boost
	symptoms = list(/datum/symptom/nano_boost)

/datum/disease_ability/symptom/medium/nano_destroy
	symptoms = list(/datum/symptom/nano_destroy)
*/
