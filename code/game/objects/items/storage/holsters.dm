
/obj/item/storage/belt/holster
	name = "shoulder holster"
	desc = "A rather plain but still cool looking holster that can hold a handgun."
	icon_state = "holster"
	inhand_icon_state = "holster"
	worn_icon_state = "holster"
	alternate_worn_layer = UNDER_SUIT_LAYER
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/belt/holster/equipped(mob/user, slot)
	. = ..()
	if(slot & (ITEM_SLOT_BELT|ITEM_SLOT_SUITSTORE))
		ADD_TRAIT(user, TRAIT_GUNFLIP, CLOTHING_TRAIT)

/obj/item/storage/belt/holster/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_GUNFLIP, CLOTHING_TRAIT)

/obj/item/storage/belt/holster/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 1
	atom_storage.max_total_storage = 16
	atom_storage.set_holdable(list(
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/gun/ballistic/revolver,
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/taser,
		/obj/item/gun/energy/dueling,
		/obj/item/food/grown/banana,
		/obj/item/gun/energy/laser/thermal,
		/obj/item/gun/ballistic/rifle/boltaction, //fits if you make it an obrez
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/energy/e_gun/hos,
	))

/obj/item/storage/belt/holster/energy
	name = "energy shoulder holsters"
	desc = "A rather plain pair of shoulder holsters with a bit of insulated padding inside. Designed to hold energy weaponry."

/obj/item/storage/belt/holster/energy/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 2
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.set_holdable(list(
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/taser,
		/obj/item/gun/energy/dueling,
		/obj/item/food/grown/banana,
		/obj/item/gun/energy/laser/thermal,
		/obj/item/gun/energy/recharge/ebow,
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/energy/e_gun/hos,
	))

/obj/item/storage/belt/holster/energy/thermal
	name = "thermal shoulder holsters"
	desc = "A rather plain pair of shoulder holsters with a bit of insulated padding inside. Meant to hold a twinned pair of thermal pistols, but can fit several kinds of energy handguns as well."

/obj/item/storage/belt/holster/energy/thermal/PopulateContents()
	generate_items_inside(list(
		/obj/item/gun/energy/laser/thermal/inferno = 1,
		/obj/item/gun/energy/laser/thermal/cryo = 1,
	),src)

/obj/item/storage/belt/holster/energy/disabler
	desc = "A rather plain pair of shoulder holsters with a bit of insulated padding inside. Designed to hold energy weaponry. A production stamp indicates that it was shipped with a disabler."

/obj/item/storage/belt/holster/energy/disabler/PopulateContents()
	generate_items_inside(list(
		/obj/item/gun/energy/disabler = 1,
	),src)

/obj/item/storage/belt/holster/energy/smoothbore
	desc = "A rather plain pair of shoulder holsters with a bit of insulated padding inside. Designed to hold energy weaponry. Seems it was meant to fit two smoothbores."

/obj/item/storage/belt/holster/energy/smoothbore/PopulateContents()
	generate_items_inside(list(
		/obj/item/gun/energy/disabler/smoothbore = 2,
	),src)

/obj/item/storage/belt/holster/detective
	name = "detective's holster"
	desc = "A holster able to carry handguns and some ammo. WARNING: Badasses only."
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/belt/holster/detective/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 3
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.set_holdable(list(
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/ammo_box/magazine/m9mm, // Pistol magazines.
		/obj/item/ammo_box/magazine/m9mm_aps,
		/obj/item/ammo_box/magazine/r10mm,
		/obj/item/ammo_box/magazine/m10mm,
		/obj/item/ammo_box/magazine/m35,
		/obj/item/ammo_box/magazine/m45,
		/obj/item/ammo_box/magazine/m50,
		/obj/item/ammo_box/magazine/c35sol_pistol,
		/obj/item/ammo_box/magazine/c585trappiste_pistol,
		/obj/item/ammo_box/magazine/whispering_jester_45_magazine,
		/obj/item/gun/ballistic/revolver,
		/obj/item/gun/ballistic/modular/mk_58,
		/obj/item/ammo_box/c38, // Revolver speedloaders.
		/obj/item/ammo_box/a357,
		/obj/item/ammo_box/a762,
		/obj/item/ammo_box/magazine/toy/pistol,
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/taser,
		/obj/item/gun/energy/dueling,
		/obj/item/gun/energy/laser/thermal,
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/energy/e_gun/hos,
		/obj/item/gun/ballistic/rifle/boltaction, //fits if you make it an obrez
		))

/obj/item/storage/belt/holster/detective/full/PopulateContents()
	generate_items_inside(list(
		/obj/item/gun/ballistic/revolver/c38/detective = 1,
		/obj/item/ammo_box/c38 = 2,
	), src)

