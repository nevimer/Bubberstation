GLOBAL_LIST(bellies)
GLOBAL_LIST(atoms_within_bellies)
SUBSYSTEM_DEF(nomming)


/datum/controller/subsystem/nomming/fire(resumed)
	if(MC_TICK_CHECK)
		return
	for(var/i in GLOB.bellies as mob)

/proc/get_prefered_container_organ()
	var/mob/living/carbon/caller = usr
	if(!istype(caller))
		return
	var/preferred_container = caller.resolve_container_pref() // that's right. in the future we can pick the funny organs.

/datum/component/container
/datum/component/container/RegisterWithParent()

	parent = get_prefered_container_organ(src) | src // Register the preferred organ, or just be the mob if basicmob


/mob/
	var/list/atom_holders


/mob/proc/enter_the_nom(mob/nomminee)
	nomminee |= GLOB.atoms_within_bellies
	var/datum/component/container/nomming = GetComponent(/datum/component/container)

/mob/proc/leave_the_nom(mob/nomminee)
	nomminee -= GLOB.atoms_within_bellies
/mob/proc/exist_within()
	SIGNAL_HANDLER




/atom/movable/proc/process()

/atom/movable/proc/
