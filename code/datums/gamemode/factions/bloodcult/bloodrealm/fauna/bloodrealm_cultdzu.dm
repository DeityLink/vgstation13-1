
/*



*/


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

/obj/cultdzu/New(turf/loc)
	..()
	grabber = new(src)

/obj/cultdzu/Destroy()
	QDEL_NULL(grabber)
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


/obj/item/weapon/gun/hookshot/cultdzu
	name = ""
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



/obj/item/projectile/hookshot/cultdzu
	name = "grabber"
	desc = "You might wanna dodge that."
	projectile_speed = 0.33

/obj/effect/overlay/hookchain/cultdzu
	name = "grabber"
	desc = "You might wanna dodge that."

/obj/effect/overlay/chain/cultdzu
	name = "grabber"
	desc = "Oh shit!"
