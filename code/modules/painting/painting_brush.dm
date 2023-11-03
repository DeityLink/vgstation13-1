/*
* Acts as a color picker:
* Use it on a reagent container and if it contains some pigments, it takes on their color. Use it on a canvas and you can paint with said color, or on the floor to write messages.
* If the mix has additional reagents with less alpha, the paint will be less opaque as well.
*
* Clean the brush by dipping it in water/space cleaner/paint cleaner
* A minimum percent of cleaning reagent out of total is needed, stronger cleaners require lower percentage.
*	eg: 5u water 5u blood won't be good for cleaning, but 9u water 1u blood will, and 5u cleaner 5u blood will too
* (made up units see PAINT_CLEANER_THRESHOLD and PAINT_CLEANER_AGENT_MULTIPLIER for actual units instead)
*
*/

/*

/obj/item/weapon/painting_brush
/obj/item/weapon/paint_roller

*/

/obj/item/weapon/painting_brush
	// Graphics stuff
	desc = "Horse hair on a stick, with a space age twist. Paint won't dry or run out on this"
	name = "painting brush"
	icon = 'icons/obj/painting_items.dmi'
	icon_state = "painting_brush"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/arts_n_crafts.dmi', "right_hand" = 'icons/mob/in-hand/right/arts_n_crafts.dmi')

	// Materials stuff
	w_class = W_CLASS_TINY
	starting_materials = list(MAT_WOOD = 23) //1cm wide, 30cm long
	autoignition_temperature=AUTOIGNITION_WOOD
	w_type = RECYK_WOOD
	siemens_coefficient = 0

	// Paint brush stuff
	var/paint_color = null
	var/nano_paint = FALSE
	var/list/blood_data = list("wet paint" = "paint")

/obj/item/weapon/painting_brush/update_icon()
	..()
	overlays.len = 0
	if (paint_color)
		var/image/covering = image(icon, src, "painting_brush_overlay")
		covering.icon += paint_color
		overlays += covering
		overlays += image(icon, src, "painting_brush_glint")
		//dynamic in-hand overlay
		var/image/paintleft = image(inhand_states["left_hand"], src, "brush_pigments")
		var/image/paintright = image(inhand_states["right_hand"], src, "brush_pigments")
		paintleft.icon += paint_color
		paintright.icon += paint_color
		dynamic_overlay["[HAND_LAYER]-[GRASP_LEFT_HAND]"] = paintleft
		dynamic_overlay["[HAND_LAYER]-[GRASP_RIGHT_HAND]"] = paintright
	else
		dynamic_overlay = list()
	update_blood_overlay()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()


/obj/item/weapon/painting_brush/afterattack(obj/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag == 0) // not adjacent
		return

	if(target.is_open_container() && target.reagents && !target.reagents.is_empty())
		// Figure out how much water or cleaner there is
		var/cleaner_percent = get_reagent_paint_cleaning_percent(target)

		if (cleaner_percent >= PAINT_CLEANER_THRESHOLD)
			// Clean up that brush
			paint_color = null
			nano_paint = FALSE
			to_chat(user, "<span class='notice'>You clean \the [name] in \the [target.name].</span>")
		else
			// Take the pigment mix's color
			var/paint_rgb = mix_color_from_reagents(target.reagents.reagent_list, TRUE)
			if (!paint_rgb)
				to_chat(user, "<span class='notice'>Your [name] fails to grab any pigment from \the [target.name].</span>")
				return
			var/list/paint_color_rgb = rgb2num(paint_rgb)
			paint_color = rgb(paint_color_rgb[1], paint_color_rgb[2], paint_color_rgb[3], mix_alpha_from_reagents(target.reagents.reagent_list))
			nano_paint = target.reagents.has_reagent(NANOPAINT)
			to_chat(user, "<span class='notice'>You dip \the [name] in \the [target.name].</span>")
			var/datum/reagent/B = get_blood(target.reagents)
			if (B)
				add_blood_from_data(B.data)
				blood_data = list(B.data["blood_DNA"] = B.data["blood_type"])
			else
				blood_data = list("wet paint" = "paint")
		update_icon()
	else if (isfloor(target))
		paint_doodle(user,target)

//presumably this will allow painting on the floor, credit to Anonymous user No.453861032
	if(istype(target, /turf/simulated)) 
		var/turf/simulated/the_turf = target
		var/datum/painting_utensil/p = new(user, src)
		if (!the_turf.advanced_graffiti)
			var/datum/custom_painting/advanced_graffiti = new(the_turf, 32, 32, base_color = "#00000000")
			the_turf.advanced_graffiti = advanced_graffiti
		the_turf.advanced_graffiti.interact(user, p)
		return

/obj/item/weapon/painting_brush/clean_act(var/cleanliness)
	paint_color = null
	nano_paint = FALSE
	update_icon()

