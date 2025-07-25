//Section for the Mentor Friend verb run test
MENTOR_VERB(imaginary_friend, R_MENTOR, FALSE, "Become Imaginary Friend", "Become someones imaginary friend.", MENTOR_CATEGORY_MAIN)
	if(istype(user.mob, /mob/camera/imaginary_friend/mentor))
		to_chat(user, span_warning("You are already someone's imaginary friend!"))
		return

	var/mob/living/mentee
	switch(input(user, "Select by:", "Imaginary Friend") as null|anything in list("Key", "Mob"))
		if("Key")
			var/client/friendclient = input(user, "Please, select a key.", "Imaginary Friend") as null|anything in sort_key(GLOB.clients)
			if(!friendclient)
				return
			mentee = friendclient.mob
		if("Mob")
			var/mob/friendmob = input(user, "Please, select a mob.", "Imaginary Friend") as null|anything in sort_names(GLOB.alive_player_list)
			if(!friendmob)
				return
			mentee = friendmob

	if(!isobserver(user.mob))
		to_chat(user, span_warning("You can only be an imaginary friend when you are observing."))
		return

	if(!istype(mentee))
		to_chat(user, span_warning("Selected mob is not alive."))
		return

	var/mob/camera/imaginary_friend/mentor/mentorfriend = new(get_turf(mentee), mentee)
	mentorfriend.PossessByPlayer(user.key)
	log_admin("[key_name(mentorfriend)] started being the imaginary friend of [key_name(mentee)].")
	message_admins("[key_name(mentorfriend)] started being the imaginary friend of [key_name(mentee)].")
	BLACKBOX_LOG_MENTOR_VERB("Become Imaginary Friend")

MENTOR_VERB(end_imaginary_friendship, R_MENTOR, FALSE, "End Imaginary Friendship", "Break the heart of your friend and end your friendship.", MENTOR_CATEGORY_MAIN)
	if(!istype(user.mob, /mob/camera/imaginary_friend/mentor))
		to_chat(user, span_warning("You aren't anybody's imaginary friend!"))
		return

	var/mob/camera/imaginary_friend/mentor/mentorfriend = user.mob
	mentorfriend.unmentor()
	BLACKBOX_LOG_MENTOR_VERB("End Imaginary Friendship")

//Section for the Mentor Friend mob.
/mob/camera/imaginary_friend/mentor
	var/datum/action/innate/imaginary_leave/leave

/mob/camera/imaginary_friend/mentor/greet()
	to_chat(src, "<span class='notice'><b>You are the imaginary friend of [owner]!</b></span>")
	to_chat(src, "<span class='notice'>You are here to help [owner] in any way you can.</span>")
	to_chat(src, "<span class='notice'>You cannot directly influence the world around you, but you can see what [owner] cannot.</span>")

/mob/camera/imaginary_friend/mentor/Login()
	. = ..()
	setup_friend()
	Show()

/mob/camera/imaginary_friend/mentor/Logout()
	. = ..()
	if(!src.key)
		return
	unmentor()

/mob/camera/imaginary_friend/mentor/Initialize(mapload, mob/imaginary_friend_owner, datum/preferences/appearance_from_prefs = null)
	. = ..()

	owner = imaginary_friend_owner

	if(appearance_from_prefs)
		INVOKE_ASYNC(src, PROC_REF(setup_friend_from_prefs), appearance_from_prefs)
	else
		INVOKE_ASYNC(src, PROC_REF(setup_friend))

	join = new
	join.Grant(src)
	hide = new
	hide.Grant(src)
	leave = new
	leave.Grant(src)

	if(!owner.imaginary_group)
		owner.imaginary_group = list(owner)
	owner.imaginary_group += src

/mob/camera/imaginary_friend/mentor/proc/unmentor()
	icon = human_image
	log_admin("[key_name(src)] stopped being the imaginary friend of [key_name(owner)].")
	message_admins("[key_name(src)] stopped being the imaginary friend of [key_name(owner)].")
	ghostize()
	qdel(src)

/mob/camera/imaginary_friend/mentor/recall()
	if(QDELETED(owner))
		unmentor()
		return FALSE
	if(loc == owner)
		return FALSE
	forceMove(owner)

/datum/action/innate/imaginary_hide/mentor/Deactivate()
	active = FALSE
	var/mob/camera/imaginary_friend/I = owner
	I.hidden = TRUE
	I.Show()
	name = "Show"
	desc = "Become visible to your owner."
	button_icon_state = "unhide"

/datum/action/innate/imaginary_leave
	name = "Leave"
	desc = "Stop mentoring."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	background_icon_state = "bg_revenant"
	button_icon_state = "mindswap"

/datum/action/innate/imaginary_leave/Activate()
	var/mob/camera/imaginary_friend/mentor/I = owner
	I.unmentor()


//For use with Mentor Friend (IF) topic calls

/client/proc/create_ifriend(mob/living/friend_owner, seek_confirm = FALSE)
	var/client/C = usr.client
	if(!C.mentor_datum?.check_for_rights(R_MENTOR))
		return

	if(istype(C.mob, /mob/camera/imaginary_friend))
		var/mob/camera/imaginary_friend/IF = C.mob
		IF.ghostize()
		return

	if(!istype(friend_owner)) // living only
		to_chat(usr, span_warning("That creature cannot have Imaginary Friends!"))
		return

	if(!isobserver(C.mob))
		to_chat(usr, span_warning("You can only be an imaginary friend when you are observing."))
		return


	if(seek_confirm && alert(usr, "Become Imaginary Friend of [friend_owner]?", "Confirm" ,"Yes", "No") != "Yes")
		return

	var/mob/camera/imaginary_friend/mentor/mentorfriend = new(get_turf(friend_owner), friend_owner)
	mentorfriend.PossessByPlayer(usr.key)

	admin_ticket_log(friend_owner, "[key_name(C)] became an imaginary friend of [key_name(friend_owner)]")
	log_admin("[key_name(mentorfriend)] started being imaginary friend of [key_name(friend_owner)].")
	message_admins("[key_name(mentorfriend)] started being the imaginary friend of [key_name(friend_owner)].")

//topic call
/client/proc/mentor_friend(href_list)
	if(href_list["mentor_friend"])
		var/mob/M = locate(href_list["mentor_friend"])
		create_ifriend(M, TRUE)