/obj/item/storage/belt/holster/detective/bis/full/PopulateContents()
	generate_items_inside(list(
		/obj/item/gun/ballistic/revolver/c38 = 1,
		/obj/item/ammo_box/c38 = 2,
	), src)

/obj/item/storage/belt/holster/detective/full/ert
	name = "marine's holster"
	desc = "Wearing this makes you feel badass, but you suspect it's just a repainted detective's holster from the NT surplus."
	icon_state = "syndicate_holster"
	inhand_icon_state = "syndicate_holster"
	worn_icon_state = "syndicate_holster"

/obj/item/storage/belt/holster/detective/full/ert/PopulateContents()
	generate_items_inside(list(
		/obj/item/gun/ballistic/automatic/pistol/m1911 = 1,
		/obj/item/ammo_box/magazine/m45 = 2,
	),src)

/obj/item/storage/belt/holster/chameleon
	name = "syndicate holster"
	desc = "A hip holster that uses chameleon technology to disguise itself, due to the added chameleon tech, it cannot be mounted onto armor."
	icon_state = "syndicate_holster"
	inhand_icon_state = "syndicate_holster"
	worn_icon_state = "syndicate_holster"
	w_class = WEIGHT_CLASS_NORMAL
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/storage/belt/holster/chameleon/Initialize(mapload)
	. = ..()

	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/storage/belt
	chameleon_action.chameleon_name = "Belt"
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/storage/belt/holster/chameleon/Initialize(mapload)
	. = ..()
	atom_storage.silent = TRUE

/obj/item/storage/belt/holster/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/storage/belt/holster/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/storage/belt/holster/chameleon/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 2
	atom_storage.max_total_storage = WEIGHT_CLASS_NORMAL
	atom_storage.set_holdable(list(
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/ammo_box/magazine/m9mm,
		/obj/item/ammo_box/magazine/m9mm_aps,
		/obj/item/ammo_box/magazine/m10mm,
		/obj/item/ammo_box/magazine/m45,
		/obj/item/ammo_box/magazine/m50,
		/obj/item/gun/ballistic/revolver,
		/obj/item/ammo_box/c38,
		/obj/item/ammo_box/a357,
		/obj/item/ammo_box/a762,
		/obj/item/ammo_box/magazine/toy/pistol,
		/obj/item/gun/energy/recharge/ebow,
		/obj/item/gun/energy/e_gun/mini,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/taser,
		/obj/item/gun/energy/dueling,
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/energy/e_gun/hos,
	))

	atom_storage.silent = TRUE

// MONKESTATION ADDITION START
/obj/item/storage/belt/holster/chameleon/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour != TOOL_MULTITOOL)
		return ..()

	if(chameleon_action.hidden)
		chameleon_action.hidden = FALSE
		actions += chameleon_action
		chameleon_action.Grant(user)
		log_game("[key_name(user)] has removed the disguise lock on the chameleon holster ([name]) with [W]")
	else
		chameleon_action.hidden = TRUE
		actions -= chameleon_action
		chameleon_action.Remove(user)
		log_game("[key_name(user)] has locked the disguise of the chameleon holster ([name]) with [W]")
// MONKESTATION ADDITION END


/obj/item/storage/belt/holster/nukie
	name = "operative holster"
	desc = "A deep shoulder holster capable of holding almost any form of firearm and its ammo."
	icon_state = "syndicate_holster"
	inhand_icon_state = "syndicate_holster"
	worn_icon_state = "syndicate_holster"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/belt/holster/nukie/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 2
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY
	atom_storage.set_holdable(list(
		/obj/item/gun, // ALL guns.
		/obj/item/ammo_box/magazine, // ALL magazines.
		/obj/item/ammo_box/c38, //There isn't a speedloader parent type, so I just put these three here by hand.
		/obj/item/ammo_box/a357, //I didn't want to just use /obj/item/ammo_box, because then this could hold huge boxes of ammo.
		/obj/item/ammo_box/a762,
		/obj/item/ammo_casing, // For shotgun shells, rockets, launcher grenades, and a few other things.
		/obj/item/grenade, // All regular grenades, the big grenade launcher fires these.
		))


/obj/item/storage/belt/holster/nukie/cowboy
	desc = "A deep shoulder holster capable of holding almost any form of small firearm and its ammo. This one's specialized for handguns."

/obj/item/storage/belt/holster/nukie/cowboy/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 3
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL

/obj/item/storage/belt/holster/nukie/cowboy/full/PopulateContents()
	generate_items_inside(list(
		/obj/item/gun/ballistic/revolver/syndicate/cowboy = 1,
		/obj/item/ammo_box/a357 = 2,
	), src)
