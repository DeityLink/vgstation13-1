
/*

/turf/unsimulated/wall/bloodrealm
/turf/unsimulated/floor/bloodrealm

*/

var/list/bloodturf_cache = list()
var/list/bloodturf_masks = list("center","north","south","east","west","northeast","northwest","southeast","southwest")

/turf/unsimulated/wall/bloodrealm
	name = "blood clot"
	desc = "something vile and unnatural exudes from this wall."
	icon = 'icons/turf/bloodrealm.dmi'
	icon_state = "wall"
	opacity = 1
	density = 1
	explosion_block = 1
	blocks_air = 1
	holomap_draw_override = HOLOMAP_DRAW_FULL
	var/maxHealth = 100
	var/health = 100
	var/healing_rate = 2
	var/image/damage_overlay = null
	var/list/possible_wounds = list("blood_1","blood_2","blood_3","blood_4","blood_5")
	var/list/acquired_wounds = list()

/turf/unsimulated/floor/bloodrealm
	name = "greasy floor"
	icon = 'icons/turf/bloodrealm.dmi'
	icon_state = "floor"
	plane = TURF_PLANE
	holomap_draw_override = HOLOMAP_DRAW_PATH

///////OH BOY HERE WE GO//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Called on Blood Dimension turfs to
/turf/proc/bloodcarve(var/new_level)
	if (!bloodZ || z != bloodZ)
		return
	if (new_level <= bloodcarved)
		return
	bloodcarved = new_level

	var/paint = "#B65127"

	switch (bloodcarved)
		if (1)
			paint = "#B65127"
		if (2)
			paint = "#B67C27"
		if (3)
			paint = "#C49215"

	var/icon/canvas = extraMiniMaps[HOLOMAP_EXTRA_BLOODMAP]

	if(map.holomap_offset_x.len >= map.zMainStation)
		canvas.DrawBox(paint, min(x+map.holomap_offset_x[map.zMainStation],((2 * world.view + 1)*WORLD_ICON_SIZE)), min(y+map.holomap_offset_y[map.zMainStation],((2 * world.view + 1)*WORLD_ICON_SIZE)))
	else
		canvas.DrawBox(paint, x, y)


/turf/unsimulated/floor/bloodrealm/initialize()
	..()
	//we're carving a new floor
	var/list/turfs_to_adjust = list()
	var/adjacent_walls = 0
	var/adjacent_clots = 0
	for (var/direction in cardinal)
		turfs_to_adjust += get_step(src, direction)

	for (var/turf/T in turfs_to_adjust)
		//starting by removing the corners on adjacent floors
		if (istype(T,/turf/unsimulated/floor/bloodrealm))
			switch(get_dir(src, T))
				if (NORTH)
					T.overlays -= "corner_clot_southeast"
					T.overlays -= "corner_clot_southwest"
					T.overlays -= "corner_rib_southeast"
					T.overlays -= "corner_rib_southwest"
				if (SOUTH)
					T.overlays -= "corner_clot_northeast"
					T.overlays -= "corner_clot_northwest"
					T.overlays -= "corner_rib_northeast"
					T.overlays -= "corner_rib_northwest"
				if (EAST)
					T.overlays -= "corner_clot_northwest"
					T.overlays -= "corner_clot_southwest"
					T.overlays -= "corner_rib_northwest"
					T.overlays -= "corner_rib_southwest"
				if (WEST)
					T.overlays -= "corner_clot_northeast"
					T.overlays -= "corner_clot_southeast"
					T.overlays -= "corner_rib_northeast"
					T.overlays -= "corner_rib_southeast"
		//then removing adjacent corner ribs on adjacent walls, while also noting down which sides have walls
		else if (istype(T,/turf/unsimulated/wall/bloodrealm))
			switch(get_dir(T, src))
				if (NORTH)
					adjacent_walls |= SOUTH
					if (T.denomination == "clot")
						adjacent_clots |= SOUTH
					else
						T.overlays -= "rib_northeast"
						T.overlays -= "rib_northwest"
				if (SOUTH)
					adjacent_walls |= NORTH
					if (T.denomination == "clot")
						adjacent_clots |= NORTH
					else
						T.overlays -= "rib_southeast"
						T.overlays -= "rib_southwest"
				if (EAST)
					adjacent_walls |= WEST
					if (T.denomination == "clot")
						adjacent_clots |= WEST
					else
						T.overlays -= "rib_northeast"
						T.overlays -= "rib_southeast"
				if (WEST)
					adjacent_walls |= EAST
					if (T.denomination == "clot")
						adjacent_clots |= EAST
					else
						T.overlays -= "rib_northwest"
						T.overlays -= "rib_southwest"

	//rounding corners. clot walls get priority (red corners).
	if ((adjacent_walls & NORTH) && (adjacent_walls & EAST))
		if (adjacent_clots & (NORTH|EAST))
			overlays += "corner_clot_northeast"
		else
			overlays += "corner_rib_northeast"
	if ((adjacent_walls & NORTH) && (adjacent_walls & WEST))
		if (adjacent_clots & (NORTH|WEST))
			overlays += "corner_clot_northwest"
		else
			overlays += "corner_rib_northwest"
	if ((adjacent_walls & SOUTH) && (adjacent_walls & EAST))
		if (adjacent_clots & (SOUTH|EAST))
			overlays += "corner_clot_southeast"
		else
			overlays += "corner_rib_southeast"
	if ((adjacent_walls & SOUTH) && (adjacent_walls & WEST))
		if (adjacent_clots & (SOUTH|WEST))
			overlays += "corner_clot_southwest"
		else
			overlays += "corner_rib_southwest"

