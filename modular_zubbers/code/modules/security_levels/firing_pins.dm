/obj/item/firing_pin/
	var/auth_user
/obj/item/firing_pin/alert_level
	name = "alert-level firing pin"
	desc = "This is a firing pin that only works on approved alert levels."
	fail_message = "alert level low!"

/obj/item/firing_pin/alert_level/Initialize(mapload)
	. = ..()
	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(check_alert))

/obj/item/firing_pin/alert_level/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()

	if(istype(attacking_item, /obj/item/card/id) && attacking_item.GetID())
		var/obj/item/card/id/id_card = attacking_item.GetID()
		if((ACCESS_COMMAND in id_card.access) || (ACCESS_ARMORY in id_card.access))
			if(!auth_user)
				auth_user = "[user.name]"
				to_chat(user, "You authorize the gun to fire lethals.")
				return
			if(auth_user)
				auth_user = null
				to_chat(user, "You deauthorize the gun from firing lethals.")
				return
		else
			balloon_alert(user, "Not Authorized!")
			return

/obj/item/gun/energy/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	pin?.attackby(attacking_item, user, params)

/obj/item/firing_pin/alert_level/pin_auth(mob/living/user)
	var/list/static/lethals = list(/obj/item/ammo_casing/energy/laser)
	var/current_ammo_type = gun.chambered
	if(is_type_in_list(current_ammo_type, lethals, TRUE))

		if(check_alert() || auth_user)
			return TRUE
		else
			return FALSE
	return FALSE

/obj/item/firing_pin/alert_level/proc/check_alert(mob/living/user)
	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_AMBER)
		return TRUE
	else
		balloon_alert(user, fail_message)
		return FALSE

/obj/item/gun/energy
	pin = /obj/item/firing_pin/alert_level

/datum/element/weapon_description/build_label_text(obj/item/gun/source)
	. = ..()
	if(source?.pin?.auth_user)
		return . += "Authorized to fire lethally by [source?.pin?.auth_user]."
