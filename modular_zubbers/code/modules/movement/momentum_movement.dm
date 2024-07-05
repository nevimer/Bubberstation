#define SPEED_MOD 5
#define PX_OFFSET 16 //half of total px size of sprite
//Cars that drfit
//By Fermi!
//Ported to mob movement for bubberstation!

/mob/living/
	var/vector = list("x" = 0, "y" = 0) //vector math
	var/tile_loc = list("x" = 0, "y" = 0) //x y offset of tile
	var/max_mobacceleration = 5.25
	var/accel_step = 0.3
	var/mobacceleration = 0.4
	var/max_deceleration = 2
	var/max_velocity = 110
	var/movedelay

	//Changes for custom
	var/i_m_acell
	var/i_m_decell
	var/i_boost
	var/i_acell


//Bounce the car off a wall
/mob/living/proc/bounce()
	vector["x"] = -vector["x"]/2
	vector["y"] = -vector["y"]/2
	mobacceleration /= 2

/mob/living/proc/ricochet(x_move, y_move)
	var/speed = calc_speed()
	take_bodypart_damage(speed/10)
	bounce()

/mob/living/proc/move_momentum()


	if(GLOB.Debug2)
		message_admins("Pre_ Tile_loc: [tile_loc["x"]], [tile_loc["y"]] Vector: [vector["x"]],[vector["y"]]")

	var/cached_tile = tile_loc
	tile_loc["x"] += vector["x"]/SPEED_MOD
	tile_loc["y"] += vector["y"]/SPEED_MOD
	//range = -16 to 16
	var/x_move = 0
	if(tile_loc["x"] > PX_OFFSET)
		x_move = round((tile_loc["x"]+PX_OFFSET) / (PX_OFFSET*2), 1)
		tile_loc["x"] = ((tile_loc["x"]+PX_OFFSET) % (PX_OFFSET*2))-PX_OFFSET
	else if(tile_loc["x"] < -PX_OFFSET)
		x_move = round((tile_loc["x"]-PX_OFFSET) / (PX_OFFSET*2), 1)
		tile_loc["x"] = ((tile_loc["x"]-PX_OFFSET) % -(PX_OFFSET*2))+PX_OFFSET



	var/y_move = 0
	if(tile_loc["y"] > PX_OFFSET)
		y_move = round((tile_loc["y"]+PX_OFFSET) / (PX_OFFSET*2), 1)
		tile_loc["y"] = ((tile_loc["y"]+PX_OFFSET) % (PX_OFFSET*2))-PX_OFFSET
	else if(tile_loc["y"] < -PX_OFFSET)
		y_move = round((tile_loc["y"]-PX_OFFSET) / (PX_OFFSET*2), 1)
		tile_loc["y"] = ((tile_loc["y"]-PX_OFFSET) % -(PX_OFFSET*2))+PX_OFFSET

	if(!(x_move == 0 && y_move == 0))
		var/turf/T = get_offset_target_turf(src, x_move, y_move)
		for(var/atom/A in T.contents)
			Bump(A)
			if(A.density)
				ricochet()
				tile_loc = cached_tile
				return FALSE
		if(T.density)
			ricochet()
			tile_loc = cached_tile
			return FALSE

	x += x_move
	y += y_move
	pixel_x = round(tile_loc["x"], 1)
	pixel_y = round(tile_loc["y"], 1)



	if(GLOB.Debug2)
		message_admins("Post TileLoc:[tile_loc["x"]], [tile_loc["y"]] Movement: [x_move],[y_move]")
		message_admins("Pix:[pixel_x],[pixel_y] TileLoc:[tile_loc["x"]], [tile_loc["y"]]. [round(tile_loc["x"])], [round(tile_loc["y"])]")
	//no tile movement

	if(x_move == 0 && y_move == 0)
		return FALSE

//
/mob/living/Bump(atom/M)
	var/speed = calc_speed()
	if(isliving(M))
		var/mob/living/C = M
		if(!C.anchored)
			var/atom/throw_target = get_edge_target_turf(C, calc_angle())
			C.throw_at(throw_target, 10, 14)
		to_chat(C, "<span class='warning'><b>You ran into by [src]!</b></span>")
		to_chat(src, "<span class='warning'><b>You just ran into [C] you crazy lunatic!</b></span>")
		C.take_bodypart_damage(speed/10)
	//playsound
	return ..()

//////////////////////////////////////////////////////////////
//					Calc procs						    	//
//////////////////////////////////////////////////////////////
/*Calc_step_angle calculates angle based off pixel x,y movement (x,y in)
Calc angle calcus angle based off vectors
calc_speed() returns the highest var of x or y relative
calc accel calculates the mobacceleration to be added to vector
calc vector updates the internal vector
friction reduces the vector by an ammount to both axis*/

//How fast the car is going atm
/mob/living/proc/calc_velocity()
	var/speed = calc_speed()
	switch(speed)
		if(-INFINITY to 10)
			movedelay = 5
			inertia_move_delay = 5
		if(10 to 20)
			movedelay = 4
			inertia_move_delay = 4
		if(20 to 35)
			movedelay = 3
			inertia_move_delay = 3
		if(35 to 60)
			movedelay = 2
			inertia_move_delay = 2
		if(60 to 90)
			movedelay = 1
			inertia_move_delay = 1
		if(90 to INFINITY)
			movedelay = 0
			inertia_move_delay = 0
	return

