
GLOBAL_LIST_INIT(potential_indicators, list(
	STUNNED = image(icon = 'modular_zubbers/icons/mob/status_indicators.dmi', icon_state = STUNNED),
	WEAKEN = image(icon = 'modular_zubbers/icons/mob/status_indicators.dmi', icon_state = WEAKEN),
	PARALYSIS = image(icon = 'modular_zubbers/icons/mob/status_indicators.dmi', icon_state = PARALYSIS),
	SLEEPING = image(icon = 'modular_zubbers/icons/mob/status_indicators.dmi', icon_state = SLEEPING),
	CONFUSED = image(icon = 'modular_zubbers/icons/mob/status_indicators.dmi', icon_state = CONFUSED),
))


/datum/component/status_indicator
	var/list/status_indicators = null // Will become a list as needed. Contains our status indicator objects. Note, they are actually added to overlays, this just keeps track of what exists.
	var/mob/living/attached_mob
	var/running // We can run many times at once, but that's bad. Don't need constant updates.
	var/last_status
	COOLDOWN_DECLARE(status_indicator_cooldown)


/datum/component/status_indicator/proc/calc_list()

	var/fake = indicator_fakeouts()
/// Returns true if the mob is weakened. Also known as floored.
	if(!fake && \
	attached_mob.IsKnockdown() || \
	HAS_TRAIT(attached_mob, TRAIT_FLOORED) && \
	!HAS_TRAIT_FROM(attached_mob, TRAIT_FLOORED, BUCKLED_TRAIT)
	)
		. |= WEAKEN_STATUS

/// Returns true if the mob is stunned.
	if(!fake && \
	HAS_TRAIT_FROM(attached_mob, TRAIT_INCAPACITATED, TRAIT_STATUS_EFFECT(STAT_TRAIT)) || \
	HAS_TRAIT(attached_mob, TRAIT_CRITICAL_CONDITION) || \
	HAS_TRAIT_FROM(attached_mob, TRAIT_IMMOBILIZED, TRAIT_STATUS_EFFECT(STAT_TRAIT)) || \
	HAS_TRAIT_FROM(attached_mob, TRAIT_IMMOBILIZED, CHOKEHOLD_TRAIT) || \
	HAS_TRAIT_FROM(attached_mob, TRAIT_INCAPACITATED, TRAIT_STATUS_EFFECT(STAT_TRAIT)) || \
	HAS_TRAIT_FROM(attached_mob, TRAIT_IMMOBILIZED, TRAIT_STATUS_EFFECT(STAT_TRAIT))
	)
		. |= STUNNED_STATUS

/// Returns true if the mob is paralyzed - for can't fight back purposes.
	if(!fake && \
	attached_mob.IsParalyzed() || \
	HAS_TRAIT_FROM(attached_mob, TRAIT_FLOORED, CHOKEHOLD_TRAIT) || \
	HAS_TRAIT_FROM(attached_mob, TRAIT_IMMOBILIZED, TRAIT_STATUS_EFFECT(STAT_TRAIT)) || \
	HAS_TRAIT(attached_mob, TRAIT_CRITICAL_CONDITION) || \
	HAS_TRAIT_FROM(attached_mob, TRAIT_INCAPACITATED, STAMINA))
		. |= PARALYSIS_STATUS

/// Returns true if the mob is unconcious for any reason.
	if(!fake && HAS_TRAIT(attached_mob, TRAIT_KNOCKEDOUT))
		. |= SLEEPING_STATUS

/// Returns true if the mob has confusion.
	if(!fake && attached_mob.has_status_effect(/datum/status_effect/confusion))
		. |= CONFUSED_STATUS
	last_status = .


/datum/component/status_indicator/RegisterWithParent()
	attached_mob = parent
	// The Basics
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(handle_status_indicators))
	RegisterSignal(parent, COMSIG_LIVING_LIFE, PROC_REF(handle_status_indicators))
	// When things actually happen
	RegisterSignal(parent, COMSIG_MOB_LOGIN, PROC_REF(apply_pref_on_login))

/datum/component/status_indicator/proc/apply_pref_on_login()
	var/atom/movable/screen/plane_master/game_world_upper_fov_hidden/status_indicator/local_status = locate() in attached_mob.client.screen
	if(local_status)
		. = attached_mob.client.prefs.read_preference(/datum/preference/toggle/enable_status_indicators)
		local_status.alpha = (.) ? 255 : 0

/datum/component/status_indicator/UnregisterFromParent()
	QDEL_NULL(status_indicators)
	UnregisterSignal(attached_mob, COMSIG_LIVING_DEATH)
	UnregisterSignal(attached_mob, COMSIG_LIVING_LIFE)
	attached_mob = null
/// This proc makes it so that mobs that have status indicators are checked to remove them, especially in fakeout situations.

/// Cases in which no status indicators should appear above a mob, such as changeling revive and regen coma.
/datum/component/status_indicator/proc/indicator_fakeouts()
	if(HAS_TRAIT(attached_mob, TRAIT_DEATHCOMA))
		return TRUE
	return FALSE

