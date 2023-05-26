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
	var/image/damage_overlay = null
	var/list/possible_wounds = list("blood_1","blood_2","blood_3","blood_4","blood_5")

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

/atom/proc/blood_dimension_radius(transformRadius = 1, approxRadius = 1)
	//mirrors tiles in a radius on the station into the blood dimension
	if (z != map.zMainStation || !bloodZ)
		return
	var/turf/T = locate(x,y,z)
	if (!T)
		return
	var/list/tiles_to_mirror = list()
	for (var/i = (-1 * transformRadius) to transformRadius)
		for (var/j = (-1 * transformRadius) to transformRadius)
			var/dist = cheap_pythag(i,j)
			if (dist <= transformRadius)
				if (dist <= approxRadius || prob(50))
					tiles_to_mirror |= list(list(i+T.x,j+T.y))
	spawn()
		while(tiles_to_mirror.len)
			var/tile_to_mirror = pick(tiles_to_mirror)
			tiles_to_mirror -= list(tile_to_mirror)
			blood_dimension_coordinates(tile_to_mirror[1], tile_to_mirror[2])
			sleep(1)

/proc/blood_dimension_coordinates(var/targetX, var/targetY)
	//mirrors the station tile at the given coordinates into the blood dimension
	var/turf/T = locate(targetX,targetY,map.zMainStation)
	if (T)
		T.blood_dimension_shape()

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

/turf/proc/blood_dimension_shape()
	//mirrors this specific tile into the blood dimension
	if (z != map.zMainStation || !bloodZ)
		return//we only mirror station tiles
	var/turf/T = locate(x,y,bloodZ)
	if (T.bloodcarved)
		return//already mirrored
	T.bloodcarved = 1
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

/turf/unsimulated/wall/blood_dimension_shape()
	. = ..()
	if (.)
		var/turf/T = .
		T.blood_dimension_dress()

/turf/simulated/wall/blood_dimension_shape()
	. = ..()
	if (.)
		var/turf/T = .
		T.blood_dimension_dress()

/turf/unsimulated/floor/blood_dimension_shape()
	. = ..()
	if (.)
		var/turf/T = .
		T.blood_dimension_carve()

/turf/simulated/floor/blood_dimension_shape()
	. = ..()
	if (.)
		var/turf/T = .
		T.blood_dimension_carve()

/turf/proc/blood_dimension_carve(var/dress = TRUE)
	if (dress && (denomination == "membrane"))
		opacity = 0
		blood_dimension_dress()
		return
	ChangeTurf(/turf/unsimulated/floor/bloodrealm)
	for (var/turf/unsimulated/wall/bloodrealm/W in range(1,src))
		W.apply_ribs(src)
	if (dress)
		blood_dimension_dress()

/turf/proc/apply_ribs()
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

/turf/unsimulated/wall/bloodrealm/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = 0, var/allow = 1)
	overlays.len = 0
	..()

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

/turf/proc/blood_dimension_dress()
	return

/turf/unsimulated/wall/bloodrealm/blood_dimension_dress()
	if (bloodcarved != 1)
		return
	var/turf/source = locate(x,y,map.zMainStation)

	for (var/obj/A in source)
		A.blood_dimension_copy(src)

	bloodcarved = 2

/turf/unsimulated/floor/bloodrealm/blood_dimension_dress()
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

	bloodcarved = 2

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

	bloodcarved = 3

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

/turf/unsimulated/wall/bloodrealm/proc/take_damage(var/damage = 0,var/hitsound = TRUE)
	if (!damage)
		return

	if (!damage_overlay)
		damage_overlay = image(icon,src,"blank")

	if(hitsound)
		playsound(loc, get_sfx("machete_hit"), 50, 1)

	var/next_threshold = maxHealth
	while (next_threshold > health)
		next_threshold -= maxHealth/5

	overlays -= damage_overlay

	health -= damage

	if (health <= 0)
		playsound(src, "sound/effects/blobsplat.ogg", 50, 1)
		if (denomination == "membrane")
			name = "viscous floor"
			icon_state = "floor_accent"
			anim(target = src, a_icon = icon, flick_anim = "membrane_break", sleeptime = 10, plane = src.plane, lay = layer+0.3)
		else
			anim(target = src, a_icon = icon, flick_anim = "rib_break", sleeptime = 10, plane = src.plane, lay = layer+0.3)
		blood_dimension_expand(src)
		blood_dimension_carve(FALSE)
	else
		while (health < next_threshold)
			var/new_wound = pick(possible_wounds)
			possible_wounds -= new_wound
			damage_overlay.overlays += new_wound
			next_threshold -= maxHealth/5
		overlays += damage_overlay

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
	take_damage(dam)
	..()

//explosions
/turf/unsimulated/wall/bloodrealm/ex_act(severity)
	switch(severity)
		if(1)
			take_damage(rand(200, 300), FALSE)
		if(2)
			take_damage(rand(50, 150), FALSE)
		if(3)
			take_damage(rand(5, 50), FALSE)

//hit by bullets
/turf/unsimulated/wall/bloodrealm/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)
		return
	take_damage(Proj.damage)
	return ..()

//hit by thrown items
/turf/unsimulated/wall/bloodrealm/hitby(var/atom/movable/AM)
	if(isitem(AM))
		var/obj/item/I = AM
		take_damage(I.throwforce)

//slashed by simple_animals
/turf/unsimulated/wall/bloodrealm/attack_animal(var/mob/living/simple_animal/user)
	user.delayNextAttack(8)
	user.do_attack_animation(src, user)
	take_damage(user.get_unarmed_damage(src))

//slashed (touched?) by humans
/turf/unsimulated/wall/bloodrealm/attack_hand(var/mob/living/carbon/human/user)
	if (user.a_intent == I_HURT)
		user.delayNextAttack(8)
		user.do_attack_animation(src, user)
		take_damage(user.get_unarmed_damage(src))

//slashed (touched?) by monkeys
/turf/unsimulated/wall/bloodrealm/attack_paw(var/mob/living/carbon/monkey/user)
	if (user.a_intent == I_HURT)
		user.delayNextAttack(8)
		user.do_attack_animation(src, user)
		take_damage(user.get_unarmed_damage(src))

//slashed by aliums
/turf/unsimulated/wall/bloodrealm/attack_alien(var/mob/living/carbon/alien/humanoid/user)
	if(istype(user, /mob/living/carbon/alien/larva))
		return
	user.delayNextAttack(8)
	user.do_attack_animation(src, user)
	var/alienverb = pick(list("slam", "rip", "claw"))
	user.delayNextAttack(8)
	user.visible_message("<span class='warning'>[user] [alienverb]s \the [src].</span>", \
						 "<span class='warning'>You [alienverb] \the [src].</span>", \
						 "You hear ripping flesh.")
	take_damage(rand(15,30))