/turf/unsimulated/floor/bloodrealm/Entered(atom/A, atom/OL)
	//enabling bloody footprints
	blood_tracks_and_tripping(A)
	..()

/turf/proc/cicatrize()

/turf/unsimulated/floor/bloodrealm/wound
	name = "wounded floor"
	desc = "It appears to be slowly healing"
	icon_state = "floor_clot"
	var/countdown_to_healing = 50

/turf/unsimulated/floor/bloodrealm/wound/initialize()
	..()
	processing_objects.Add(src)

/turf/unsimulated/floor/bloodrealm/wound/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = 0, var/allow = 1)
	processing_objects.Remove(src)
	..()

/turf/unsimulated/floor/bloodrealm/wound/process()
	countdown_to_healing--
	if (countdown_to_healing <= 0)
		processing_objects.Remove(src)
		ChangeTurf(/turf/unsimulated/wall/bloodrealm/wound)
		cicatrize()

/turf/unsimulated/floor/bloodrealm/wound/cicatrize()
	if (denomination == "membrane")
		icon_state = "floor_membrane"
		name = "viscous floor"
		countdown_to_healing = 10
		blood_splatter(src,null,TRUE,"#9D7300")
	else
		denomination = "clot"
		blood_splatter(src,null,TRUE,"#6D0000")

/turf/unsimulated/wall/bloodrealm/wound/cicatrize()
	if (denomination == "rib")
		denomination = "clot"
	playsound(src, "sound/effects/squelch1.ogg", 50, 1)
	for (var/obj/effect/decal/cleanable/C in src)
		qdel(C)
	for (var/direction in alldirs)
		var/turf/T = get_step(src, direction)
		if (istype(T, /turf/unsimulated/wall/bloodrealm))
			var/turf/unsimulated/wall/bloodrealm/W = T
			W.remove_ribs(src)
		if (istype(T, /turf/unsimulated/floor/bloodrealm))
			apply_ribs(T)
	overlays += "[denomination]_scar"
	switch(denomination)
		if ("clot")
			maxHealth = 50
			health = 50
		if ("membrane")
			maxHealth = 25
			health = 25
			icon_state = "membrane"
			name = "membrane"
			opacity = 0
			possible_wounds = list("pus_1","pus_2","pus_3","pus_4","pus_5")
	take_damage(maxHealth-2, null, 0)

/turf/unsimulated/floor/bloodrealm/wound/Entered(atom/A, atom/OL)
	//stuff passing through the wounds slows down its healing
	countdown_to_healing++
	..()