/// Refreshes the indicators over a mob's head. Should only be called when adding or removing a status indicator with the above procs,
/// or when the mob changes size visually for some reason.
/datum/component/status_indicator/proc/handle_status_indicators()
	SIGNAL_HANDLER
	// First, get rid of all the overlays.
	if(!COOLDOWN_FINISHED(src, status_indicator_cooldown))
		return
	COOLDOWN_START(src, status_indicator_cooldown, 0.5 SECONDS) // Race conditions are fun, lets avoid them
	if(attached_mob.stat == DEAD)
		return

	var/mob/living/carbon/my_carbon_mob = attached_mob

	var/icon_scale = get_icon_scale(my_carbon_mob)


	// Now put them back on in the right spot.
	var/our_sprite_x = 16 * icon_scale
	var/our_sprite_y = 24 * icon_scale

	var/x_offset = our_sprite_x // Add your own offset here later if you want.
	var/y_offset = our_sprite_y + STATUS_INDICATOR_Y_OFFSET

	// Calculates how 'long' the row of indicators and the margin between them should be.
	// The goal is to have the center of that row be horizontally aligned with the sprite's center.
	var/current_x_position = (x_offset / 2)

	// In /mob/living's `update_transform()`, the sprite is horizontally shifted when scaled up, so that the center of the sprite doesn't move to the right.
	// Because of that, this adjustment needs to happen with the future indicator row as well, or it will look bad.
	current_x_position -= 16 * (icon_scale - DEFAULT_MOB_SCALE)
	var/indicators_to_add = calc_list()
	// Now the indicator row can actually be built.

	var/list/overlays_list = list()
	if(indicators_to_add)
		if(indicators_to_add & STUNNED_STATUS)
			var/image/indicator = GLOB.potential_indicators[STUNNED]
			indicator.plane = GAME_PLANE_UPPER_FOV_HIDDEN
			indicator.layer = STATUS_LAYER
			indicator.appearance_flags = PIXEL_SCALE|TILE_BOUND|NO_CLIENT_COLOR|RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM|KEEP_APART
			indicator.pixel_y = y_offset
			indicator.pixel_x = current_x_position
			overlays_list |= indicator
			current_x_position += STATUS_INDICATOR_ICON_X_SIZE + STATUS_INDICATOR_ICON_MARGIN
		if(indicators_to_add & WEAKEN_STATUS)
			var/image/indicator = GLOB.potential_indicators[WEAKEN]
			indicator.plane = GAME_PLANE_UPPER_FOV_HIDDEN
			indicator.layer = STATUS_LAYER
			indicator.appearance_flags = PIXEL_SCALE|TILE_BOUND|NO_CLIENT_COLOR|RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM|KEEP_APART
			indicator.pixel_y = y_offset
			indicator.pixel_x = current_x_position
			overlays_list |= indicator
			current_x_position += STATUS_INDICATOR_ICON_X_SIZE + STATUS_INDICATOR_ICON_MARGIN
		if(indicators_to_add & PARALYSIS_STATUS)
			var/image/indicator = GLOB.potential_indicators[PARALYSIS]
			indicator.plane = GAME_PLANE_UPPER_FOV_HIDDEN
			indicator.layer = STATUS_LAYER
			indicator.appearance_flags = PIXEL_SCALE|TILE_BOUND|NO_CLIENT_COLOR|RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM|KEEP_APART
			indicator.pixel_y = y_offset
			indicator.pixel_x = current_x_position
			overlays_list |= indicator
			current_x_position += STATUS_INDICATOR_ICON_X_SIZE + STATUS_INDICATOR_ICON_MARGIN
		if(indicators_to_add & SLEEPING_STATUS)
			var/image/indicator = GLOB.potential_indicators[SLEEPING]
			indicator.plane = GAME_PLANE_UPPER_FOV_HIDDEN
			indicator.layer = STATUS_LAYER
			indicator.appearance_flags = PIXEL_SCALE|TILE_BOUND|NO_CLIENT_COLOR|RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM|KEEP_APART
			indicator.pixel_y = y_offset
			indicator.pixel_x = current_x_position
			overlays_list |= indicator
			current_x_position += STATUS_INDICATOR_ICON_X_SIZE + STATUS_INDICATOR_ICON_MARGIN
		if(indicators_to_add & CONFUSED_STATUS)
			var/image/indicator = GLOB.potential_indicators[CONFUSED]
			indicator.plane = GAME_PLANE_UPPER_FOV_HIDDEN
			indicator.layer = STATUS_LAYER
			indicator.appearance_flags = PIXEL_SCALE|TILE_BOUND|NO_CLIENT_COLOR|RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM|KEEP_APART
			indicator.pixel_y = y_offset
			indicator.pixel_x = current_x_position
			overlays_list |= indicator
			current_x_position += STATUS_INDICATOR_ICON_X_SIZE + STATUS_INDICATOR_ICON_MARGIN
		var/list/overlays_to_remove = GLOB.potential_indicators - indicators_to_add
		my_carbon_mob.overlays |= overlays_list
		// This is a semi-HUD element, in a similar manner as medHUDs, in that they're 'above' everything else in the world,
		// but don't pierce obfuscation layers such as blindness or darkness, unlike actual HUD elements like inventory slots.

		// Adding the margin space every time saves a conditional check on the last iteration,
		// and it won't cause any issues since no more icons will be added, and the var is not used for anything else.

/datum/component/status_indicator/proc/get_icon_scale(livingmob)
	if(!iscarbon(livingmob)) // normal mobs are always 1 for scale - hopefully all borgs and simplemobs get this one
		return DEFAULT_MOB_SCALE
	var/mob/living/carbon/passed_mob = livingmob // we're possibly a player! We have size prefs!
	var/mysize = (passed_mob.dna?.current_body_size ? passed_mob.dna.current_body_size : DEFAULT_MOB_SCALE)
	return mysize

/atom/movable/screen/plane_master/game_world_upper_fov_hidden/status_indicator
	name = "Status Indicator Plane"
	documentation = "Status Indicator Plane"
	plane = GAME_PLANE_UPPER_FOV_HIDDEN
	start_hidden = FALSE

#undef STATUS_INDICATOR_Y_OFFSET
#undef STATUS_INDICATOR_ICON_X_SIZE
#undef STATUS_INDICATOR_ICON_MARGIN