/obj/item/weapon/painting_brush/proc/paint_doodle(var/mob/living/user, var/turf/T)
	if (!paint_color)
		to_chat(user, "<span class='warning'>There is no paint on your brush.</span>")
		return

	if (!isfloor(T))
		to_chat(user, "<span class='warning'>You can only doodle over floors.</span>")
		return

	for (var/obj/effect/decal/cleanable/blood/writing/W in T)
		to_chat(user, "<span class='warning'>This floor is already filled with writings.</span>")
		return

	var/max_length = 30//same as bloody doodles
	var/message = stripped_input(user,"Write a message. You will be able to preview it.","Painted writings", "")

	if (!message)
		return

	message = copytext(message, 1, max_length)

	var/letter_amount = length(replacetext(message, " ", ""))
	if(!letter_amount) //If there is no text
		return

	//Previewing our message
	var/image/I = image(icon = null)
	I.maptext = {"<span style="color:[paint_color];font-size:9pt;font-family:'Bloody';" align="center" valign="top">[message]</span>"}
	I.maptext_height = 32
	I.maptext_width = 64
	I.maptext_x = -16
	I.maptext_y = -2
	I.loc = T
	I.alpha = 180

	user.client.images.Add(I)
	var/continue_drawing = alert(user, "This is how your message will look. Continue?", "Painted writings", "Yes", "Cancel")

	user.client.images.Remove(I)
	animate(I)
	I.loc = null
	qdel(I)

	if(continue_drawing != "Yes" || !user.Adjacent(T))
		return

	//Painting our message
	var/obj/effect/decal/cleanable/blood/writing/W = new /obj/effect/decal/cleanable/blood/writing(T)
	W.basecolor = paint_color
	W.color = paint_color//so alpha gets applied as well
	W.maptext = {"<span style="color:#FFFFFF;font-size:9pt;font-family:'Bloody';" align="center" valign="top">[message]</span>"}
	var/invisible = user.invisibility || !user.alpha
	W.visible_message("<span class='warning'>[invisible ? "An invisible brush" : "\The [user]"] paints something on \the [T]...</span>")
	W.blood_DNA = blood_data.Copy()

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/paint_roller
	name = "paint roller"
	desc = "Used to cover floors in paint more efficiently than by just dumping buckets on them"
	icon = 'icons/obj/painting_items.dmi'
	icon_state = "paint_roller"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/arts_n_crafts.dmi', "right_hand" = 'icons/mob/in-hand/right/arts_n_crafts.dmi')

	// Materials stuff
	w_class = W_CLASS_TINY
	starting_materials = list(MAT_PLASTIC = 50)
	autoignition_temperature=AUTOIGNITION_PLASTIC
	w_type = RECYK_PLASTIC
	siemens_coefficient = 0

	// Paint brush stuff
	var/paint_color = null
	var/paint_alpha = 255
	var/nano_paint = FALSE
	var/list/blood_data = list("wet paint" = "paint")

/obj/item/weapon/paint_roller/clean_act(var/cleanliness)
	paint_color = null
	nano_paint = FALSE
	update_icon()

/obj/item/weapon/paint_roller/afterattack(obj/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag == 0) // not adjacent
		return

	if(target.is_open_container() && target.reagents && !target.reagents.is_empty())
		var/cleaner_percent = get_reagent_paint_cleaning_percent(target)

		if (cleaner_percent >= PAINT_CLEANER_THRESHOLD)
			paint_color = null
			nano_paint = FALSE
			to_chat(user, "<span class='notice'>You clean \the [name] in \the [target.name].</span>")
		else
			// Take the pigment mix's color
			var/paint_rgb = mix_color_from_reagents(target.reagents.reagent_list, TRUE)
			if (!paint_rgb)
				to_chat(user, "<span class='notice'>Your [name] fails to grab any pigment from \the [target.name].</span>")
				return
			var/list/paint_color_rgb = rgb2num(paint_rgb)
			var/mix_alpha = mix_alpha_from_reagents(target.reagents.reagent_list)
			paint_color = rgb(paint_color_rgb[1], paint_color_rgb[2], paint_color_rgb[3], mix_alpha)
			paint_alpha = mix_alpha
			nano_paint = target.reagents.has_reagent(NANOPAINT)
			to_chat(user, "<span class='notice'>You dip \the [name] in \the [target.name].</span>")
			var/datum/reagent/B = get_blood(target.reagents)
			if (B)
				add_blood_from_data(B.data)
				blood_data = list(B.data["blood_DNA"] = B.data["blood_type"])
			else
				blood_data = list("wet paint" = "paint")
		update_icon()
	else if (isfloor(target))
		var/turf/F = target
		if (!paint_color)
			to_chat(user, "<span class='warning'>There is no paint on your roller.</span>")
			return
		var/turf/T = get_turf(user)
		var/_dir = user.dir
		if (T != F)
			_dir = get_dir_cardinal(F,T)
		F.apply_paint_stroke(paint_color, paint_alpha, _dir, "border_roller", blood_data)
		playsound(src, get_sfx("mop"), 5, 1)

/obj/item/weapon/paint_roller/update_icon()
	..()
	overlays.len = 0
	if (paint_color)
		var/image/covering = image(icon, src, "paint_roller_overlay")
		covering.color = paint_color
		overlays += covering
		//dynamic in-hand overlay
		var/image/paintleft = image(inhand_states["left_hand"], src, "paint_roller_pigments")
		var/image/paintright = image(inhand_states["right_hand"], src, "paint_roller_pigments")
		paintleft.color = paint_color
		paintright.color = paint_color
		dynamic_overlay["[HAND_LAYER]-[GRASP_LEFT_HAND]"] = paintleft
		dynamic_overlay["[HAND_LAYER]-[GRASP_RIGHT_HAND]"] = paintright
	else
		dynamic_overlay = list()
	update_blood_overlay()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()
