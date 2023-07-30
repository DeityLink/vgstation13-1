
/*



*/

//Cult space vines that need blood to expand
//They get blood by entangling humans that pass through them
//Fires hookshots at non-cultists to quickly trap them in
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

	health = 10
	maxHealth = 100

	var/obj/item/weapon/gun/hookshot/cultdzu/grabber = null
	var/grab_delay = 2 SECONDS
	var/last_grab = 0

/datum/locking_category/cultdzu

/obj/cultdzu/New(turf/loc)
	..()
	grabber = new(src)

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
		AM.forceMove(loc)

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

/obj/item/weapon/gun/hookshot/cultdzu/clockwerk_chain(var/length)
	rewind_chain()

/obj/item/weapon/gun/hookshot/cultdzu/check_tether()
	if(chain_datum && istype(loc,/obj/cultdzu))
		var/obj/cultdzu/C = loc
		if(C.tether)
			var/datum/chain/tether_datum = C.tether.chain_datum
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
	AM.forceMove(A.loc)

/obj/item/projectile/hookshot/cultdzu/to_bump(var/atom/A)
	if (istype(A,/mob/living))
		var/mob/living/L = A
		if (L.locked_to)
			var/obj/O = L.locked_to
			O.unlock_atom(L)
	..()

/obj/item/projectile/hookshot/cultdzu
	name = "grabber"
	desc = "You might wanna dodge that."
	projectile_speed = 0.33
	icon = 'icons/obj/cultdzu.dmi'
	icon_state = "cultdzu"
	icon_name = "cultdzu0"
	chain_overlay_path = /obj/effect/overlay/chain/cultdzu
	chain_datum_path = /datum/chain/cultdzu


/obj/item/projectile/hookshot/cultdzu/process_step()
	icon_name = "cultdzu[rand(1,5)]"
	..()

/datum/chain/cultdzu
	name = "grabber"

//THE CHAIN THAT APPEARS WHEN YOU FIRE THE HOOKSHOT
/obj/effect/overlay/hookchain/cultdzu
	name = "grabber"
	desc = "You might wanna dodge that."
	icon = 'icons/obj/cultdzu.dmi'
	icon_state = "cultdzu1_chain"

//THE CHAIN THAT TETHERS STUFF TOGETHER
/obj/effect/overlay/chain/cultdzu
	name = "grabber"
	desc = "Oh shit!"
	overlay_name = "cultdzu_chain"
