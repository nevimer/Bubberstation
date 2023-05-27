#define WEH_DIVIDER rand(2,4)
/mob/
	var/datum/voicebox/voicebox

/mob/living/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null, message_range = 7, datum/saymode/saymode = null)
	. = ..()
	if(!voicebox)
		voicebox = new /datum/voicebox
		voicebox.parent = src
	if(!saymode) // No telepaths
		voicebox.speak_sfx(message)

/datum/voicebox/
	var/soundfile = "modules/emotes/sound/voice/weh.ogg" // Subtypes change this.
	var/mob/parent // Ref to owner
	var/blabbing = FALSE // Are we talking?

/datum/voicebox/proc/speak_sfx(passed_msg)
	ASYNC
	blabbing = TRUE
	for(var/i in (length_char(passed_msg) / WEH_DIVIDER))
		i++

		playsound(src, soundfile, 50, TRUE)
		sleep(WEH_DIVIDER)
		. = TRUE
	blabbing = FALSE
	if(!.)
		return

/datum/voicebox/lizard
	soundfile

