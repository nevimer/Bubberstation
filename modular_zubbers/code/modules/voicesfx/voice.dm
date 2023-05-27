#define WEH_DIVIDER rand(2,4)

/mob/
	var/datum/voicebox/voicebox

/datum/species/
	var/datum/voicebox/species_voicebox
/datum/species/lizard
	species_voicebox = /datum/voicebox/lizard
/datum/species/unathi
	species_voicebox = /datum/voicebox/unathi
/datum/species/vulpkanin
	species_voicebox = /datum/voicebox/vulpkanin
/datum/species/mammal
	species_voicebox = /datum/voicebox/mammal
/datum/species/human/felinid
	species_voicebox = /datum/voicebox/felinid

/mob/living/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null, message_range = 7, datum/saymode/saymode = null)
	. = ..()
	if(!voicebox)
		if(ishuman(src))
			var/mob/living/carbon/human/human = src
			voicebox = new human.dna.species.species_voicebox

		if(issilicon(src))
			voicebox = new /datum/voicebox/silicon

		else
			voicebox = new /datum/voicebox
		voicebox.parent = src

		message_admins("I got a [voicebox] for [src]")
	if(!saymode) // No telepaths
		voicebox.speak_sfx(message)

/datum/voicebox/
	var/soundfile = 'modular_zubbers/sound/misc/dog_toy.ogg' // Subtypes change this.
	var/mob/parent // Ref to owner
	var/blabbing = FALSE // Are we talking?

/datum/voicebox/proc/speak_sfx(passed_msg)
	ASYNC
	blabbing = TRUE
	for(var/i=0 to clamp((length_char(passed_msg) / WEH_DIVIDER), 1, 50))
		i++
		playsound(parent, soundfile, 50, TRUE)
		sleep(WEH_DIVIDER)
		. = TRUE
	blabbing = FALSE
	if(!.)
		return FALSE
/datum/voicebox/human
/datum/voicebox/lizard
	soundfile = 'modular_skyrat/modules/emotes/sound/voice/weh.ogg'
/datum/voicebox/unathi
	soundfile = 'modular_skyrat/modules/emotes/sound/voice/weh.ogg'
/datum/voicebox/vulpkanin
	soundfile = 'modular_skyrat/modules/emotes/sound/voice/woof.ogg'
/datum/voicebox/mammal
	soundfile = 'modular_skyrat/modules/emotes/sound/voice/merp.ogg'
/datum/voicebox/silicon
	soundfile = 'modular_skyrat/modules/emotes/sound/voice/roro_rogue.ogg'
/datum/voicebox/felinid
	soundfile = 'modular_skyrat/modules/emotes/sound/voice/merowr.ogg'
