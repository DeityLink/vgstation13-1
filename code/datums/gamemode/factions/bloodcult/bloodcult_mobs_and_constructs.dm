
/////////////////Juggernaut///////////////
/mob/living/simple_animal/construct/armoured/perfect
	icon_state = "juggernaut2"
	icon_living = "juggernaut2"
	icon_dead = "juggernaut2"
	construct_spells = list(
		/spell/aoe_turf/conjure/forcewall/greater,
		/spell/juggerdash,
		)
	see_in_dark = 7
	var/dash_dir = null
	var/turf/crashing = null

/mob/living/simple_animal/construct/armoured/perfect/New()
	..()
	setupfloat()

/mob/living/simple_animal/construct/armoured/perfect/to_bump(var/atom/obstacle)
	if(src.throwing)
		var/breakthrough = 0
		if(istype(obstacle, /obj/structure/window/))
			obstacle.Destroy(brokenup = 1)
			breakthrough = 1

		else if(istype(obstacle, /obj/structure/grille/))
			var/obj/structure/grille/G = obstacle
			G.health = (0.25*initial(G.health))
			G.broken = 1
			G.icon_state = "[initial(G.icon_state)]-b"
			G.setDensity(FALSE)
			getFromPool(/obj/item/stack/rods, get_turf(G.loc))
			breakthrough = 1

		else if(istype(obstacle, /obj/structure/table))
			var/obj/structure/table/T = obstacle
			T.destroy()
			breakthrough = 1

		else if(istype(obstacle, /obj/structure/rack))
			new /obj/item/weapon/rack_parts(obstacle.loc)
			qdel(obstacle)
			breakthrough = 1

		else if(istype(obstacle, /turf/simulated/wall))
			var/turf/simulated/wall/W = obstacle
			if (W.hardness <= 60)
				playsound(W, 'sound/weapons/heavysmash.ogg', 75, 1)
				W.dismantle_wall(1)
				breakthrough = 1
			else
				src.throwing = 0
				src.crashing = null

		else if(istype(obstacle, /obj/structure/reagent_dispensers/fueltank))
			obstacle.ex_act(1)

		else if(istype(obstacle, /mob/living))
			var/mob/living/L = obstacle
			if (L.flags & INVULNERABLE)
				src.throwing = 0
				src.crashing = null
			else if (!(L.status_flags & CANKNOCKDOWN) || (M_HULK in L.mutations) || istype(L,/mob/living/silicon))
				//can't be knocked down? you'll still take the damage.
				src.throwing = 0
				src.crashing = null
				L.take_overall_damage(5,0)
				if(L.locked_to)
					L.locked_to.unlock_atom(L)
			else
				L.take_overall_damage(5,0)
				if(L.locked_to)
					L.locked_to.unlock_atom(L)
				L.Stun(5)
				L.Knockdown(5)
				L.apply_effect(STUTTER, 5)
				playsound(src, 'sound/weapons/heavysmash.ogg', 50, 0, 0)
				breakthrough = 1
		else
			src.throwing = 0
			src.crashing = null

		if(breakthrough)
			if(crashing && !istype(crashing,/turf/space))
				spawn(1)
					src.throw_at(crashing, 50, src.throw_speed)
			else
				spawn(1)
					crashing = get_distant_turf(get_turf(src), dash_dir, 2)
					src.throw_at(crashing, 50, src.throw_speed)

	if(istype(obstacle, /obj))
		var/obj/O = obstacle
		if(istype(O, /obj/effect/portal))
			src.anchored = 0
			O.Crossed(src)
			spawn(0)
				src.anchored = 1
		else if(!O.anchored)
			step(obstacle,src.dir)
		else
			obstacle.Bumped(src)
	else if(istype(obstacle, /mob))
		step(obstacle,src.dir)
	else
		obstacle.Bumped(src)


////////////////////Wraith/////////////////////////


/mob/living/simple_animal/construct/wraith/perfect
	icon_state = "wraith2"
	icon_living = "wraith2"
	icon_dead = "wraith2"
	see_in_dark = 7
	construct_spells = list(/spell/targeted/ethereal_jaunt/shift/alt)
	var/ranged_cooldown = 0
	var/ammo = 3
	var/ammo_recharge = 0

/mob/living/simple_animal/construct/wraith/perfect/New()
	..()
	setupfloat()

