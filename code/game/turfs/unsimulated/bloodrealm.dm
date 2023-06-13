///////TURFS

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

////////DOODADS

/obj/blood_dimension_object
	name = "object"
	desc = ""
	icon = 'icons/turf/bloodrealm.dmi'
	icon_state = ""

/obj/machinery/blood_dimension_machine
	name = "object"
	desc = ""
	icon = 'icons/turf/bloodrealm.dmi'
	icon_state = ""
	machine_flags = WRENCHMOVE

///////OH BOY HERE WE CGO

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


//gives objects a "greasy" look
/obj/proc/greasify()
	if (greased_up)
		return
	greased_up = image('icons/turf/bloodrealm.dmi',src,"grease2")
	greased_up.blend_mode = BLEND_INSET_OVERLAY
	appearance_flags |= KEEP_TOGETHER
	overlays += greased_up

var/list/bloodturf_cache = list()
var/list/bloodturf_masks = list("center","north","south","east","west","northeast","northwest","southeast","southwest")

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

//////////////////////////////////////////////////////////////////////TODO, move those to their proper files

/obj/proc/blood_dimension_copy(var/turf/T)
	blood_copied = 1

/obj/structure/table/blood_dimension_copy(var/turf/T)
	if (blood_copied)
		return
	var/obj/structure/table/woodentable/WT = new (T)
	WT.greasify()
	blood_copied = 1

/obj/structure/bed/chair/wood/pew/blood_dimension_copy(var/turf/T)
	if (blood_copied)
		return
	var/obj/structure/bed/chair/wood/pew/C = new (T)
	C.dir = dir
	C.icon_state = icon_state
	C.greasify()
	blood_copied = 1

/obj/structure/bed/chair/blood_dimension_copy(var/turf/T)
	if (blood_copied)
		return
	var/obj/structure/bed/chair/wood/throne/C = new (T)
	C.dir = dir
	C.greasify()
	blood_copied = 1

/obj/structure/sign/double/barsign/blood_dimension_copy(var/turf/T)
	if (blood_copied)
		return
	var/obj/O = turn_into_blood_dimension_object(T)
	O.icon_state = "narsiebistro"
	O.light_range = 3
	O.light_color = "#FF3F3F"
	O.set_light(3)
	blood_copied = 1

/obj/structure/sign/blood_dimension_copy(var/turf/T)
	if (blood_copied)
		return
	var/obj/structure/sign/S = new (T)
	S.icon = icon
	S.icon_state = icon_state
	S.name = "unreadable sign"
	S.pixel_x = pixel_x
	S.pixel_y = pixel_y
	S.greasify()
	blood_copied = 1

/obj/machinery/atmospherics/unary/vent_pump/blood_dimension_copy(var/turf/T)
	if (blood_copied)
		return
	var/obj/O = turn_into_blood_dimension_object(T)
	O.icon_state = "base"
	O.name = "rusty vent"
	blood_copied = 1

/obj/machinery/atmospherics/unary/vent_scrubber/blood_dimension_copy(var/turf/T)
	if (blood_copied)
		return
	var/obj/O = turn_into_blood_dimension_object(T)
	O.icon_state = "hoff"
	O.name = "rusty scrubber"
	blood_copied = 1

/obj/machinery/light/small/blood_dimension_copy(var/turf/T)
	if (blood_copied)
		return
	var/obj/machinery/light/small/O = new (T)
	O.dir = dir
	O.greasify()
	if (prob(50))
		O.broken(1)
	else
		O.fix()
		O.light_power = 0.7
		O.light_range = 2.5
		O.light_color = "#FFE67F"
		O.set_light(2.5)
	blood_copied = 1

/obj/machinery/light/blood_dimension_copy(var/turf/T)
	if (blood_copied)
		return
	var/obj/machinery/light/O = new (T)
	O.dir = dir
	O.greasify()
	if (prob(20))
		O.broken(1)
	else
		O.fix()
		O.light_power = 1
		O.light_range = 3.5
		O.light_color = "#FFE67F"
		O.set_light(3.5)
	blood_copied = 1

