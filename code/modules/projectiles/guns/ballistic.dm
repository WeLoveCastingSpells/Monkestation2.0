///Subtype for any kind of ballistic gun
///This has a shitload of vars on it, and I'm sorry for that, but it does make making new subtypes really easy
/obj/item/gun/ballistic
	desc = "Now comes in flavors like GUN. Uses 10mm ammo, for some reason."
	name = "projectile gun"
	icon_state = "debug"
	w_class = WEIGHT_CLASS_NORMAL

	///sound when inserting magazine
	var/load_sound = 'sound/weapons/gun/general/magazine_insert_full.ogg'
	///sound when inserting an empty magazine
	var/load_empty_sound = 'sound/weapons/gun/general/magazine_insert_empty.ogg'
	///volume of loading sound
	var/load_sound_volume = 40
	///whether loading sound should vary
	var/load_sound_vary = TRUE
	///sound of racking
	var/rack_sound = 'sound/weapons/gun/general/bolt_rack.ogg'
	///volume of racking
	var/rack_sound_volume = 60
	///whether racking sound should vary
	var/rack_sound_vary = TRUE
	///sound of when the bolt is locked back manually
	var/lock_back_sound = 'sound/weapons/gun/general/slide_lock_1.ogg'
	///volume of lock back
	var/lock_back_sound_volume = 60
	///whether lock back varies
	var/lock_back_sound_vary = TRUE
	///Sound of ejecting a magazine
	var/eject_sound = 'sound/weapons/gun/general/magazine_remove_full.ogg'
	///sound of ejecting an empty magazine
	var/eject_empty_sound = 'sound/weapons/gun/general/magazine_remove_empty.ogg'
	///volume of ejecting a magazine
	var/eject_sound_volume = 40
	///whether eject sound should vary
	var/eject_sound_vary = TRUE
	///sound of dropping the bolt or releasing a slide
	var/bolt_drop_sound = 'sound/weapons/gun/general/bolt_drop.ogg'
	///volume of bolt drop/slide release
	var/bolt_drop_sound_volume = 60
	///empty alarm sound (if enabled)
	var/empty_alarm_sound = 'sound/weapons/gun/general/empty_alarm.ogg'
	///empty alarm volume sound
	var/empty_alarm_volume = 70
	///whether empty alarm sound varies
	var/empty_alarm_vary = TRUE

	///Whether the gun will spawn loaded with a magazine
	var/spawnwithmagazine = TRUE
	/// What type (includes subtypes) of magazine will this gun accept being put into it
	var/obj/item/ammo_box/magazine/accepted_magazine_type = /obj/item/ammo_box/magazine/m10mm
	/// Change this if the gun should spawn with a different magazine type to what accepted_magazine_type defines. Will create errors if not a type or subtype of accepted magazine.
	var/obj/item/ammo_box/magazine/spawn_magazine_type
	///Whether the sprite has a visible magazine or not
	var/mag_display = TRUE
	///Whether the sprite has a visible ammo display or not
	var/mag_display_ammo = FALSE
	///Whether the sprite has a visible indicator for being empty or not.
	var/empty_indicator = FALSE
	///Whether the gun alarms when empty or not.
	var/empty_alarm = FALSE
	///Whether the gun supports multiple special mag types
	var/special_mags = FALSE
	/**
	* The bolt type controls how the gun functions, and what iconstates you'll need to represent those functions.
	* BOLT_TYPE_STANDARD - The Slide doesn't lock back.  Clicking on it will only cycle the bolt.  Only 1 sprite.
	* BOLT_TYPE_OPEN - Same as standard, but it fires directly from the magazine - No need to rack.  Doesn't hold the bullet when you drop the mag.
	* BOLT_TYPE_LOCKING - This is most handguns and bolt action rifles.  The bolt will lock back when it's empty.  You need yourgun_bolt and yourgun_bolt_locked icon states.
	* BOLT_TYPE_NO_BOLT - This is shotguns and revolvers.  clicking will dump out all the bullets in the gun, spent or not.
	* see combat.dm defines for bolt types: BOLT_TYPE_STANDARD; BOLT_TYPE_LOCKING; BOLT_TYPE_OPEN; BOLT_TYPE_NO_BOLT
	**/
	var/bolt_type = BOLT_TYPE_STANDARD
	///Used for locking bolt and open bolt guns. Set a bit differently for the two but prevents firing when true for both.
	var/bolt_locked = FALSE
	var/show_bolt_icon = TRUE ///Hides the bolt icon.
	///Whether the gun has to be racked each shot or not.
	var/semi_auto = TRUE
	///Actual magazine currently contained within the gun
	var/obj/item/ammo_box/magazine/magazine
	///whether the gun ejects the chambered casing
	var/casing_ejector = TRUE
	///Whether the gun has an internal magazine or a detatchable one. Overridden by BOLT_TYPE_NO_BOLT.
	var/internal_magazine = FALSE
	///Phrasing of the bolt in examine and notification messages; ex: bolt, slide, etc.
	var/bolt_wording = "bolt"
	///Phrasing of the magazine in examine and notification messages; ex: magazine, box, etx
	var/magazine_wording = "magazine"
	///Phrasing of the cartridge in examine and notification messages; ex: bullet, shell, dart, etc.
	var/cartridge_wording = "bullet"
	///length between individual racks
	var/rack_delay = 5
	///time of the most recent rack, used for cooldown purposes
	var/recent_rack = 0
	///Whether the gun can be tacloaded by slapping a fresh magazine directly on it
	var/tac_reloads = TRUE //Snowflake mechanic no more.
	///Whether the gun can be sawn off by sawing tools
	var/can_be_sawn_off = FALSE
	var/flip_cooldown = 0
	var/suppressor_x_offset ///pixel offset for the suppressor overlay on the x axis.
	var/suppressor_y_offset ///pixel offset for the suppressor overlay on the y axis.
	/// Check if you are able to see if a weapon has a bullet loaded in or not.
	var/hidden_chambered = FALSE

	// Gun internal magazine modification and misfiring

	///Can we modify our ammo type in this gun's internal magazine?
	var/can_modify_ammo = FALSE
	///our initial ammo type. Should match initial caliber, but a bit of redundency doesn't hurt.
	var/initial_caliber
	///our alternative ammo type.
	var/alternative_caliber
	///our initial fire sound. same reasons for initial caliber
	var/initial_fire_sound
	///our alternative fire sound, in case we want our gun to be louder or quieter or whatever
	var/alternative_fire_sound
	///If only our alternative ammuntion misfires and not our main ammunition, we set this to TRUE
	var/alternative_ammo_misfires = FALSE

	/// Misfire Variables ///

	/// Whether our ammo misfires now or when it's set by the wrench_act. TRUE means it misfires.
	var/can_misfire = FALSE
	///How likely is our gun to misfire?
	var/misfire_probability = 0
	///How much does shooting the gun increment the misfire probability?
	var/misfire_percentage_increment = 0
	///What is the cap on our misfire probability? Do not set this to 100.
	var/misfire_probability_cap = 25

	var/wield_recoil = 0

