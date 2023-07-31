
/*

/obj/cultdzu
/datum/locking_category/cultdzu
/obj/item/weapon/gun/hookshot/cultdzu
/obj/item/projectile/hookshot/cultdzu
/datum/chain/cultdzu
/obj/effect/overlay/hookchain/cultdzu
/obj/effect/overlay/chain/cultdzu

*/

//Cult space vines that need blood to expand
//They get blood by entangling humans that pass through them
//Fires hookshots at passing mobs to quickly trap those with blood in
//Cultists get grabbed too, but can more easily get out
//Sucks blood continually until the victim dies
//Sucks blood faster if it needs to heal itself, or slower if the target is in crit/dying.

/obj/cultdzu
	name = "bloodsucker tangle"
	desc = "A mass of wriggly appendages that can grab creatures at a distance and traps them in to suck their blood. Allowing it to expand."
	icon = 'icons/obj/cultdzu.dmi'
	icon_state = "cultdzu"
	anchored = 1
	opacity = 0
	density = 0
	plane = ABOVE_HUMAN_PLANE
	pass_flags = PASSTABLE | PASSGRILLE | PASSGIRDER | PASSMACHINE
	mouse_opacity = 1
	var/list/turf/simulated/floor/neighbors = list()
	var/mature_time
	var/tmp/last_tick = 0
	var/tmp/last_special = 0
	var/age = 0

	health = 10
	maxHealth = 100

	maxtemp = 350

	var/obj/item/weapon/gun/hookshot/cultdzu/grabber = null
	var/grab_delay = 2 SECONDS
	var/last_grab = 0

/datum/locking_category/cultdzu

/obj/cultdzu/New(turf/loc)
	..()
	grabber = new(src)
	grabber.source = src
	create_reagents(100)//gotta store the blood we suck somewhere

/obj/cultdzu/Destroy()
	QDEL_NULL(grabber)
	if(is_locking_type(/mob, /datum/locking_category/cultdzu))
		var/mob/V = locate(/mob) in get_locked(/datum/locking_category/cultdzu)
		unlock_atom(V)
	..()

/obj/cultdzu/attack_ghost(var/mob/user)//DEBUG, Don't forget to remove, idiot
	grab_at_turf(user.loc)

/obj/cultdzu/proc/grab_at_turf(var/turf/target)
	if (!loc || !istype(target))
		return
	if(world.time < last_grab + grab_delay)
		return

	playsound(src, grabber.fire_sound, 100, 1)

	last_grab = world.time
	var/obj/item/projectile/hookshot/cultdzu/grabber_projectile
	grabber_projectile = new grabber.hooktype(loc)
	grabber_projectile.firer = src
	grabber_projectile.original = target
	grabber_projectile.starting = loc
	grabber_projectile.shot_from = grabber
	grabber_projectile.target = target
	grabber_projectile.current = loc
	grabber_projectile.yo = target.y - loc.y
	grabber_projectile.xo = target.x - loc.x
	grabber_projectile.OnFired()
	spawn()
		grabber_projectile.process()

/obj/cultdzu/proc/start_pulling(var/atom/movable/AM)
	if (Adjacent(AM))
		entrap_atom(AM)

/obj/cultdzu/proc/special_cooldown()
	return world.time >= last_special + 3 SECONDS

/obj/cultdzu/Crossed(var/mob/living/M)
	if(!istype(M) || !is_mature() || !special_cooldown())
		return
	if(prob(round(seed.potency/6)))
		entangle_mob(M)
	if(istype(M, /mob/living/carbon/human))
		do_thorns(M, 25) //this is the chance !! PER NON-PROTECTED LIMB !!
		do_sting(M, 30)

/obj/cultdzu/proc/is_mature()
	return (health >= (maxHealth/2) && age > mature_time)

/obj/cultdzu/attack_hand(var/mob/user)
	manual_unbuckle(user)

/obj/cultdzu/attack_paw(var/mob/user)
	manual_unbuckle(user)


/obj/cultdzu/lock_atom(var/mob/living/M)
	. = ..()
	if(!.)
		return

	if(!istype(M))
		return

	M.register_event(/event/resist, src, src::manual_unbuckle())

	last_special = world.time

/obj/cultdzu/unlock_atom(var/mob/living/M)
	. = ..()
	if(!.)
		return

	if(!istype(M))
		return

	M.unregister_event(/event/resist, src, src::manual_unbuckle())