/atom/proc/blood_dimension_radius(transformRadius = 1, approxRadius = 1, paintRadius = 1)
	//mirrors tiles in a radius on the station into the blood dimension
	if (z != map.zMainStation || !bloodZ)
		return
	var/turf/T = locate(x,y,z)
	if (!T)
		return
	var/list/tiles_to_carve = list()
	var/list/tiles_to_mirror = list()
	for (var/i = (-1 * transformRadius) to transformRadius)
		for (var/j = (-1 * transformRadius) to transformRadius)
			var/dist = cheap_pythag(i,j)
			if (dist <= transformRadius)
				if (dist <= approxRadius || prob(50))
					if (dist <= paintRadius)
						tiles_to_mirror |= list(list(i+T.x,j+T.y))
					else
						tiles_to_carve |= list(list(i+T.x,j+T.y))
	spawn()
		while(tiles_to_mirror.len)
			var/tile_to_mirror = pick(tiles_to_mirror)
			tiles_to_mirror -= list(tile_to_mirror)
			blood_dimension_coordinates(tile_to_mirror[1], tile_to_mirror[2], TRUE)
			sleep(1)
		while(tiles_to_carve.len)
			var/tile_to_carve = pick(tiles_to_carve)
			tiles_to_carve -= list(tile_to_carve)
			blood_dimension_coordinates(tile_to_carve[1], tile_to_carve[2], FALSE)
			sleep(1)

/proc/blood_dimension_coordinates(var/targetX, var/targetY, var/paintFloor)
	//mirrors the station tile at the given coordinates into the blood dimension
	var/turf/T = locate(targetX,targetY,map.zMainStation)
	if (T)
		T.blood_dimension_shape(paint = paintFloor)

/turf/proc/blood_dimension_walltype(var/type = "clot")
	return

/turf/unsimulated/wall/bloodrealm/blood_dimension_walltype(var/type = "clot")
	switch(type)
		if ("rib")
			denomination = "rib"
			name = "meaty wall"
			maxHealth = 200
			health = 200
		if ("scab")
			denomination = "scab"
			name = "obsidian scabs"
			icon_state = "obsidian"
			maxHealth = 800
			health = 800
		if ("membrane")
			denomination = "membrane"
			name = "membrane"
			icon_state = "membrane"
			maxHealth = 50
			health = 50
			possible_wounds = list("pus_1","pus_2","pus_3","pus_4","pus_5")

/turf/proc/blood_dimension_shape(var/dress = TRUE, var/paint = TRUE)
	//mirrors this specific tile into the blood dimension
	if (z != map.zMainStation || !bloodZ)
		return//we only mirror station tiles
	var/turf/T = locate(x,y,bloodZ)
	if (T.bloodcarved)
		return//already mirrored
	T.bloodcarve(1)
	blood_dimension_expand(T)
	. = T

/turf/proc/blood_dimension_expand(var/turf/T)
	for (var/turf/U in range(1,T))
		if (istype(U.loc,/area/narsie))
			continue
		U.set_area(/area/narsie)//enables dynamic lighting
		var/turf/R = locate(U.x,U.y,map.zMainStation)
		if (istype (R.loc, /area/shuttle))
			U.blood_dimension_walltype("scab")
		else if (istype(R, /turf/unsimulated/wall/) || istype(R, /turf/simulated/wall/))
			U.blood_dimension_walltype("rib")
		else if (istype(R, /turf/space))
			U.blood_dimension_walltype("scab")
		for (var/obj/structure/grille/G in R)
			U.blood_dimension_walltype("membrane")
			break

/turf/unsimulated/wall/blood_dimension_shape(var/dress = TRUE, var/paint = TRUE)
	. = ..()
	if (. && dress)
		var/turf/T = .
		T.blood_dimension_dress()

/turf/simulated/wall/blood_dimension_shape(var/dress = TRUE, var/paint = TRUE)
	. = ..()
	if (. && dress)
		var/turf/T = .
		T.blood_dimension_dress()

/turf/unsimulated/floor/blood_dimension_shape(var/dress = TRUE, var/paint = TRUE)
	. = ..()
	if (. && !istype(loc, /area/shuttle))
		var/turf/T = .
		T.blood_dimension_carve(dress,paint)