/mob/living/proc/calc_step_angle(x, y)
	if((sqrt(x**2))>1 || (sqrt(y**2))>1) //Too large a movement for a step
		return FALSE
	if(x == 1)
		if (y == 1)
			return NORTHEAST
		else if (y == -1)
			return SOUTHEAST
		else if (y == 0)
			return EAST
		else
			message_admins("something went wrong; y = [y]")
	else if (x == -1)
		if (y == 1)
			return NORTHWEST
		else if (y == -1)
			return SOUTHWEST
		else if (y == 0)
			return WEST
		else
			message_admins("something went wrong; y = [y]")
	else if (x != 0)
		message_admins("something went wrong; x = [x]")

	if (y == 1)
		return NORTH
	else if (y == -1)
		return SOUTH
	else if (x != 0)
		message_admins("something went wrong; y = [y]")
	return FALSE

//Returns the angle to move towards
/mob/living/proc/calc_angle()
	var/x = round(vector["x"], 1)
	var/y = round(vector["y"], 1)
	if(y == 0)
		if(x > 0)
			return EAST
		else if(x < 0)
			return WEST
	if(x == 0)
		if(y > 0)
			return NORTH
		else if(y < 0)
			return SOUTH
	if(x == 0 || y == 0)
		return FALSE
	var/angle = (ATAN2(x,y))

	if(angle > 0)
		switch(angle)
			if(0 to 22)
				return EAST
			if(22 to 67)
				return NORTHEAST
			if(67 to 112)
				return NORTH
			if(112 to 157)
				return NORTHWEST
			if(157 to 180)
				return WEST
/* 	else
		switch(angle)
			if(0 to -22)
				return EAST
			if(-22 to -67)
				return SOUTHEAST
			if(-67 to -112)
				return SOUTH
			if(-112 to -157)
				return SOUTHWEST
			if(-157 to -180)
				return WEST */


//updates the internal speed of the car (used for crashing)
/mob/living/proc/calc_speed()
	var/speed = max(sqrt((vector["x"]**2)), sqrt((vector["y"]**2)))
	return speed


//Calculates the mobacceleration
/mob/living/proc/calc_mobacceleration() //Make speed 0 - 100 regardless of gear here
	mobacceleration += accel_step
	mobacceleration = clamp(mobacceleration, initial(mobacceleration), max_mobacceleration)
	return


//calulate the vector change
/mob/living/proc/calc_vector(direction)
/* 	if(SEND_SIGNAL(driver, COMSIG_COMBAT_MODE_CHECK, COMBAT_MODE_ACTIVE))//clutch is on
		return FALSE */
	var/cached_mobacceleration = mobacceleration

	var/result_vector = vector
	switch(direction)
		if(NORTH)
			result_vector["y"] += cached_mobacceleration
		if(NORTHEAST)
			result_vector["x"] += cached_mobacceleration/1.4
			result_vector["y"] += cached_mobacceleration/1.4
		if(EAST)
			result_vector["x"] += cached_mobacceleration
		if(SOUTHEAST)
			result_vector["x"] += cached_mobacceleration/1.4
			result_vector["y"] -= cached_mobacceleration/1.4
		if(SOUTH)
			result_vector["y"] -= cached_mobacceleration
		if(SOUTHWEST)
			result_vector["x"] -= cached_mobacceleration/1.4
			result_vector["y"] -= cached_mobacceleration/1.4
		if(WEST)
			result_vector["x"] -= cached_mobacceleration
		if(NORTHWEST)
			result_vector["y"] += cached_mobacceleration/1.4
			result_vector["x"] -= cached_mobacceleration/1.4

	vector["x"] = clamp(result_vector["x"], -max_velocity, max_velocity)
	vector["y"] = clamp(result_vector["y"], -max_velocity, max_velocity)

	if(vector["x"] > max_velocity || vector["x"] < -max_velocity)
		vector["x"] = vector["x"] - (vector["x"]/10)
		vector["x"] = clamp(vector["x"], -250, 250)
	if(vector["y"] > max_velocity || vector["y"] < -max_velocity)
		vector["y"] = vector["y"] - (vector["y"]/10)
		vector["y"] = clamp(vector["y"], -250, 250)

	return

//Reduces speed
/mob/living/proc/friction(change, sfx = FALSE)
	//decell X
	if(vector["x"] == 0 && vector["y"] == 0)
		return
	if(vector["x"] <= -change)
		vector["x"] += change
	else if(vector["x"] >= change)
		vector["x"] -= change
	else
		vector["x"] = 0
	//decell Y
	if(vector["y"] <= -change)
		vector["y"] += change
	else if(vector["y"] >= change)
		vector["y"] -= change
	else
		vector["y"] = 0

/* 	if(sfx)
		playsound(src.loc, 'modular_skyrat/master_files/sound/vehicles/skid.ogg', 50, 0)
 */