/obj/cultdzu/proc/entrap_atom(var/atom/movable/victim)
	if(!victim || victim.locked_to || is_locking(/datum/locking_category/cultdzu))
		return
	victim.visible_message("<span class='danger'>Tendrils lash out from \the [src] and drag \the [victim] in!</span>","<span class='danger'>The bloodsuckers [pick("wind", "tangle", "tighten")] around you!</span>")
	victim.forceMove(loc)
	lock_atom(victim, /datum/locking_category/cultdzu)
	playsound(src, 'sound/weapons/spiderlunge.ogg', 100, 1)


/obj/cultdzu/proc/attack_mob(var/mob/living/L)
	var/atk_zone = ran_zone(LIMB_CHEST)
	var/atk_flag = "melee"
	var/atk_dam = 10
	var/absorb = L.run_armor_check(atk_zone, atk_flag)
	var/damage = L.run_armor_absorb(atk_zone, atk_flag, atk_dam)
	L.apply_damage(damage, atk_flag, atk_zone, absorb, TRUE, used_weapon = grabber)
	L.regenerate_icons()

#define NEIGHBOR_REFRESH_TIME 100

/obj/cultdzu/proc/get_cardinal_neighbors()
	var/list/cardinal_neighbors = list()
	for(var/check_dir in cardinal)
		var/turf/simulated/T = get_step(get_turf(src), check_dir)
		if(istype(T))
			cardinal_neighbors |= T
	return cardinal_neighbors

/obj/cultdzu/proc/update_neighbors()
	neighbors = list()
	for(var/turf/simulated/T in get_cardinal_neighbors())
		if(locate(/obj/cultdzu) in T.contents)
			continue
		if(!Adjacent(T) || !T.Enter(src, loc, TRUE))
			continue
		neighbors |= T
	// Update all of our friends.
	var/turf/T = get_turf(src)
	for(var/obj/cultdzu/neighbor in range(1,src))
		neighbor.neighbors -= T

/obj/cultdzu/process()
	if(timestopped)
		return 0

	var/turf/simulated/T = get_turf(src)

	//takes damage from fire
	if(istype(T))
		var/datum/gas_mixture/environment = T.return_air()
		if(environment)
			if(environment.temperature > maxtemp)
				health -= rand(5,10)

	//heals from stored blood
	if(health < maxHealth)
		health = min(maxHealth, health + rand(3,5))

	if(prob(80))
		age++

	if(harvest && (seed.harvest_repeat == 2))
		autoharvest()

	if(!harvest && prob(3) && age > mature_time + seed.production)
		harvest = 1

	update_icon()

	if(is_mature() && special_cooldown())
		if(is_locking_type(/mob, /datum/locking_category/plantsegment))
			var/mob/V = locate(/mob) in get_locked(/datum/locking_category/plantsegment)
			if (V.loc != loc)
				unlock_atom(V)
				to_chat(V, "<span class='danger'>You broke free from \the [src]!</span>")
			else
				if(istype(V, /mob/living/carbon/human))
					do_chem_inject(V)
					do_carnivorous_bite(V, seed.potency)
		else
			if(seed.voracious == 2)
				var/mob/living/victim = locate() in range(src,1)
				if(victim)
					grab_mob(victim)
			else
				if(prob(round(seed.potency/2)))
					var/mob/living/victim = locate() in get_turf(src)
					if(victim)
						grab_mob(victim)

	if(world.time >= last_tick+NEIGHBOR_REFRESH_TIME)
		last_tick = world.time
		update_neighbors()

	if(sampled)
		//Should be between 2-7 for given the default range of values for production time.
		var/chance = max(1, round(30/seed.production))
		if(prob(chance))
			sampled = 0

	if(is_mature() && neighbors.len && prob(spread_chance))
		//spread to 1-3 adjacent turfs depending on yield trait.
		var/max_spread = clamp(round(seed.yield*3/14), 1, 3) // 3/14? Why?

		for(var/i in 1 to max_spread)
			if(prob(spread_chance))
				sleep(rand(3,5))
				if(gcDestroyed || !neighbors.len)
					break
				var/turf/target_turf = pick(neighbors)
				var/obj/effect/plantsegment/child = new(get_turf(src),seed,epicenter)
				// Update neighboring squares.
				for(var/obj/effect/plantsegment/neighbor in range(1,target_turf))
					neighbor.neighbors -= target_turf
				spawn(1) // This should do a little bit of animation.
					child.forceMove(target_turf)
					child.update_icon()

	// We shouldn't have spawned if the controller doesn't exist.
	try_break()
	// Keep processing us until we've done all there is for us to do in life.
	if(!neighbors.len && (health == maxHealth || health <= 0) && harvest && !is_locking(/datum/locking_category))
		SSplant.remove_plant(src)