/turf/simulated/floor/blood_dimension_shape(var/dress = TRUE, var/paint = TRUE)
	. = ..()
	if (. && !istype(loc, /area/shuttle))
		var/turf/T = .
		T.blood_dimension_carve(dress,paint)

/turf/proc/blood_dimension_carve(var/dress = TRUE, var/paint = TRUE, var/turf_type = /turf/unsimulated/floor/bloodrealm)
	if (dress && (denomination == "membrane"))
		opacity = 0
		blood_dimension_dress()
		return
	ChangeTurf(turf_type)
	for (var/turf/unsimulated/wall/bloodrealm/W in range(1,src))
		W.apply_ribs(src)
	if (dress)
		blood_dimension_dress(paint)

/turf/unsimulated/wall/bloodrealm/wound/blood_dimension_carve(var/dress = TRUE, var/paint = TRUE, var/turf_type = /turf/unsimulated/floor/bloodrealm)
	ChangeTurf(/turf/unsimulated/floor/bloodrealm/wound)
	for (var/turf/unsimulated/wall/bloodrealm/W in range(1,src))
		W.apply_ribs(src)

/turf/proc/apply_ribs()
	return

/turf/proc/remove_ribs()
	return

/turf/unsimulated/wall/bloodrealm/apply_ribs(var/turf/T)
	switch(get_dir(src, T))
		if (NORTH)
			overlays += "[denomination]_north"
		if (SOUTH)
			overlays += "[denomination]_south"
		if (EAST)
			overlays += "[denomination]_east"
		if (WEST)
			overlays += "[denomination]_west"
		if (NORTHEAST)
			overlays += "[denomination]_northeast"
		if (NORTHWEST)
			overlays += "[denomination]_northwest"
		if (SOUTHEAST)
			overlays += "[denomination]_southeast"
		if (SOUTHWEST)
			overlays += "[denomination]_southwest"

/turf/unsimulated/wall/bloodrealm/remove_ribs(var/turf/T)
	switch(get_dir(src, T))
		if (NORTH)
			overlays -= "[denomination]_north"
		if (SOUTH)
			overlays -= "[denomination]_south"
		if (EAST)
			overlays -= "[denomination]_east"
		if (WEST)
			overlays -= "[denomination]_west"
		if (NORTHEAST)
			overlays -= "[denomination]_northeast"
		if (NORTHWEST)
			overlays -= "[denomination]_northwest"
		if (SOUTHEAST)
			overlays -= "[denomination]_southeast"
		if (SOUTHWEST)
			overlays -= "[denomination]_southwest"

/turf/unsimulated/wall/bloodrealm/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = 0, var/allow = 1)
	overlays.len = 0
	processing_objects.Remove(src)
	..()

/turf/unsimulated/wall/bloodrealm/process()
	healing(healing_rate)

/turf/unsimulated/wall/bloodrealm/proc/healing(var/rate)
	var/next_threshold = 0
	while (next_threshold < health)
		next_threshold += maxHealth/5

	if (!damage_overlay)
		damage_overlay = image('icons/turf/bloodrealm.dmi',src,"blank")

	overlays -= damage_overlay

	health += rate

	while (health > next_threshold && acquired_wounds.len)
		var/new_wound = pick(acquired_wounds)
		acquired_wounds -= new_wound
		possible_wounds += new_wound
		damage_overlay.overlays -= new_wound
		next_threshold += maxHealth/5

	if (health >= maxHealth)
		health = maxHealth
		processing_objects.Remove(src)
		return

	overlays += damage_overlay


/turf/proc/blood_dimension_dress(var/doPaint = TRUE)
	return

/turf/unsimulated/wall/bloodrealm/blood_dimension_dress(var/doPaint = TRUE)
	if (bloodcarved != 1)
		return
	var/turf/source = locate(x,y,map.zMainStation)

	for (var/obj/A in source)
		A.blood_dimension_copy(src)

	bloodcarve(2)

