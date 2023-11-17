/*

/obj/structure/spinning_wheel
/obj/machinery/electric_loom

*/

#define CLOTH_PER_FLAX	2

////////////////////MANUAL LOOM//////////////////////
//TODO: support wool as well, and maybe other plants such as coton
//I chose linen to start with because of too much time playing Pharaoh
/obj/structure/spinning_wheel
	name = "spinning wheel"
	desc = "Allows you to manually weave grown flax into linen cloth."
	icon = 'icons/obj/clothes_making.dmi'
	icon_state = "wooden_loom"
	density = 1
	anchored = 0

	var/remaining_cloth = 0
	var/mob/spinner = null

/obj/structure/spinning_wheel/Destroy()
	if (spinner)
		spinner = null
		processing_objects.Remove(src)
	..()

/obj/structure/spinning_wheel/examine(mob/user)
	..()
	if(remaining_cloth > 0)
		to_chat(user, "<span class='info'>There is enough flax in it to produce [remaining_cloth] more cloth sheets.</span>")
	else
		to_chat(user, "<span class='info'>Grow some flax then put it in there before you can use it.</span>")

/obj/structure/spinning_wheel/attack_hand(var/mob/user)
	if (spinner)
		if (user == spinner)
			to_chat(user, "<span class='notice'>You interrupt your weaving.</span>")
			spinner = null
			processing_objects.Remove(src)
			update_icon()
		else
			to_chat(user, "<span class='warning'>\The [spinner] is currently weaving at this [src] already.</span>")
	else if (remaining_cloth > 0)
		spinner = user
		to_chat(user, "<span class='notice'>You start weaving the flax into cloth.</span>")
		processing_objects.Add(src)
		playsound(src, 'sound/machines/loom_wooden_start.ogg', 10, 0)
		update_icon()
	else
		to_chat(user, "<span class='warning'>Can't use the wheel before some flax to weave has been added to it.</span>")

/obj/structure/spinning_wheel/attackby(var/obj/item/W, var/mob/user)
	if(W.is_wrench(user))
		W.playtoolsound(src, 100)
		user.visible_message("<span class='notice'>[user] starts disassembling \the [src].</span>", \
		"<span class='notice'>You start disassembling \the [src].</span>")
		if(do_after(user, src, 20))
			user.visible_message("<span class='warning'>[user] dissasembles \the [src].</span>", \
			"<span class='notice'>You dissasemble \the [src].</span>")
			var/turf/T = get_turf(src)
			new /obj/item/stack/sheet/wood(T, 10)
			for (var/i = 1 to round(remaining_cloth/CLOTH_PER_FLAX))
				new /obj/item/weapon/reagent_containers/food/snacks/grown/flax(T)
			qdel(src)
	else if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/grown/flax))
		if(user.drop_item(W, loc))
			remaining_cloth += CLOTH_PER_FLAX
			qdel(W)
			to_chat(user, "<span class='notice'>You prepare the flax to be weaved by the wheel.</span>")
			playsound(src, 'sound/items/bonegel.ogg', 50, 0)
			update_icon()
	else if (istype(W, /obj/item/weapon/storage/bag/plants))
		var/inserted = FALSE
		for (var/obj/item/weapon/reagent_containers/food/snacks/grown/flax/F in W.contents)
			remaining_cloth += CLOTH_PER_FLAX
			inserted = TRUE
			qdel(F)
		if (inserted)
			playsound(src, 'sound/items/bonegel.ogg', 50, 0)
			playsound(src, 'sound/effects/rustle3.ogg', 50, 0)
			to_chat(user, "<span class='notice'>You remove the flax from the bag and prepare it be weaved by the wheel.</span>")
			update_icon()
		else
			to_chat(user, "<span class='warning'>There is no flax in the bag.</span>")
	else
		..()

/obj/structure/spinning_wheel/process()
	set waitfor = FALSE

	if (!spinner || !Adjacent(spinner) || spinner.incapacitated() || spinner.lying || (remaining_cloth <= 0))
		spinner = null
		update_icon()
		processing_objects.Remove(src)
		return
	if (remaining_cloth > 0)
		playsound(src, 'sound/machines/loom_wooden.ogg', 20, 0)
		if (spawn_cloth(spinner))
			spawn(10)//process is called every 2 seconds, this lets us spawn 1 cloth per second
				spawn_cloth(spinner)


/obj/structure/spinning_wheel/proc/spawn_cloth(var/mob/_spinner)
	remaining_cloth--
	drop_stack(/obj/item/stack/sheet/cloth, loc, 1)
	if (remaining_cloth <= 0)
		to_chat(_spinner, "<span class='warning'>There [src] is out of flax.</span>")
		spinner = null
		update_icon()
		processing_objects.Remove(src)
		return 0
	return 1

/obj/structure/spinning_wheel/update_icon()
	if (spinner)
		icon_state = "wooden_loom_spin"
	else if (remaining_cloth > 0)
		icon_state = "wooden_loom_ready"
	else
		icon_state = "wooden_loom"


///////////////////ELECTRIC LOOM//////////////////////

/obj/machinery/electric_loom
	name = "electric loom"
	desc = "Automatically turns flax into cloth while powered. You can set input and output directions with a multitool."
	icon = 'icons/obj/clothes_making.dmi'
	icon_state = "electric_loom"
	density = 1
	anchored = 1

	var/remaining_cloth = 0
	var/stored_cloth = 0

/obj/machinery/electric_loom/attackby(var/obj/item/O, var/mob/user)
	..()