/obj/machinery/computer/blood_dimension_copy(var/turf/T)
	if (blood_copied)
		return
	var/obj/O = turn_into_blood_dimension_machine(T)
	O.icon_state = initial(icon_state)
	O.icon_state += "0"
	blood_copied = 1

/obj/machinery/vending/blood_dimension_copy(var/turf/T)
	if (blood_copied)
		return
	var/obj/O = turn_into_blood_dimension_machine(T)
	O.icon_state = initial(icon_state)
	O.icon_state += "-broken"
	blood_copied = 1

//////////////////////////////////////////////////////////////////////

/obj/proc/turn_into_blood_dimension_object(var/turf/T)
	var/obj/blood_dimension_object/O = new (T)
	O.name = name
	O.desc = desc
	O.density = density
	O.anchored = anchored
	O.plane = plane
	O.layer = layer
	O.icon = icon
	O.icon_state = icon_state
	O.pixel_x = pixel_x
	O.pixel_y = pixel_y
	O.dir = dir
	O.greasify()
	return O

/obj/proc/turn_into_blood_dimension_machine(var/turf/T)
	var/obj/machinery/blood_dimension_machine/O = new (T)
	O.name = name
	O.desc = desc
	O.density = density
	O.anchored = anchored
	O.plane = plane
	O.layer = layer
	O.icon = icon
	O.icon_state = icon_state
	O.pixel_x = pixel_x
	O.pixel_y = pixel_y
	O.dir = dir
	O.greasify()
	return O

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

//////////////////////////////////////////////////////////////////////////////////////

/datum/meat_blob
	var/list/blob_tiles = list()
	var/obj/meat_blob/center_blob = null	//there's no "core" but this is an arbitrary tile whose coordinates are fairly close to the center
	var/obj/meat_blob/previous_center = null
	var/initial_size = 10	//How many blob tiles are compacted inside the core. Will spread out given the chance.
	var/mass_to_move = 0	//Some buffer to move around by contracting/expanding
	var/average_x = 0
	var/average_y = 0
	var/turf/target_tile = null
	var/turf/target_dist = 0
	var/turf/target_dir = 0
	var/blobZ = 1

	var/target_modifier = 1
	var/group_modifier = 2
	var/block_modifier = -1
	var/side_modifier = 1

	var/list/high_scorers = list()
	var/list/low_scorers = list()
	var/list/low_scorers_necessary = list()
	var/necessary_count = 0

	var/timestopped = 0//TODO

	var/update_speed = 5//lower = faster, don't set below 1

	var/stuck_count = 0
	var/stuck_critical = 10
	var/mode_change_threshold = 0
	var/list/integrity_check = list()

	var/state = "idle"//TODO: Replace with defines

/obj/meat_blob
	name = "meat blob"
	desc = "It looks fairly harmless, maybe tasty even."
	icon = 'icons/mob/meatblob.dmi'
	icon_state = "blob"
	anchored = 1
	density = 1
	layer = BLOB_BASE_LAYER
	plane = BLOB_PLANE

	health = 100
	maxHealth = 100

	var/datum/meat_blob/blob_datum = null
	var/existence_score = 0
	var/created_when = 0
	var/last_attack = 0

	var/target_score = 0
	var/group_score = 0
	var/block_score = 0
	var/side_score = 0
	var/score = 0

	var/list/available_directions = list()
	var/list/connection_directions = list()

/obj/meat_blob/New(turf/loc)
	..()
	created_when = world.time

/obj/meat_blob/Destroy()
	if (blob_datum)
		blob_datum.remove_blob(src)
	blob_datum = null
	..()

/obj/meat_blob/proc/set_target_score()
	var/dist = abs(abs(x - blob_datum.target_tile.x) + abs(y - blob_datum.target_tile.y))
	target_score = blob_datum.target_dist - dist