/turf/unsimulated/floor/bloodrealm/blood_dimension_dress(var/doPaint = TRUE)
	if (bloodcarved != 1)
		return
	var/turf/source = locate(x,y,map.zMainStation)

	var/source_key = "[source.icon]_[source.icon_state]_[source.dir]"
	if (!(source_key in bloodturf_cache))
		var/icon/I = icon(source.icon,source.icon_state,source.dir)
		var/list/icon_parts = list()
		for(var/direc in bloodturf_masks)
			var/icon/J = icon('icons/turf/bloodrealm.dmi',"mask_[direc]")
			J.Blend(I,ICON_MULTIPLY)
			icon_parts["[direc]"] = J
		bloodturf_cache[source_key] = icon_parts
	turf_icon_parts = bloodturf_cache[source_key]

	for (var/obj/A in source)
		A.blood_dimension_copy(src)

	bloodcarve(2)

	if (doPaint)
		blood_dimension_paint()


//////////////////////////////////////////////////////////////////////


/turf/proc/blood_dimension_paint()
	if (bloodcarved != 2)
		return

	overlays += turf_icon_parts["center"]

	bloodcarve(3)

	var/ok_dir = 0
	for (var/direc in cardinal)
		var/turf/T = get_step(src,direc)
		if (T.bloodcarved == 3)
			overlays += turf_icon_parts[dir2text(direc)]
			T.overlays += T.turf_icon_parts[dir2text(GetOppositeDir(direc))]
			ok_dir |= direc

	for (var/direc in diagonal)
		switch(direc)
			if(SOUTHWEST)
				if (!(ok_dir & SOUTH) || !(ok_dir & WEST))
					continue
			if(NORTHWEST)
				if (!(ok_dir & NORTH) || !(ok_dir & WEST))
					continue
			if(NORTHEAST)
				if (!(ok_dir & NORTH) || !(ok_dir & EAST))
					continue
			if(SOUTHEAST)
				if (!(ok_dir & SOUTH) || !(ok_dir & EAST))
					continue
		var/turf/T = get_step(src,direc)
		if (T.bloodcarved == 3)
			overlays += turf_icon_parts[dir2text(direc)]
			T.overlays += T.turf_icon_parts[dir2text(GetOppositeDir(direc))]
			switch(direc)
				if(SOUTHWEST)
					var/turf/U = get_step(src,SOUTH)
					var/turf/R = get_step(src,WEST)
					U.overlays += U.turf_icon_parts["northwest"]
					R.overlays += R.turf_icon_parts["southeast"]
				if(NORTHWEST)
					var/turf/U = get_step(src,NORTH)
					var/turf/R = get_step(src,WEST)
					U.overlays += U.turf_icon_parts["southwest"]
					R.overlays += R.turf_icon_parts["northeast"]
				if(NORTHEAST)
					var/turf/U = get_step(src,NORTH)
					var/turf/R = get_step(src,EAST)
					U.overlays += U.turf_icon_parts["southeast"]
					R.overlays += R.turf_icon_parts["northwest"]
				if(SOUTHEAST)
					var/turf/U = get_step(src,SOUTH)
					var/turf/R = get_step(src,EAST)
					U.overlays += U.turf_icon_parts["northeast"]
					R.overlays += R.turf_icon_parts["southwest"]

////////WAYS TO BREAK THEM WALLS

/turf/unsimulated/wall/bloodrealm/proc/take_damage(var/damage = 0,var/mob/user,var/hitsound = get_sfx("machete_hit"))
	if (!damage)
		return

	if (!damage_overlay)
		damage_overlay = image(icon,src,"blank")

	if (damage < 5)
		if (user)
			to_chat(user, "\the [src] endures the hit.")
		return

	if (health >= maxHealth)
		processing_objects.Add(src)

	if(hitsound)
		playsound(src, hitsound, 20, 1)

	var/next_threshold = maxHealth
	while (next_threshold > health)
		next_threshold -= maxHealth/5

	overlays -= damage_overlay

	health -= damage

	if (health <= 0)
		playsound(src, "sound/effects/blobsplat.ogg", 50, 1)
		anim(target = src, a_icon = icon, flick_anim = "[denomination]_break", sleeptime = 10, plane = src.plane, lay = layer+0.3)
		bloodcarve(1)
		blood_dimension_expand(src)
		carve()
	else
		while (health < next_threshold && possible_wounds.len)
			var/new_wound = pick(possible_wounds)
			possible_wounds -= new_wound
			acquired_wounds += new_wound
			damage_overlay.overlays += new_wound
			next_threshold -= maxHealth/5
		overlays += damage_overlay

