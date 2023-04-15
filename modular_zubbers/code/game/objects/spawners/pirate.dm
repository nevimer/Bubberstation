/obj/effect/mob_spawn/ghost_role/human/pirate/create(mob/mob_possessor, newname)

	if(SSshuttle.emergency || exceeded_spawn_time)
		return
	var/tracking
	for(var/turf/A in SSmapping.shuttle_templates)
		for(var/obj/effect/mob_spawn/ghost_role/human/pirate/spawner in A)
			addtimer(VARSET_CALLBACK(spawner, exceeded_spawn_time, TRUE), 10 MINUTES, TIMER_UNIQUE)
			tracking++
	if(tracking)
		notify_ghosts("The timer to become a pirate is counting down! Double click a spawner soon!")


	. = ..()






/obj/effect/mob_spawn/ghost_role/human/pirate
	var/exceeded_spawn_time = FALSE