/obj/meat_blob/proc/set_side_score()
	side_score = 0
	if (src != blob_datum.center_blob)
		var/current_dir = get_dir(blob_datum.center_blob,src)
		if (blob_datum.target_dir & current_dir)
			side_score = 1
		else
			side_score = -1

/obj/meat_blob/proc/set_group_and_block_score()
	group_score = 0
	block_score = 0
	available_directions = list()
	connection_directions = list()
	for (var/direction in cardinal)
		var/turf/T = get_step(loc,direction)
		var/adjacent_blob = locate(/obj/meat_blob) in T
		if (adjacent_blob && (adjacent_blob in blob_datum.blob_tiles))
			group_score++
			connection_directions += direction
		else if (!T.Enter(src, loc, TRUE))
			block_score++
		else
			available_directions += direction

//This proc loops through all 8 surrounding turfs in a clockwise fashion to check if it contains a meatblob tile from the same parent datum
/*
		1  2  3

		8 src 4

	    7  6  5
*/
//If it alternates between finding/not-finding 3 or more times, that means this blob would split the group of blob tiles in two, so the blob shouldn't try to retract those
//We also take this opportunity to note down which of those tiles have connected blobs so we can update our icon_state. There are 256 possible combinations from XXXXXXXX to OOOOOOOO
/obj/meat_blob/proc/is_necessary()
	var/connections = ""
	var/static/list/clockwise_coords = list(
		list(-1,1),
		list(0,1),
		list(1,1),
		list(1,0),
		list(1,-1),
		list(0,-1),
		list(-1,-1),
		list(-1,0),
		)
	var/toggle_count = -1
	var/toggle_status = -1
	for (var/list/coord in clockwise_coords)
		var/nearby_blob = locate(/obj/meat_blob) in locate(x+coord[1],y+coord[2],z)
		if (nearby_blob && (nearby_blob in blob_datum.blob_tiles))
			connections += "O"
			if (toggle_status == 1)
				continue
			else
				toggle_status = 1
				toggle_count++
		else
			connections += "X"
			if (toggle_status == 0)
				continue
			else
				toggle_status = 0
				toggle_count++
	icon_state = connections
	return (toggle_count >= 3)

/obj/meat_blob/attack_ghost(var/mob/user)//DEBUG, Don't forget to remove, idiot
	if (blob_datum)
		blob_datum.set_target(user.loc)

/obj/meat_blob/blocks_doors()
	return TRUE

/datum/meat_blob/proc/instantiate(var/turf/spawnpoint)
	if (!spawnpoint)
		qdel(src)
		return
	spawn()
		custom_process()
	blobZ = spawnpoint.z
	var/obj/meat_blob/first_blob = new (spawnpoint)
	blob_tiles += first_blob
	first_blob.blob_datum = src
	average_x = first_blob.x
	average_y = first_blob.y
	spawn()
		expand_blob_list(list(first_blob), initial_size)
		re_center()
		for (var/blob in blob_tiles)
			var/obj/meat_blob/B = blob
			B.is_necessary()//updates sprites
		set_target(spawnpoint)