/turf/unsimulated/wall/bloodrealm/proc/carve()
	if (denomination == "rib" || denomination == "membrane")
		blood_dimension_carve(FALSE, FALSE, /turf/unsimulated/floor/bloodrealm/wound)
		cicatrize()
	else
		blood_dimension_carve(FALSE, FALSE)

/turf/unsimulated/wall/bloodrealm/wound/carve()
	blood_dimension_carve(FALSE, FALSE, /turf/unsimulated/floor/bloodrealm/wound)
	cicatrize()

//hit by held items
/turf/unsimulated/wall/bloodrealm/attackby(var/obj/item/weapon/W, var/mob/living/user)
	user.delayNextAttack(8)
	var/dam = W.force
	if(W.sharpness_flags & SHARP_TIP)
		dam *= 1.1
	if(W.sharpness_flags & SHARP_BLADE)
		dam *= 1.5
	if(W.sharpness_flags & SERRATED_BLADE)
		dam *= 2
	if(dam)
		user.do_attack_animation(src, W)
		user.visible_message("<span class='danger'>\The [user] [pick(W.attack_verb)] \the [src] with \the [W].</span>")
	take_damage(dam,user)
	..()

//explosions
/turf/unsimulated/wall/bloodrealm/ex_act(severity)
	switch(severity)
		if(1)
			take_damage(rand(200, 300),null, 0)
		if(2)
			take_damage(rand(50, 150),null, 0)
		if(3)
			take_damage(rand(5, 50),null, 0)

//hit by bullets
/turf/unsimulated/wall/bloodrealm/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)
		return
	take_damage(Proj.damage, Proj.firer)
	return ..()

//hit by thrown items
/turf/unsimulated/wall/bloodrealm/hitby(var/atom/movable/AM,var/speed = 5)
	if(isitem(AM))
		var/obj/item/I = AM
		take_damage(I.throwforce*speed/5)

//slashed by simple_animals
/turf/unsimulated/wall/bloodrealm/attack_animal(var/mob/living/simple_animal/user)
	user.delayNextAttack(8)
	user.do_attack_animation(src, user)
	take_damage(user.get_unarmed_damage(src),user, user.get_unarmed_hit_sound())

//slashed (touched?) by humans
/turf/unsimulated/wall/bloodrealm/attack_hand(var/mob/living/carbon/human/user)
	if (user.a_intent == I_HURT)
		user.delayNextAttack(8)
		user.do_attack_animation(src, user)
		var/datum/species/S = user.get_organ_species(user.get_active_hand_organ())
		user.visible_message("<span class='danger'>\The [user] [S.attack_verb] \the [src].</span>")
		take_damage(user.get_unarmed_damage(src),user, user.get_unarmed_hit_sound())

//slashed (touched?) by monkeys
/turf/unsimulated/wall/bloodrealm/attack_paw(var/mob/living/carbon/monkey/user)
	if (user.a_intent == I_HURT)
		if(user.wear_mask?.is_muzzle)
			to_chat(user, "<span class='notice'>You can't do this with \the [user.wear_mask] on!</span>")
			return
		user.delayNextAttack(8)
		user.do_attack_animation(src, user)
		take_damage(user.get_unarmed_damage(src),user, user.get_unarmed_hit_sound())

//slashed by aliums
/turf/unsimulated/wall/bloodrealm/attack_alien(var/mob/living/carbon/alien/humanoid/user)
	if(istype(user, /mob/living/carbon/alien/larva))
		return
	user.delayNextAttack(8)
	user.do_attack_animation(src, user)
	var/alienverb = pick(list("slam", "rip", "claw"))
	user.visible_message("<span class='warning'>[user] [alienverb]s \the [src].</span>", \
						 "<span class='warning'>You [alienverb] \the [src].</span>", \
						 "You hear ripping flesh.")
	take_damage(rand(15,30),user)