/mob/living/simple_animal/construct/wraith/perfect/Life()
	if(timestopped)
		return 0
	. = ..()
	ranged_cooldown = max(0,ranged_cooldown-1)
	if (ammo < 3)
		ammo_recharge++
		if (ammo_recharge >= 3)
			ammo_recharge = 0
			ammo++

/mob/living/simple_animal/construct/wraith/perfect/RangedAttack(var/atom/A, var/params)
	if(ranged_cooldown <= 0 && ammo)
		ammo--
		var/obj/item/projectile/wraithnail/nail = new (loc)

		if(!nail || !A)
			return 0

		playsound(loc, 'sound/weapons/hivehand.ogg', 75, 1)

		var/turf/T = get_turf(src)
		var/turf/U = get_turf(A)
		nail.original = U
		nail.target = U
		nail.current = T
		nail.starting = T
		nail.yo = U.y - T.y
		nail.xo = U.x - T.x
		spawn()
			nail.OnFired()
			nail.process()

	return ..()

/obj/item/projectile/wraithnail
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "wraithnail"
	damage = 5


/obj/item/projectile/wraithnail/to_bump(var/atom/A)
	if(bumped)
		return 0
	bumped = 1

	if(A)
		setDensity(FALSE)
		invisibility = 101
		kill_count = 0
		var/obj/effect/overlay/wraithnail/nail = new (A.loc)
		nail.transform = transform
		if(isliving(A))
			nail.stick_to(A)
			var/mob/living/L = A
			L.take_overall_damage(damage,0)
		else if(loc)
			var/turf/T = get_turf(src)
			nail.stick_to(T,get_dir(src,A))
		bullet_die()

/obj/item/projectile/wraithnail/bump_original_check()
	if(!bumped)
		if(loc == get_turf(original))
			if(!(original in permutated))
				to_bump(original)

/obj/effect/overlay/wraithnail
	name = "red bolt"
	desc = "A pointy red nail, lodged into the ground."
	icon = 'icons/effects/effects.dmi'
	icon_state = "wraithnail"
	anchored = 1
	density = 0
	plane = ABOVE_HUMAN_PLANE
	layer = CLOSED_CURTAIN_LAYER
	var/atom/stuck_to = null
	var/duration = 100

/obj/effect/overlay/wraithnail/New()
	..()
	pixel_x = rand(-4, 4) * PIXEL_MULTIPLIER
	pixel_y = rand(-4, 4) * PIXEL_MULTIPLIER

/obj/effect/overlay/wraithnail/Destroy()
	if(stuck_to)
		unlock_atom(stuck_to)
	stuck_to = null
	..()

/obj/effect/overlay/wraithnail/proc/stick_to(var/atom/A, var/side = null)
	pixel_x = rand(-4, 4) * PIXEL_MULTIPLIER
	pixel_y = rand(-4, 4) * PIXEL_MULTIPLIER
	playsound(A, 'sound/items/metal_impact.ogg', 30, 1)
	var/turf/T = get_turf(A)
	loc = T
	playsound(T, 'sound/weapons/hivehand_empty.ogg', 75, 1)

	if(isturf(A))
		switch(side)
			if(NORTH)
				pixel_y = WORLD_ICON_SIZE/2
			if(SOUTH)
				pixel_y = -WORLD_ICON_SIZE/2
			if(EAST)
				pixel_x = WORLD_ICON_SIZE/2
			if(WEST)
				pixel_x = -WORLD_ICON_SIZE/2

	else if(isliving(A) && !isspace(T))
		stuck_to = A
		visible_message("<span class='warning'>\the [src] nails \the [A] to \the [T].</span>")
		lock_atom(A, /datum/locking_category/buckle)

	spawn(duration)
		qdel(src)


/obj/effect/overlay/wraithnail/attack_hand(var/mob/user)
	if (do_after(user,src,15))
		unstick()

/obj/effect/overlay/wraithnail/proc/unstick()
	if(stuck_to)
		unlock_atom(stuck_to)
	qdel(src)


////////////////////Artificer/////////////////////////

/mob/living/simple_animal/construct/builder/perfect
	icon_state = "artificer2"
	icon_living = "artificer2"
	icon_dead = "artificer2"
	see_in_dark = 7

/mob/living/simple_animal/construct/builder/perfect/New()
	..()
	setupfloat()