/datum/meat_blob/proc/custom_process()
	set waitfor = FALSE
	if (target_tile)
		tally_scores()
		if (mass_to_move)
			if (stuck_count >= mode_change_threshold)//if we're having some trouble to move, let's try thinning ourselves a bit
				target_modifier = 2
				side_modifier = 2
			else
				target_modifier = 1
				side_modifier = 1
			if (high_scorers?.len)
				var/obj/meat_blob/expanding = pick(high_scorers)
				if (expanding.available_directions?.len)
					var/expansion = pick(expanding.available_directions)
					var/obj/meat_blob/new_blob = expand_blob(expanding, get_step(expanding.loc,expansion))
					if (new_blob)
						for (var/obj/meat_blob/B in range(new_blob.loc,1))
							B.is_necessary()//updating sprite
						mass_to_move--
						set_target(target_tile)//updating target distance and direction
		else
			var/unshackle_attempt = 0
			if ((stuck_count >= stuck_critical) && (necessary_count >= 8))//For there to be an actual shackle to cut there should be at least 8 "necessary" tiles
				var/obj/meat_blob/retracting = pick(low_scorers_necessary)
				integrity_check = list(center_blob)
				core_integrity(list(center_blob),retracting)
				if (integrity_check.len == (blob_tiles.len - 1))//making sure that we're not separating the blob in two
					if (retracting.connection_directions?.len)
						var/retraction = pick(retracting.connection_directions)
						if (retraction)
							var/turf/T = retracting.loc
							remove_blob(retracting,retraction)
							qdel(retracting)
							for (var/obj/meat_blob/B in range(T,1))
								B.is_necessary()//updating sprite
							mass_to_move++
							set_target(target_tile)//updating target distance and direction
							unshackle_attempt = 1
			if (!unshackle_attempt && low_scorers?.len)
				var/obj/meat_blob/retracting = pick(low_scorers)
				if (retracting.connection_directions?.len)
					var/retraction = pick(retracting.connection_directions)
					if (retraction)
						var/turf/T = retracting.loc
						remove_blob(retracting,retraction)
						qdel(retracting)
						for (var/obj/meat_blob/B in range(T,1))
							B.is_necessary()//updating sprite
						mass_to_move++
						set_target(target_tile)//updating target distance and direction


		//tally_scores()//again for debug purposes
		//center_blob.maptext = "[stuck_count]"
	sleep(update_speed)
	custom_process()

/datum/meat_blob/proc/re_center()
	if (!blob_tiles?.len)
		return
	var/obj/meat_blob/preprevious_center = previous_center
	previous_center = center_blob
	var/closest_total_diff = 100
	var/obj/meat_blob/most_centered = null
	for (var/blob in blob_tiles)
		var/obj/meat_blob/B = blob
		var/diff_x = abs(B.x - average_x)
		var/diff_y = abs(B.y - average_y)
		var/total_diff = diff_x + diff_y
		if ((total_diff < closest_total_diff) || ((total_diff == closest_total_diff) && prob(50)))
			closest_total_diff = total_diff
			most_centered = B
	if (center_blob)
		center_blob.overlays -= "center"
	center_blob = most_centered
	center_blob.overlays += "center"
	if (((previous_center == center_blob)||(preprevious_center == center_blob)) && (target_dist > 2))//if the center hasn't moved in a while and we're nowhere near the target, we might be shackled
		stuck_count++
	else
		stuck_count = 0

/datum/meat_blob/proc/set_target(var/turf/T)
	if (!T || (T.z != blobZ))
		return
	target_tile = T
	target_dist = abs(abs(center_blob.x - T.x) + abs(center_blob.y - T.y))
	target_dir = get_dir(center_blob,T)

/datum/meat_blob/proc/core_integrity(var/list/blobs_to_check,var/obj/meat_blob/blob_to_kill = null)
	var/list/next_blobs = list()
	for(var/blob in blobs_to_check)
		var/obj/meat_blob/B = blob
		for (var/direction in cardinal)
			var/turf/T = get_step(B.loc,direction)
			var/obj/meat_blob/O = locate(/obj/meat_blob) in T
			if (O && (O in blob_tiles) && (O != blob_to_kill))
				if (!(O in integrity_check))
					next_blobs += O
				integrity_check |= O
	if (next_blobs?.len)
		core_integrity(next_blobs,blob_to_kill)