/obj/cultdzu/proc/die_off()
	for(var/turf/simulated/check_turf in get_cardinal_neighbors())
		if(!istype(check_turf))
			continue
		for(var/obj/cultdzu/neighbor in check_turf.contents)
			neighbor.neighbors |= check_turf
			processing_objects.Add(neighbor)
	qdel(src)

/obj/cultdzu/proc/proxDensityChange(var/atom/A)
	var/turf/T = get_turf(A)
	if(!is_blocked_turf(T))
		processing_objects.Add(src)

#undef NEIGHBOR_REFRESH_TIME




//////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/gun/hookshot/cultdzu
	name = "bloodsucker tangle"
	desc = ""
	slot_flags = null
	mech_flags = MECH_SCAN_ILLEGAL
	fire_sound = 'sound/effects/flesh_squelch.ogg'
	empty_sound = null
	silenced = 1
	fire_volume = 100
	maxlength = 9
	chaintype = /obj/effect/overlay/hookchain/cultdzu
	hooktype = /obj/item/projectile/hookshot/cultdzu
	var/obj/cultdzu/source

/obj/item/weapon/gun/hookshot/cultdzu/Destroy()
	source = null
	..()

/obj/item/weapon/gun/hookshot/cultdzu/clockwerk_chain(var/length)
	rewind_chain()

/obj/item/weapon/gun/hookshot/cultdzu/check_tether()
	if(chain_datum)
		if(source.tether)
			var/datum/chain/tether_datum = source.tether.chain_datum
			if(tether_datum == chain_datum)
				return 1
	return 0

/obj/item/weapon/gun/hookshot/cultdzu/hooked_something()
	spawn(5)
		if(check_tether())
			if(istype(chain_datum.extremity_B,/mob/living/carbon))
				display_reel_message()
			chain_datum.rewind_chain()

/obj/item/weapon/gun/hookshot/cultdzu/finished_rewind(var/atom/A, var/atom/movable/AM)
	source.entrap_atom(AM)

/obj/item/weapon/gun/hookshot/cultdzu/can_hook(var/atom/movable/AM)
	if (!isliving(AM))
		return FALSE
	var/skin = "skin"
	var/mob/living/L = AM
	if (istype(L, /mob/living/carbon/monkey) || istype(L, /mob/living/carbon/alien))
		return TRUE
	if (istype(L, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = L
		if (H.take_blood(source, 1))
			return TRUE

	if (istype(L, /mob/living/carbon/slime))
		skin = "metal cover"

	else (istype(L, /mob/living/simple_animal))
		var/mob/living/simple_animal/SA = L
		if (SA.blooded)
			return TRUE
	else (istype(L, /mob/living/silicon))
		skin = "metal cover"


	source.attack_mob(L)
	to_chat(L, "The tendrils pierce your [skin], but failing to find any blood they retract without grabbing you.")
	return FALSE

//////////////////////////////////////////////////////////////////////////////////

/obj/item/projectile/hookshot/cultdzu
	name = "grabber"
	desc = "You might wanna dodge that."
	projectile_speed = 0.33
	icon = 'icons/obj/cultdzu.dmi'
	icon_state = "cultdzu"
	icon_name = "cultdzu0"
	chain_overlay_path = /obj/effect/overlay/chain/cultdzu
	chain_datum_path = /datum/chain/cultdzu


/obj/item/projectile/hookshot/cultdzu/to_bump(var/atom/A)
	if (istype(A,/mob/living))
		var/mob/living/L = A
		if (L.locked_to)
			var/obj/O = L.locked_to
			O.unlock_atom(L)
	..()

/obj/item/projectile/hookshot/cultdzu/process_step()
	icon_name = "cultdzu[rand(1,5)]"
	..()

//////////////////////////////////////////////////////////////////////////////////

/datum/chain/cultdzu
	name = "grabber"

//////////////////////////////////////////////////////////////////////////////////
//THE CHAIN THAT APPEARS WHEN YOU FIRE THE HOOKSHOT
/obj/effect/overlay/hookchain/cultdzu
	name = "grabber"
	desc = "You might wanna dodge that."
	icon = 'icons/obj/cultdzu.dmi'
	icon_state = "cultdzu1_chain"

//////////////////////////////////////////////////////////////////////////////////
//THE CHAIN THAT TETHERS STUFF TOGETHER
/obj/effect/overlay/chain/cultdzu
	name = "grabber"
	desc = "Oh shit!"
	overlay_name = "cultdzu_chain"