/obj/item/gun/ballistic/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, wield_callback = CALLBACK(src, PROC_REF(on_wield)), unwield_callback = CALLBACK(src, PROC_REF(on_unwield)))
	if(!spawn_magazine_type)
		spawn_magazine_type = accepted_magazine_type
	if (!spawnwithmagazine)
		bolt_locked = TRUE
		update_appearance()
		return
	if (!magazine)
		magazine = new spawn_magazine_type(src)
	if(bolt_type == BOLT_TYPE_STANDARD || internal_magazine) //Internal magazines shouldn't get magazine + 1.
		chamber_round()
	else
		chamber_round(replace_new_round = TRUE)
	update_appearance()
	RegisterSignal(src, COMSIG_ITEM_RECHARGED, PROC_REF(instant_reload))
	register_context()

/obj/item/gun/ballistic/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_CTRL_LMB] = "Toggle Bracing"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/gun/ballistic/Destroy()
	QDEL_NULL(magazine)
	return ..()

/obj/item/gun/ballistic/add_weapon_description()
	AddElement(/datum/element/weapon_description, attached_proc = PROC_REF(add_notes_ballistic))

/obj/item/gun/ballistic/fire_sounds()
	var/max_ammo = magazine?.max_ammo || initial(spawn_magazine_type.max_ammo)
	var/current_ammo = get_ammo()
	var/frequency_to_use = sin((90 / max_ammo) * current_ammo)
	var/click_frequency_to_use = 1 - frequency_to_use * 0.75
	var/play_click = round(sqrt(max_ammo * 2)) > current_ammo

	if(suppressed)
		playsound(src, suppressed_sound, suppressed_volume, vary_fire_sound, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
		if(play_click)
			playsound(src, 'sound/weapons/gun/general/ballistic_click.ogg', suppressed_volume, vary_fire_sound, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0, frequency = click_frequency_to_use)
	else
		playsound(src, fire_sound, fire_sound_volume, vary_fire_sound)
		if(play_click)
			playsound(src, 'sound/weapons/gun/general/ballistic_click.ogg', fire_sound_volume, vary_fire_sound, frequency = click_frequency_to_use)


/**
 *
 * Outputs type-specific weapon stats for ballistic weaponry based on its magazine and its caliber.
 * It contains extra breaks for the sake of presentation
 *
 **/
/obj/item/gun/ballistic/proc/add_notes_ballistic()
	if(magazine) // Make sure you have a magazine, to get the notes from
		return "\n[magazine.add_notes_box()]"
	else
		return "\nThe warning attached to the magazine is missing..."

/obj/item/gun/ballistic/vv_edit_var(vname, vval)
	. = ..()
	if(vname in list(NAMEOF(src, suppressor_x_offset), NAMEOF(src, suppressor_y_offset), NAMEOF(src, internal_magazine), NAMEOF(src, magazine), NAMEOF(src, chambered), NAMEOF(src, empty_indicator), NAMEOF(src, sawn_off), NAMEOF(src, bolt_locked), NAMEOF(src, bolt_type)))
		update_appearance()

/obj/item/gun/ballistic/update_icon_state()
	if(current_skin)
		icon_state = "[unique_reskin[current_skin]][sawn_off ? "_sawn" : ""]"
	else
		icon_state = "[base_icon_state || initial(icon_state)][sawn_off ? "_sawn" : ""]"
	return ..()

/obj/item/gun/ballistic/update_overlays()
	. = ..()
	if(show_bolt_icon)
		if (bolt_type == BOLT_TYPE_LOCKING)
			. += "[icon_state]_bolt[bolt_locked ? "_locked" : ""]"
		if (bolt_type == BOLT_TYPE_OPEN && bolt_locked)
			. += "[icon_state]_bolt"

	if(suppressed)
		var/mutable_appearance/MA = mutable_appearance(icon, "[icon_state]_suppressor")
		if(suppressor_x_offset)
			MA.pixel_x = suppressor_x_offset
		if(suppressor_y_offset)
			MA.pixel_y = suppressor_y_offset
		. += MA

	if(!chambered && empty_indicator) //this is duplicated in c20's update_overlayss due to a layering issue with the select fire icon.
		. += "[icon_state]_empty"

	if(gun_flags & TOY_FIREARM_OVERLAY)
		. += "[icon_state]_toy"


	if(!magazine || internal_magazine || !mag_display)
		return

	if(special_mags)
		. += "[icon_state]_mag_[initial(magazine.icon_state)]"
		if(mag_display_ammo && !magazine.ammo_count())
			. += "[icon_state]_mag_empty"
		return

	. += "[icon_state]_mag"
	if(!mag_display_ammo)
		return

	var/capacity_number
	switch(get_ammo() / magazine.max_ammo)
		if(1 to INFINITY) //cause we can have one in the chamber.
			capacity_number = 100
		if(0.8 to 1)
			capacity_number = 80
		if(0.6 to 0.8)
			capacity_number = 60
		if(0.4 to 0.6)
			capacity_number = 40
		if(0.2 to 0.4)
			capacity_number = 20
	if(capacity_number)
		. += "[icon_state]_mag_[capacity_number]"


/obj/item/gun/ballistic/handle_chamber(mob/living/user, empty_chamber = TRUE, from_firing = TRUE, chamber_next_round = TRUE)
	if(!semi_auto && from_firing)
		return
	var/obj/item/ammo_casing/casing = chambered //Find chambered round
	if(istype(casing)) //there's a chambered round
		if(QDELING(casing))
			stack_trace("Trying to move a qdeleted casing of type [casing.type]!")
			chambered = null
		else if(casing_ejector || !from_firing)
			chambered = null
			casing.forceMove(drop_location()) //Eject casing onto ground.
			if(!QDELETED(casing))
				var/bounce_angle
				if(user)
					var/sign_x = (istype(user) && !(user.get_held_index_of_item(src) % RIGHT_HANDS)) ? 1 : -1
					bounce_angle = SIMPLIFY_DEGREES(dir2angle(user.dir) + (sign_x * 90) + rand(-45, 45))
				casing.bounce_away(bounce_angle = bounce_angle, still_warm = TRUE)
				SEND_SIGNAL(casing, COMSIG_CASING_EJECTED)
		else if(empty_chamber)
			chambered = null
	if (chamber_next_round && (magazine?.max_ammo > 1))
		chamber_round()

///Used to chamber a new round and eject the old one
/obj/item/gun/ballistic/proc/chamber_round(keep_bullet = FALSE, spin_cylinder, replace_new_round)
	if (chambered || !magazine)
		return
	if (magazine.ammo_count())
		chambered = magazine.get_round(keep_bullet || bolt_type == BOLT_TYPE_NO_BOLT)
		if (bolt_type != BOLT_TYPE_OPEN)
			chambered.forceMove(src)
		if(replace_new_round)
			magazine.give_round(new chambered.type)

///updates a bunch of racking related stuff and also handles the sound effects and the like
/obj/item/gun/ballistic/proc/rack(mob/user = null)
	if (bolt_type == BOLT_TYPE_NO_BOLT) //If there's no bolt, nothing to rack
		return
	if (bolt_type == BOLT_TYPE_OPEN)
		if(!bolt_locked) //If it's an open bolt, racking again would do nothing
			if (user)
				balloon_alert(user, "[bolt_wording] already cocked!")
			return
		bolt_locked = FALSE
	if (user)
		balloon_alert(user, "[bolt_wording] racked")
	process_chamber(user = user, empty_chamber = !chambered, from_firing = FALSE)
	if (bolt_type == BOLT_TYPE_LOCKING && !chambered)
		bolt_locked = TRUE
		playsound(src, lock_back_sound, lock_back_sound_volume, lock_back_sound_vary)
	else
		playsound(src, rack_sound, rack_sound_volume, rack_sound_vary)
	SEND_SIGNAL(src, COMSIG_GUN_RACKED, user)
	update_appearance()

///Drops the bolt from a locked position
/obj/item/gun/ballistic/proc/drop_bolt(mob/user = null)
	playsound(src, bolt_drop_sound, bolt_drop_sound_volume, FALSE)
	if (user)
		balloon_alert(user, "[bolt_wording] dropped")
	chamber_round()
	bolt_locked = FALSE
	update_appearance()

///Handles all the logic needed for magazine insertion
/obj/item/gun/ballistic/proc/insert_magazine(mob/user, obj/item/ammo_box/magazine/AM, display_message = TRUE)
	if(!istype(AM, accepted_magazine_type))
		balloon_alert(user, "[AM.name] doesn't fit!")
		return FALSE
	if(user.transferItemToLoc(AM, src))
		magazine = AM
		if (display_message)
			balloon_alert(user, "[magazine_wording] loaded")
		playsound(src, load_empty_sound, load_sound_volume, load_sound_vary)
		if (bolt_type == BOLT_TYPE_OPEN && !bolt_locked)
			chamber_round(TRUE)
		update_appearance()
		return TRUE
	else
		to_chat(user, span_warning("You cannot seem to get [src] out of your hands!"))
		return FALSE

///Handles all the logic of magazine ejection, if tac_load is set that magazine will be tacloaded in the place of the old eject
/obj/item/gun/ballistic/proc/eject_magazine(mob/user, display_message = TRUE, obj/item/ammo_box/magazine/tac_load = null)
	if(bolt_type == BOLT_TYPE_OPEN)
		chambered = null
	if (magazine.ammo_count())
		playsound(src, load_sound, load_sound_volume, load_sound_vary)
	else
		playsound(src, load_empty_sound, load_sound_volume, load_sound_vary)
	magazine.forceMove(drop_location())
	var/obj/item/ammo_box/magazine/old_mag = magazine
	if (tac_load)
		if (insert_magazine(user, tac_load, FALSE))
			balloon_alert(user, "[magazine_wording] swapped")
		else
			to_chat(user, span_warning("You dropped the old [magazine_wording], but the new one doesn't fit. How embarassing."))
			magazine = null
	else
		magazine = null
	user.put_in_hands(old_mag)
	old_mag.update_appearance()
	if (display_message)
		balloon_alert(user, "[magazine_wording] unloaded")
	update_appearance()

/obj/item/gun/ballistic/can_shoot()
	return chambered?.loaded_projectile

/obj/item/gun/ballistic/attackby(obj/item/A, mob/user, params)
	. = ..()
	if (.)
		return
	if (!internal_magazine && istype(A, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = A
		if (!magazine)
			insert_magazine(user, AM)
		else
			if (tac_reloads)
				eject_magazine(user, FALSE, AM)
			else
				balloon_alert(user, "already loaded!")
		return
	if (isammocasing(A) || istype(A, /obj/item/ammo_box))
		if (bolt_type == BOLT_TYPE_NO_BOLT || internal_magazine)
			if (chambered && !chambered.loaded_projectile)
				chambered.forceMove(drop_location())
				chambered = null
			var/num_loaded = magazine?.attackby(A, user, params, TRUE)
			if (num_loaded)
				balloon_alert(user, "[num_loaded] [cartridge_wording]\s loaded")
				playsound(src, load_sound, load_sound_volume, load_sound_vary)
				if (chambered == null && bolt_type == BOLT_TYPE_NO_BOLT)
					chamber_round()
				A.update_appearance()
				update_appearance()
			return
	if(istype(A, /obj/item/suppressor))
		var/obj/item/suppressor/S = A
		if(!can_suppress)
			balloon_alert(user, "[S.name] doesn't fit!")
			return
		if(!user.is_holding(src))
			balloon_alert(user, "not in hand!")
			return
		if(suppressed)
			balloon_alert(user, "already has a supressor!")
			return
		if(user.transferItemToLoc(A, src))
			balloon_alert(user, "[S.name] attached")
			install_suppressor(A)
			return
	if (can_be_sawn_off)
		if (sawoff(user, A))
			return

	if(can_misfire && istype(A, /obj/item/stack/sheet/cloth))
		if(guncleaning(user, A))
			return

	return FALSE

/obj/item/gun/ballistic/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(can_misfire && magazine && chambered?.loaded_projectile && misfire_probability > 0)  //monke edit : moved can_misfire from the third spot to the first to cancel some runtime issues
		if(prob(misfire_probability))
			if(blow_up(user))
				to_chat(user, span_userdanger("[src] misfires!"))

	if (sawn_off)
		bonus_spread += SAWN_OFF_ACC_PENALTY
	return ..()

/obj/item/gun/ballistic/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
	if(can_misfire)
		misfire_probability += misfire_percentage_increment
		misfire_probability = clamp(misfire_probability, 0, misfire_probability_cap)
	return ..()

///Installs a new suppressor, assumes that the suppressor is already in the contents of src
/obj/item/gun/ballistic/proc/install_suppressor(obj/item/suppressor/S)
	suppressed = S
	w_class += S.w_class //so pistols do not fit in pockets when suppressed
	update_appearance()

/obj/item/gun/ballistic/clear_suppressor()
	if(!can_unsuppress)
		return
	if(isitem(suppressed))
		var/obj/item/I = suppressed
		w_class -= I.w_class
	return ..()

/obj/item/gun/ballistic/AltClick(mob/user)
	if (unique_reskin && !current_skin && user.can_perform_action(src, NEED_DEXTERITY))
		reskin_obj(user)
		return
	if(loc == user)
		if(suppressed && can_unsuppress)
			var/obj/item/suppressor/S = suppressed
			if(!user.is_holding(src))
				return ..()
			balloon_alert(user, "[S.name] removed")
			user.put_in_hands(S)
			clear_suppressor()

///Prefire empty checks for the bolt drop
/obj/item/gun/ballistic/proc/prefire_empty_checks()
	if (!chambered && !get_ammo())
		if (bolt_type == BOLT_TYPE_OPEN && !bolt_locked)
			bolt_locked = TRUE
			playsound(src, bolt_drop_sound, bolt_drop_sound_volume)
			update_appearance()

///postfire empty checks for bolt locking and sound alarms
/obj/item/gun/ballistic/proc/postfire_empty_checks(last_shot_succeeded)
	if (!chambered && !get_ammo())
		if (empty_alarm && last_shot_succeeded)
			playsound(src, empty_alarm_sound, empty_alarm_volume, empty_alarm_vary)
			update_appearance()
		if (last_shot_succeeded && bolt_type == BOLT_TYPE_LOCKING)
			bolt_locked = TRUE
			update_appearance()

/obj/item/gun/ballistic/afterattack()
	prefire_empty_checks()
	. = ..() //The gun actually firing
	postfire_empty_checks(.)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/gun/ballistic/attack_hand(mob/user, list/modifiers)
	if(!internal_magazine && loc == user && user.is_holding(src) && magazine)
		eject_magazine(user)
		return
	return ..()

/obj/item/gun/ballistic/attack_self(mob/living/user)
	if(HAS_TRAIT(user, TRAIT_GUNFLIP))
		SpinAnimation(4,2)
		if(flip_cooldown <= world.time)
			if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(40))
				to_chat(user, span_userdanger("While trying to flip [src] you pull the trigger and accidentally shoot yourself!"))
				process_fire(user, user, FALSE, user.get_random_valid_zone(even_weights = TRUE))
				user.dropItemToGround(src, TRUE)
				return
			flip_cooldown = (world.time + 30)
			user.visible_message(span_notice("[user] spins [src] around [user.p_their()] finger by the trigger. That’s pretty badass."))
			playsound(src, 'sound/items/handling/ammobox_pickup.ogg', 20, FALSE)
			return
	if(!internal_magazine && magazine)
		if(!magazine.ammo_count())
			eject_magazine(user)
			return
	if(bolt_type == BOLT_TYPE_NO_BOLT)
		chambered = null
		var/num_unloaded = 0
		for(var/obj/item/ammo_casing/casing in get_ammo_list(FALSE, TRUE))
			casing.forceMove(drop_location())
			var/bounce_angle
			if(user)
				var/sign_x = (istype(user) && !(user.get_held_index_of_item(src) % RIGHT_HANDS)) ? 1 : -1
				bounce_angle = SIMPLIFY_DEGREES(dir2angle(user.dir) + (sign_x * 90) + rand(-45, 45))
			casing.bounce_away(bounce_angle = bounce_angle, still_warm = FALSE, sound_delay = 0)
			num_unloaded++
			var/turf/our_turf = get_turf(drop_location())
			if(our_turf && is_station_level(our_turf.z))
				SSblackbox.record_feedback("tally", "station_mess_created", 1, casing.name)
		if (num_unloaded)
			balloon_alert(user, "[num_unloaded] [cartridge_wording] unloaded")
			playsound(user, eject_sound, eject_sound_volume, eject_sound_vary)
			update_appearance()
		else
			balloon_alert(user, "it's empty!")
		return
	if(bolt_type == BOLT_TYPE_LOCKING && bolt_locked)
		drop_bolt(user)
		return
	if (recent_rack > world.time)
		return
	recent_rack = world.time + rack_delay
	rack(user)
	return


/obj/item/gun/ballistic/examine(mob/user)
	. = ..()
	var/count_chambered = !(bolt_type == BOLT_TYPE_NO_BOLT || bolt_type == BOLT_TYPE_OPEN)
	. += "It has [get_ammo(count_chambered)] round\s remaining."

	if (!chambered && !hidden_chambered)
		. += "It does not seem to have a round chambered."
	if (bolt_locked)
		. += "The [bolt_wording] is locked back and needs to be released before firing or de-fouling."
	if (suppressed)
		. += "It has a suppressor attached that can be removed with <b>alt+click</b>."
	if(can_misfire)
		. += span_danger("You get the feeling this might explode if you fire it....")
		if(misfire_probability > 0)
			. += span_danger("Given the state of the gun, there is a [misfire_probability]% chance it'll misfire.")

///Gets the number of bullets in the gun
/obj/item/gun/ballistic/proc/get_ammo(countchambered = TRUE)
	var/bullets = 0 //No silly variable names on my watch.
	if (chambered && countchambered)
		bullets++
	if (magazine)
		bullets += magazine.ammo_count()
	return bullets

///gets a list of every bullet in the gun
/obj/item/gun/ballistic/proc/get_ammo_list(countchambered = TRUE, drop_all = FALSE)
	var/list/rounds = list()
	if(chambered && countchambered)
		rounds.Add(chambered)
		if(drop_all)
			chambered = null
	if(magazine)
		rounds.Add(magazine.ammo_list(drop_all))
	return rounds

#define BRAINS_BLOWN_THROW_RANGE 3
#define BRAINS_BLOWN_THROW_SPEED 1

/obj/item/gun/ballistic/suicide_act(mob/living/user)
	var/obj/item/organ/internal/brain/B = user.get_organ_slot(ORGAN_SLOT_BRAIN)
	if (B && chambered && chambered.loaded_projectile && can_trigger_gun(user) && chambered.loaded_projectile.damage > 0)
		user.visible_message(span_suicide("[user] is putting the barrel of [src] in [user.p_their()] mouth. It looks like [user.p_theyre()] trying to commit suicide!"))
		sleep(2.5 SECONDS)
		if(user.is_holding(src))
			var/turf/T = get_turf(user)
			process_fire(user, user, FALSE, null, BODY_ZONE_HEAD)
			user.visible_message(span_suicide("[user] blows [user.p_their()] brain[user.p_s()] out with [src]!"))
			var/turf/target = get_ranged_target_turf(user, turn(user.dir, 180), BRAINS_BLOWN_THROW_RANGE)
			B.Remove(user)
			B.forceMove(T)
			var/datum/callback/gibspawner = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(spawn_atom_to_turf), /obj/effect/gibspawner/generic, B, 1, FALSE, user)
			B.throw_at(target, BRAINS_BLOWN_THROW_RANGE, BRAINS_BLOWN_THROW_SPEED, callback=gibspawner)
			return BRUTELOSS
		else
			user.visible_message(span_suicide("[user] panics and starts choking to death!"))
			return OXYLOSS
	else
		user.visible_message(span_suicide("[user] is pretending to blow [user.p_their()] brain[user.p_s()] out with [src]! It looks like [user.p_theyre()] trying to commit suicide!</b>"))
		playsound(src, dry_fire_sound, 30, TRUE)
		return OXYLOSS

#undef BRAINS_BLOWN_THROW_SPEED
#undef BRAINS_BLOWN_THROW_RANGE

GLOBAL_LIST_INIT(gun_saw_types, typecacheof(list(
	/obj/item/gun/energy/plasmacutter,
	/obj/item/melee/energy,
	/obj/item/dualsaber
	)))

///Handles all the logic of sawing off guns,
/obj/item/gun/ballistic/proc/sawoff(mob/user, obj/item/saw, handle_modifications = TRUE)
	if(!saw.get_sharpness() || (!is_type_in_typecache(saw, GLOB.gun_saw_types) && saw.tool_behaviour != TOOL_SAW)) //needs to be sharp. Otherwise turned off eswords can cut this.
		return
	if(sawn_off)
		balloon_alert(user, "it's already shortened!")
		return
	if(bayonet)
		balloon_alert(user, "[bayonet.name] must be removed!")
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message(span_notice("[user] begins to shorten [src]."), span_notice("You begin to shorten [src]..."))

	//if there's any live ammo inside the gun, makes it go off
	if(blow_up(user))
		user.visible_message(span_danger("[src] goes off!"), span_danger("[src] goes off in your face!"))
		return

	if(do_after(user, 30, target = src))
		if(sawn_off)
			return
		user.visible_message(span_notice("[user] shortens [src]!"), span_notice("You shorten [src]."))
		sawn_off = TRUE
		if(handle_modifications)
			name = "sawn-off [src.name]"
			desc = sawn_desc
			w_class = WEIGHT_CLASS_NORMAL
			//The file might not have a "gun" icon, let's prepare for this
			lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
			righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
			inhand_x_dimension = 32
			inhand_y_dimension = 32
			inhand_icon_state = "gun"
			worn_icon_state = "gun"
			slot_flags &= ~ITEM_SLOT_BACK //you can't sling it on your back
			slot_flags |= ITEM_SLOT_BELT //but you can wear it on your belt (poorly concealed under a trenchcoat, ideally)
			recoil = SAWN_OFF_RECOIL
			update_appearance()
		return TRUE

/obj/item/gun/ballistic/proc/guncleaning(mob/user, obj/item/A)
	if(misfire_probability == 0)
		balloon_alert(user, "it's already clean!")
		return

	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message(span_notice("[user] begins to cleaning [src]."), span_notice("You begin to clean the internals of [src]."))

	if(do_after(user, 100, target = src))
		var/original_misfire_value = initial(misfire_probability)
		if(misfire_probability > original_misfire_value)
			misfire_probability = original_misfire_value
			user.visible_message(span_notice("[user] cleans [src] of any fouling."), span_notice("You clean [src], removing any fouling, preventing misfire."))
			return TRUE

/obj/item/gun/ballistic/wrench_act(mob/living/user, obj/item/I)
	if(!user.is_holding(src))
		to_chat(user, span_notice("You need to hold [src] to modify it."))
		return TRUE

	if(!can_modify_ammo)
		return

	if(bolt_type == BOLT_TYPE_STANDARD)
		if(get_ammo())
			to_chat(user, span_notice("You can't get at the internals while the gun has a bullet in it!"))
			return

		else if(!bolt_locked)
			to_chat(user, span_notice("You can't get at the internals while the bolt is down!"))
			return

	to_chat(user, span_notice("You begin to tinker with [src]..."))
	I.play_tool_sound(src)
	if(!I.use_tool(src, user, 3 SECONDS))
		return TRUE

	if(blow_up(user))
		user.visible_message(span_danger("[src] goes off!"), span_danger("[src] goes off in your face!"))
		return

	if(magazine.caliber == initial_caliber)
		magazine.caliber = alternative_caliber
		if(alternative_ammo_misfires)
			can_misfire = TRUE
		fire_sound = alternative_fire_sound
		to_chat(user, span_notice("You modify [src]. Now it will fire [alternative_caliber] rounds."))
	else
		magazine.caliber = initial_caliber
		if(alternative_ammo_misfires)
			can_misfire = FALSE
		fire_sound = initial_fire_sound
		to_chat(user, span_notice("You reset [src]. Now it will fire [initial_caliber] rounds."))


///used for sawing guns, causes the gun to fire without the input of the user
/obj/item/gun/ballistic/proc/blow_up(mob/user)
	. = FALSE
	for(var/obj/item/ammo_casing/AC in magazine.stored_ammo)
		if(AC.loaded_projectile)
			process_fire(user, user, FALSE)
			. = TRUE

/obj/item/gun/ballistic/proc/instant_reload()
	SIGNAL_HANDLER
	if(magazine)
		magazine.top_off()
	else
		if(!accepted_magazine_type)
			return
		magazine = new accepted_magazine_type(src)
	chamber_round()
	update_appearance()

// monkestation edit start
/obj/item/gun/ballistic/handle_atom_del(atom/A)
	if (istype(A, /obj/item/ammo_casing) && magazine)
		magazine.handle_atom_del(A)
	return ..()
// monkestation edit end

/obj/item/suppressor
	name = "suppressor"
	desc = "A syndicate small-arms suppressor for maximum espionage."
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "suppressor"
	w_class = WEIGHT_CLASS_TINY
