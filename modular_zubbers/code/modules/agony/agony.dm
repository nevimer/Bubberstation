/datum/component/agony
	var/tier = 0
	var/deaths = 0


/datum/component/agony/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	RegisterSignal(parent, COMSIG_CARBON_GAIN_WOUND, PROC_REF(on_wound_gain))
	RegisterSignal(parent, COMSIG_CARBON_LOSE_WOUND, PROC_REF(on_wound_loss))
/datum/component/agony/proc/get_wound_score()
	var/mob/living/carbon/human/humanoid = parent
	var/score
	if(istype(humanoid))
		for(var/datum/wound/wound in humanoid.all_wounds)
			if(wound.disabling)
				score += 50
			switch(wound.severity)
				if(WOUND_SEVERITY_TRIVIAL)
					score += 10
				if(WOUND_SEVERITY_MODERATE)
					score += 35
					to_chat(parent, span_userdanger("Your [wound.limb] hurts a lot!"))
				if(WOUND_SEVERITY_SEVERE)
					score += 85
					to_chat(parent, span_userdanger("Your [wound.limb] feels horrible!"))
				if(WOUND_SEVERITY_CRITICAL)
					score += 115
					to_chat(parent, span_userdanger("Your [wound.limb] needs to come off!"))
				if(WOUND_SEVERITY_LOSS)
					score += 200
	. = score

/datum/component/agony/proc/on_wound_gain()
	SIGNAL_HANDLER
	var/mob/living/carbon/human/humanoid = parent
	var/score = get_wound_score()
	switch(score)
		if(150 to INFINITY)
			tier++
		if(85 to 149)
			tier++

/datum/component/agony/proc/on_wound_loss()
	SIGNAL_HANDLER
	var/score = get_wound_score()
	switch(score)
		if(0 to 85)
			(deaths <= tier) ? (tier = deaths) : tier--


/datum/component/agony/proc/on_examine(atom/A, mob/user, list/examine_list)
	SIGNAL_HANDLER
	switch(tier)
		if(1)
			examine_list += span_warning("It looks as if [A] is in pain.")
		if(2)
			examine_list += span_boldwarning("[A] seems to be suffering.")
		if(3)
			examine_list += span_alertwarning("[A] looks like they should be on painkillers.")
		if(4 to INFINITY)
			examine_list += span_userdanger("[A] looks like they're about to pass out!")

/datum/component/agony/proc/on_death()
	deaths++
	prob(50 * (tier ? tier : 1))
		tier++
		to_chat(parent, span_userdanger("A certain sort of tiredness enters your soul..."))
	if(tier <= 4)
		to_chat(parent, span_userdanger("You feel as if your body can't take any more."))
