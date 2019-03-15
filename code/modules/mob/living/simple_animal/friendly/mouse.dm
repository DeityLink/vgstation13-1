#define MOUSETFAT 1000
#define MOUSEFAT 600
#define MOUSESTARVE 25
#define MOUSEHUNGRY 100
#define MOUSEMOVECOST 1
#define MOUSESTANDCOST 0.5

/mob/living/simple_animal/mouse
	name = "mouse"
	real_name = "mouse"
	var/namenumbers = TRUE
	desc = "It's a small, disease-ridden rodent."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	speak = list("Squeek!","SQUEEK!","Squeek?")
	speak_emote = list("squeeks","squeeks","squiks")
	emote_hear = list("squeeks","squeaks","squiks")
	emote_see = list("runs in a circle", "shakes", "scritches at something")
	pass_flags = PASSTABLE
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 5
	health = 5
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "stamps on the"
	density = 0
	var/_color //brown, gray and white, leave blank for random
	min_oxy = 16 //Require atleast 16kPA oxygen
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius
	universal_speak = 0
	treadmill_speed = 0.2 //You can still do it, but you're not going to generate much power.
	speak_override = FALSE

	size = SIZE_TINY
	holder_type = /obj/item/weapon/holder/animal/mouse
	held_items = list()
	var/obj/item/weapon/reagent_containers/food/snacks/food_target //What food we're walking towards
	var/is_fat = 0
	var/can_chew_wires = 0
	var/splat = 0

/mob/living/simple_animal/mouse/Life()
	if(timestopped)
		return 0 //under effects of time magick
	..()
	if(!stat && prob(speak_chance))
		for(var/mob/M in view())
			M << 'sound/effects/mousesqueek.ogg'

	if(!ckey && stat == CONSCIOUS && prob(0.5))
		stat = UNCONSCIOUS
		icon_state = "mouse_[_color]_sleep"
		wander = 0
		speak_chance = 0
		//snuffles
	else if(stat == UNCONSCIOUS)
		if(ckey || prob(1))
			stat = CONSCIOUS
			icon_state = "mouse_[_color]"
			wander = 1
			speak_chance = initial(speak_chance)
		else if(prob(5))
			emote("me", EMOTE_AUDIBLE, "snuffles")

	if(nutrition >= MOUSETFAT)
		visible_message("<span class = 'warning'>\The [src] explodes!</span>")
		gib()
		return

	if(nutrition >= MOUSEFAT && is_fat == 0)
		is_fat = 1
		speed = 6
		meat_amount += 1
	else if ((nutrition <= MOUSEFAT-25 && is_fat == 1) || (nutrition > MOUSEHUNGRY && is_fat == 0))
		is_fat = 0
		speed = initial(speed)
		meat_amount = size //What it is on living/New(),
	if(nutrition <= MOUSESTARVE && prob(5) && client)
		to_chat(src, "<span class = 'warning'>You are starving!</span>")
		health -= 1
	if(nutrition <= MOUSEHUNGRY && nutrition > MOUSESTARVE)
		speed = 3
		if(prob(5))
			to_chat(src, "<span class = 'warning'>You are getting hungry!</span>")

	find_nearby_disease()//getting diseases from

	if(SSair.current_cycle%4==2)//Only try to breath diseases every 4 seconds
		breath_airborne_diseases()

	for (var/mob/living/simple_animal/mouse/M in range(1,src))
		share_contact_diseases(M)

	if(!isUnconscious())
		var/list/can_see() = view(src, 5) //Decent radius, not too large so they're attracted across rooms, but large enough to attract them to mousetraps

		if(!food_target && (!client || nutrition <= MOUSEHUNGRY)) //Regular mice will be moved towards food, mice with a client won't be moved unless they're desperate
			for(var/obj/item/weapon/reagent_containers/food/snacks/C in can_see)
				food_target = C
				break
		if(!(food_target in can_see))
			food_target = null
		if(food_target)
			step_towards(src, food_target)
			if(Adjacent(food_target))
				food_target.attack_animal(src)

		if(prob(10))

			if(!client)
				if(can_chew_wires)
					for(var/obj/structure/cable/C in can_see)
						if(Adjacent(C))
							C.attack_animal(src)
							break
						else
							step_towards(src, C)
							break
				/*
				if(virus2.len > 0)
					for(var/mob/living/carbon/human/H in can_see)
						if(Adjacent(H))
							visible_message("[src] bites [H]")
							H.attack_animal(src)
							break
						else
							step_towards(src, H)
							break
				*/
/*
			if(virus2.len > 0)
				for(var/mob/living/M in view(1,src))
					//spread_disease_to(src,M, "Airborne") //Spreads it to humans, mice, and monkeys

*/
		nutrition = max(0, nutrition - MOUSESTANDCOST)

/mob/living/simple_animal/mouse/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	..()
	var/multiplier = 1
	if(nutrition >= MOUSEFAT) //Fat mice lose nutrition faster through movement
		multiplier = 2.5
	nutrition = max(0, nutrition - MOUSEMOVECOST*multiplier)

/mob/living/simple_animal/mouse/New()
	..()
	if(config && config.uneducated_mice)
		universal_understand = 0
	// Mice IDs
	if(namenumbers)
		name = "[name] ([rand(1, 1000)])"
	real_name = name
	if(!_color)
		_color = pick( list("brown","gray","white") )
	icon_state = "mouse_[_color]"
	icon_living = "mouse_[_color]"
	icon_dead = "mouse_[_color]_dead"
	desc = "It's a small [_color] rodent, often seen hiding in maintenance areas and making a nuisance of itself."
	add_language(LANGUAGE_MOUSE)
	default_language = all_languages[LANGUAGE_MOUSE]
	hud_list[STATUS_HUD]      = image('icons/mob/hud.dmi', src, "hudhealthy")
