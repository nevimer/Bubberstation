GLOBAL_LIST(bellies)
GLOBAL_LIST(atoms_within_bellies)
SUBSYSTEM_DEF(nomming)


/datum/controller/subsystem/nomming/fire(resumed)
	if(MC_TICK_CHECK)
		return
	for(var/i in GLOB.bellies as mob)

/proc/get_prefered_vore_organ()
	var/mob/living/carbon/caller = usr
	if(!istype(caller))
		return
	var/preferred_vore_organ = caller.get_organ_slot(ORGAN_SLOT_STOMACH) // that's right. in the future we can pick the funny organs.

/datum/component/vore
/datum/component/vore/RegisterWithParent()

	parent = get_prefered_vore_organ(src) | src // Register the preferred organ, or just be the mob if basicmob


/mob/
	var/list/atom_holders


/mob/proc/enter_the_nom(mob/nomminee)
	nomminee |= GLOB.atoms_within_bellies
	var/datum/component/nomming = GetComponent(/datum/component/vore)
/mob/proc/leave_the_nom(mob/nomminee)
	nomminee -= GLOB.atoms_within_bellies
/mob/proc/exist



/atom/movable/proc/process()

/atom/movable/proc/