/datum/meat_blob/proc/tally_scores()
	high_scorers = list()
	low_scorers = list()
	low_scorers_necessary = list()
	necessary_count = 0
	var/high_score = -100
	var/low_score = 100
	var/low_score_critical = 100
	for (var/blob in blob_tiles)
		var/obj/meat_blob/B = blob
		B.set_target_score()
		B.set_side_score()
		B.set_group_and_block_score()
		B.score = B.target_score * target_modifier + B.group_score * group_modifier + B.side_score * side_modifier
		//B.maptext = "[B.score]"
		if ((B.group_score + B.block_score) < 4)//we're not gonna try to expand off an inner tile or a blocked tile
			if (B.score > high_score)
				high_scorers = list(B)
				high_score = B.score
			else if (B.score == high_score)
				high_scorers += B
		if (!B.is_necessary())//we're not gonna cut off a tile that would separate the blob in two
			if (B.score < low_score)
				low_scorers = list(B)
				low_score = B.score
			else if (B.score == low_score)
				low_scorers += B
		else if (stuck_count > stuck_critical)//UNLESS we somehow shackled ourselves by accident
			necessary_count++
			if (B.score < low_score_critical)
				low_scorers_necessary = list(B)
				low_score_critical = B.score
			else if (B.score == low_score_critical)
				low_scorers_necessary += B

/datum/meat_blob/proc/expand_blob_list(var/list/blob_list, var/amount_to_expand = 0)
	var/list/new_list = list()
	for(var/blob in blob_list)
		var/obj/meat_blob/B = blob
		if (amount_to_expand <= 0)
			return
		var/list/cardinal_tiles = list()
		for (var/direction in cardinal)
			cardinal_tiles += get_step(B.loc,direction)
		for (var/turf/T in cardinal_tiles)
			if (amount_to_expand <= 0)
				return
			var/obj/meat_blob/new_blob = expand_blob(B,T)
			if (new_blob)
				new_list += new_blob
				amount_to_expand--
				sleep(2)
	if (new_list.len > 0)
		expand_blob_list(new_list, amount_to_expand)
	else if (amount_to_expand)
		mass_to_move = amount_to_expand

/datum/meat_blob/proc/expand_blob(var/obj/meat_blob/source, var/turf/target)
	var/obj/meat_blob/new_blob = new (source.loc)
	if(target.Enter(new_blob, source.loc, TRUE))//Attempt to move into the tile
		new_blob.Move(target)
		new_blob.move_blob(get_dir(source.loc,target))
		new_blob.blob_datum = src
		var/total_x = average_x * blob_tiles.len
		var/total_y = average_y * blob_tiles.len
		blob_tiles += new_blob
		average_x = (total_x + new_blob.x) / blob_tiles.len
		average_y = (total_y + new_blob.y) / blob_tiles.len
		re_center()
		return new_blob
	else
		qdel(new_blob)
		return null

/obj/meat_blob/proc/move_blob(var/direction)
	switch(direction)
		if (NORTH)
			pixel_y = -32
		if (SOUTH)
			pixel_y = 32
		if (EAST)
			pixel_x = -32
		if (WEST)
			pixel_x = 32
	animate(src,pixel_x = 0, pixel_y = 0, time = 2, easing = SINE_EASING|EASE_OUT)

/datum/meat_blob/proc/remove_blob(var/obj/meat_blob/blob,var/merge)
	blob.blob_datum = null
	var/total_x = average_x * blob_tiles.len
	var/total_y = average_y * blob_tiles.len
	blob_tiles -= blob
	average_x = (total_x - blob.x) / blob_tiles.len
	average_y = (total_y - blob.y) / blob_tiles.len
	re_center()
	if (merge)
		var/atom/movable/overlay/animation = new /atom/movable/overlay(blob.loc)
		animation.appearance = blob.appearance
		animation.layer -= 1
		switch(merge)
			if (NORTH)
				animate(animation,pixel_y = 32, time = 2, easing = SINE_EASING|EASE_IN)
			if (SOUTH)
				animate(animation,pixel_y = -32, time = 2, easing = SINE_EASING|EASE_IN)
			if (WEST)
				animate(animation,pixel_x = -32, time = 2, easing = SINE_EASING|EASE_IN)
			if (EAST)
				animate(animation,pixel_x = 32, time = 2, easing = SINE_EASING|EASE_IN)
		spawn(2)
			qdel(animation)