/*
/mob/living/simple_animal/mouse/unarmed_attack_mob(mob/living/target)
	..()
	if(target.can_be_infected())
		//spread_disease_to(src, target, "Contact")
*/
/mob/living/simple_animal/mouse/proc/nutrstats()
	stat(null, "Nutrition level - [nutrition]")

/mob/living/simple_animal/mouse/Stat()
	..()
	if(statpanel("Status"))
		nutrstats()

/mob/living/simple_animal/mouse/examine(mob/user)
	..()
	if(!isDead())
		if(is_fat)
			to_chat(user, "<span class='info'>It seems well fed.</span>")
		if(can_chew_wires)
			to_chat(user, "<span class='notice'>It seems a bit frazzled.</span>")
		if(virus2.len > 0)
			to_chat(user, "<span class='blob'>It seems unwell.</span>")
		if(nutrition <= MOUSEHUNGRY)
			to_chat(user, "<span class = 'danger'>It seems a bit hungry.</span>")

/mob/living/simple_animal/mouse/proc/splat()
	death()
	splat = 1
	src.icon_dead = "mouse_[_color]_splat"
	src.icon_state = "mouse_[_color]_splat"
	if(client)
		client.time_died_as_mouse = world.time

//copy paste from alien/larva, if that func is updated please update this one also
/mob/living/simple_animal/mouse/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Object"
	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl(pipe)


//copy paste from alien/larva, if that func is updated please update this one also
/mob/living/simple_animal/mouse/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Object"

	if(isUnconscious())
		return

	if (plane != HIDING_MOB_PLANE)
		plane = HIDING_MOB_PLANE
		to_chat(src, text("<span class='notice'>You are now hiding.</span>"))
		/*
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				to_chat(O, text("<B>[] scurries to the ground!</B>", src))
		*/
	else
		plane = MOB_PLANE
		to_chat(src, text("<span class='notice'>You have stopped hiding.</span>"))
		/*
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				to_chat(O, text("[] slowly peaks up from the ground...", src))
		*/

//make mice fit under tables etc? this was hacky, and not working
/*
/mob/living/simple_animal/mouse/Move(var/dir)

	var/turf/target_turf = get_step(src,dir)
	//CanReachThrough(src.loc, target_turf, src)
	var/can_fit_under = 0
	if(target_turf.ZCross(get_turf(src),1))
		can_fit_under = 1

	..(dir)
	if(can_fit_under)
		src.forceMove(target_turf)
	for(var/d in cardinal)
		var/turf/O = get_step(T,d)
		//Simple pass check.
		if(O.ZCross(T, 1) && !(O in open) && !(O in closed) && O in possibles)
			open += O
			*/

///mob/living/simple_animal/mouse/restrained() //Hotfix to stop mice from doing things with MouseDrop
//	return 1

/mob/living/simple_animal/mouse/scoop_up(var/mob/living/M)
	if (..())
		var/block = M.check_contact_sterility(HANDS)
		var/bleeding = M.check_bodypart_bleeding(HANDS)
		share_contact_diseases(M,block,bleeding)

/mob/living/simple_animal/mouse/Crossed(AM as mob|obj)
	if( ishuman(AM) )
		var/mob/living/carbon/human/M = AM
		if(!stat)
			to_chat(M, "<span class='notice'>[bicon(src)] Squeek!</span>")
			M << 'sound/effects/mousesqueek.ogg'

		var/block = 0
		var/bleeding = 0
		if (lying)
			block = M.check_contact_sterility(FULL_TORSO)
			bleeding = M.check_bodypart_bleeding(FULL_TORSO)
		else
			block = M.check_contact_sterility(FEET)
			bleeding = M.check_bodypart_bleeding(FEET)

		//sharing diseases with people stepping on us
		share_contact_diseases(M,block,bleeding)
	..()

/mob/living/simple_animal/mouse/death(var/gibbed = FALSE)
	if(client)
		client.time_died_as_mouse = world.time
	..(gibbed)

/*
 * Mouse types
 */

/mob/living/simple_animal/mouse/white
	_color = "white"
	icon_state = "mouse_white"

/mob/living/simple_animal/mouse/gray
	_color = "gray"
	icon_state = "mouse_gray"

/mob/living/simple_animal/mouse/brown
	_color = "brown"
	icon_state = "mouse_brown"

/mob/living/simple_animal/mouse/black
	_color = "black"
	icon_state = "mouse_black"

//TOM IS ALIVE! SQUEEEEEEEE~K :)
/mob/living/simple_animal/mouse/brown/Tom
	name = "Tom"
	namenumbers = FALSE
	desc = "Jerry the cat is not amused."
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "splats"

/mob/living/simple_animal/mouse/black/dessert
	name = "Dessert"
	namenumbers = FALSE
	desc = "Crunchy!"
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "tenderizes"

/mob/living/simple_animal/mouse/say_quote(text)
	if(!text)
		return "squeaks, \"...\"";	//not the best solution, but it will stop a large number of runtimes. The cause is somewhere in the Tcomms code
	return "squeaks, [text]";

/mob/living/simple_animal/mouse/singularity_act()
	if(!(src.flags & INVULNERABLE))
		investigation_log(I_SINGULO,"has been consumed by a singularity")
		gib()
		return 0

/mob/living/simple_animal/mouse/wire_biter
	can_chew_wires = 1

/mob/living/simple_animal/mouse/can_be_infected()
	return 1
