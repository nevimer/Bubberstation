GLOBAL_LIST(bellies)
GLOBAL_LIST(atoms_within_bellies)
SUBSYSTEM_DEF(nomming)


// ALL LOGIC BETWEEN MOB AND THE COMPONENT WILL  REQUIRE DCS

/datum/controller/subsystem/nomming/fire(resumed)
	if(MC_TICK_CHECK)
		return


/proc/get_prefered_container_organ()
	var/mob/living/carbon/caller = usr
	if(!istype(caller))
		return
	var/preferred_container = caller.resolve_container_pref() // that's right. in the future we can pick the funny organs.

/datum/belly
	var/list/stored_atoms
	var/flavour_text = "A dark and fleshy room. Slightly acidic."
	name = "regular digestive container"
	var/mob/living/owner_as_living
/datum/belly/proc/choose_name()
	src.name = input(src, "Pick this belly name?")
/datum/belly/proc/load_prefs(index)
	owner_as_living.client.mind.prefs.read_preference(/datum/preference/string/belly_name[index]) // tragic for now
/datum/belly/proc/write_prefs(index)
	owner_as_living.client.mind.prefs.write_preference(/datum/preference/belly_name[index]) // figure this out

/datum/component/container
	var/list/bellies
	var/datum/belly/current_belly

/datum/component/container
/datum/component/container/RegisterWithParent()

	parent = get_prefered_container_organ(src) | src // Register the preferred organ, or just be the mob if basicmob
	var/index = 0
	for(var/datum/belly in bellies)
		index++
		current_belly = belly
		belly.load_prefs[index]

/mob/
	var/datum/component/container/atom_holder // We don't need this as it will be a component


/mob/proc/enter_the_nom(mob/nomminee)
	nomminee |= GLOB.atoms_within_bellies
	var/datum/component/container/nomming = GetComponent(/datum/component/container)

/mob/proc/leave_the_nom(mob/nomminee)
	nomminee -= GLOB.atoms_within_bellies
/mob/proc/exist_within()
	SIGNAL_HANDLER




/atom/movable/proc/process()

/atom/movable/proc/
