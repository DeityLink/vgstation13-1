//NEVER USE THIS IT SUX	-PETETHEGOAT //Not any longer -Deity Link

var/global/list/cached_icons = list()
var/global/list/paint_types = subtypesof(/datum/reagent/paint)

/obj/item/weapon/reagent_containers/glass/paint
	name = "paint bucket"
	desc = "A bucket for storing acrylic paint."
	icon = 'icons/obj/painting_items.dmi'
	icon_state = "paint_bucket"
	item_state = "paint_bucket"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/arts_n_crafts.dmi', "right_hand" = 'icons/mob/in-hand/right/arts_n_crafts.dmi')
	starting_materials = list(MAT_IRON = 200)
	w_type = RECYK_METAL
	w_class = W_CLASS_MEDIUM
	melt_temperature = MELTPOINT_STEEL
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10,20,25,30,50,100,150)
	volume = 150
	flags = FPRINT | OPENCONTAINER
	var/icon/spots
	var/last_pigments = ""
	var/name_base = "paint bucket"
	var/icon_lid = "paint_cover"

/obj/item/weapon/reagent_containers/glass/paint/New()
	..()
	spots = icon(icon,"paint_spots")

/obj/item/weapon/reagent_containers/glass/paint/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is taking \his hand and eating the [src.name]! It looks like \he's  trying to commit suicide!</span>")
	return (SUICIDE_ACT_TOXLOSS|SUICIDE_ACT_OXYLOSS)

/obj/item/weapon/reagent_containers/glass/paint/mop_act(obj/item/weapon/mop/M, mob/user)
	return 0

/obj/item/weapon/reagent_containers/glass/paint/afterattack(var/atom/target, mob/user , flag)
	if(!flag || user.stat)
		return ..()

	if((flags & OPENCONTAINER) && (istype(target,/turf/simulated)||ismob(target)||isobj(target)) && reagents.total_volume >= 5)
		var/datum/reagent/R = reagents.get_master_reagent()
		target.visible_message("<span class='warning'>\The [target] has been splashed with [R.name] by \the [user]!</span>")
		reagents.reaction(target, TOUCH)
		reagents.remove_any(5)
		if (prob(50))
			add_spots()
		if (ismob(target)||isobj(target))
			var/pigment_rgb = mix_color_from_reagents(reagents.reagent_list, TRUE)
			if (pigment_rgb)
				var/mix_alpha = mix_alpha_from_reagents(reagents.reagent_list)
				var/turf/T = get_turf(target)
				if (target.loc == T)
					T.apply_paint_stroke(pigment_rgb, mix_alpha, SOUTH, "splatter")
					T.paint_overlay.wet(pigment_rgb,20 SECONDS,2)
					playsound(T, 'sound/effects/slosh.ogg', 25, 1)
	else
		return ..()

//manipulating the bucket causes it to spill some of its paint on itself, getting dirtier and dirtier
/obj/item/weapon/reagent_containers/glass/paint/pickup(var/mob/user)
	..()
	if (prob(10))
		add_spots()

/obj/item/weapon/reagent_containers/glass/paint/dropped(var/mob/user)
	..()
	if (prob(10))
		add_spots()

/obj/item/weapon/reagent_containers/glass/paint/attackby(var/obj/item/I, var/mob/user)
	..()
	if (prob(10))
		add_spots()

/obj/item/weapon/reagent_containers/glass/paint/throw_at(atom/target, range, speed)
	..()
	add_spots(2)

/obj/item/weapon/reagent_containers/glass/paint/throw_impact(var/atom/hit_atom, var/speed, var/mob/user)
	if (!(flags & OPENCONTAINER))
		return
	var/pigment_rgb = mix_color_from_reagents(reagents.reagent_list, TRUE)
	if (pigment_rgb)
		var/mix_alpha = mix_alpha_from_reagents(reagents.reagent_list)
		var/turf/T = get_turf(hit_atom)
		T.apply_paint_stroke(pigment_rgb, mix_alpha, SOUTH, "splatter")
		T.paint_overlay.wet(pigment_rgb,20 SECONDS,2)
		playsound(T, 'sound/effects/slosh.ogg', 25, 1)


/obj/item/weapon/reagent_containers/glass/paint/container_splash_sub(var/datum/reagents/reagents, var/atom/target, var/amount, var/mob/user = null)
	var/spot_color = mix_color_from_reagents(reagents.reagent_list, TRUE)
	if (!spot_color)
		return
	. = ..()
	if (. != -1)
		add_spots(3, spot_color)

/obj/item/weapon/reagent_containers/glass/paint/update_icon()
	..()

	overlays.len = 0
	overlays += spots

	if (last_pigments)
		var/image/I = image(icon, src, "paint_pigments")
		I.color = last_pigments
		overlays += I
		//dynamic in-hand overlay
		var/image/paintleft = image(inhand_states["left_hand"], src, "paint_pigments")
		var/image/paintright = image(inhand_states["right_hand"], src, "paint_pigments")
		paintleft.color = last_pigments
		paintright.color = last_pigments
		dynamic_overlay["[HAND_LAYER]-[GRASP_LEFT_HAND]"] = paintleft
		dynamic_overlay["[HAND_LAYER]-[GRASP_RIGHT_HAND]"] = paintright
	else
		dynamic_overlay = list()

	if (reagents && reagents.total_volume)
		var/image/I = image(icon, src, "paint_inside")
		I.color = mix_color_from_reagents(reagents.reagent_list)
		I.alpha = mix_alpha_from_reagents(reagents.reagent_list)
		overlays += I

	if (!(flags & OPENCONTAINER))
		overlays += icon_lid



/obj/item/weapon/reagent_containers/glass/paint/on_reagent_change()
	var/new_pigments = mix_color_from_reagents(reagents.reagent_list, TRUE)
	if (new_pigments)
		if (last_pigments != new_pigments)
			name = "[name_base] ([get_paint_name(new_pigments)])"
			last_pigments = new_pigments
	else
		name = name_base
	update_icon()

/obj/item/weapon/reagent_containers/glass/paint/clean_act(var/cleanliness)
	if (cleanliness >= CLEANLINESS_SPACECLEANER)
		color = ""
	if (cleanliness >= CLEANLINESS_BLEACH)
		spots = icon(icon,"paint_spots")
		last_pigments = ""
	on_reagent_change()

/obj/item/weapon/reagent_containers/glass/paint/proc/add_spots(var/spots_to_add = 1, var/color_override)
	if (!(flags & OPENCONTAINER))
		return
	if (!spots)
		spots = icon('icons/obj/painting_items.dmi',"paint_spots")
	var/spot_color = color_override
	if (!spot_color)
		spot_color = mix_color_from_reagents(reagents.reagent_list, TRUE)
	if (spot_color)
		for (var/i = 1 to spots_to_add)
			var/icon/I = icon('icons/obj/painting_items.dmi', "paint_spots[rand(1,4)]")
			I.Blend(spot_color, ICON_MULTIPLY)
			spots.Blend(I, ICON_OVERLAY)
		update_icon()

/obj/item/weapon/reagent_containers/glass/paint/proc/get_paint_name(var/paint_name)
	var/upper_name = uppertext(paint_name)
	if (upper_name in colors_all)
		return colors_all[upper_name]
	else
		return "[upper_name]"


//-------------------------------------------------------------------------------------------------

/obj/item/weapon/reagent_containers/glass/paint/metal
	name = "metal bucket"
	desc = "Can be used to store and carry reagents."
	name_base = "metal bucket"

//-------------------------------------------------------------------------------------------------

//Acrylic Paints
/obj/item/weapon/reagent_containers/glass/paint/filled
	last_pigments = "#FFFFFF"
	var/paint_color	= "#FFFFFF"

/obj/item/weapon/reagent_containers/glass/paint/filled/New(turf/loc, var/p_color)
	..()
	if (p_color)
		paint_color = p_color
	reagents.add_reagent(ACRYLIC, volume, list("color" = paint_color))

/obj/item/weapon/reagent_containers/glass/paint/filled/red
	paint_color	= "#D52127"
/obj/item/weapon/reagent_containers/glass/paint/filled/yellow
	paint_color	= "#FCED23"
/obj/item/weapon/reagent_containers/glass/paint/filled/blue
	paint_color	= "#2357BC"
/obj/item/weapon/reagent_containers/glass/paint/filled/orange
	paint_color	= "#F6851E"
/obj/item/weapon/reagent_containers/glass/paint/filled/green
	paint_color	= "#07B151"
/obj/item/weapon/reagent_containers/glass/paint/filled/violet
	paint_color	= "#733B97"
/obj/item/weapon/reagent_containers/glass/paint/filled/vermilion
	paint_color	= "#F36621"
/obj/item/weapon/reagent_containers/glass/paint/filled/amber
	paint_color	= "#FBB40F"
/obj/item/weapon/reagent_containers/glass/paint/filled/magenta
	paint_color	= "#AF3A94"
/obj/item/weapon/reagent_containers/glass/paint/filled/indigo
	paint_color	= "#4C489B"
/obj/item/weapon/reagent_containers/glass/paint/filled/turquoise
	paint_color	= "#2FBBB3"
/obj/item/weapon/reagent_containers/glass/paint/filled/chartreuse
	paint_color	= "#8CC640"
/obj/item/weapon/reagent_containers/glass/paint/filled/black
	paint_color	= "#111111"
/obj/item/weapon/reagent_containers/glass/paint/filled/white
	paint_color	= "#FFFFFF"

/obj/item/weapon/reagent_containers/glass/paint/filled/random/New(turf/loc, var/p_color)
	paint_color = pick(colors_all)
	..(loc, paint_color)

//Nano Paints
/obj/item/weapon/reagent_containers/glass/paint/rgb
	name = "nano-paint bucket"
	desc = "A bucket for storing paint composed of luminous nanomachines."
	icon_state = "nano_bucket"
	item_state = "nano_bucket"
	name_base = "nano-paint bucket"
	icon_lid = "nano_cover"

/obj/item/weapon/reagent_containers/glass/paint/rgb/filled
	last_pigments = "#FFFFFF"
	var/paint_color	= "#FFFFFF"

/obj/item/weapon/reagent_containers/glass/paint/rgb/filled/New(turf/loc, var/p_color)
	..()
	if (p_color)
		paint_color = p_color
	reagents.add_reagent(NANOPAINT, volume, list("color" = paint_color))

/obj/item/weapon/reagent_containers/glass/paint/rgb/filled/red
	paint_color	= "#FF0000"
/obj/item/weapon/reagent_containers/glass/paint/rgb/filled/green
	paint_color	= "#00FF00"
/obj/item/weapon/reagent_containers/glass/paint/rgb/filled/blue
	paint_color	= "#0000FF"
/obj/item/weapon/reagent_containers/glass/paint/rgb/filled/vantablack
	paint_color	= "#000000"


/////////////////////////////////////////  REAGENTS  ////////////////////////////////////////////////

/*
	/datum/reagent/paint 			= Acrylic Paint
	/datum/reagent/paint/nanopaint	= Nano Paint
	/datum/reagent/paint/flaxoil	= Flax Oil
	/datum/reagent/paint_remover	= Acetone
*/

/datum/reagent/paint
	name = "Acrylic Paint"
	id = ACRYLIC
	description = "Grab your brushes and paint rollers, and get creative."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#FFFFFF"
	density = 1.808
	specheatcap = 0.85
	flags = CHEMFLAG_PIGMENT
	data = list(
		"color" = "#FFFFFF",
		)

//Mixing Acrylic paints together blends them together using the RYB color space
/datum/reagent/paint/handle_data_mix(var/list/added_data=null, var/added_volume, var/mob/admin)
	var/base_color = data["color"]
	var/added_color = base_color
	if (admin)
		added_color = input(admin,"Paint Color","Choose a Paint Color","#FFFFFF") as color
	else if (added_data)
		added_color = added_data["color"]
	data["color"] = BlendRYB(added_color, base_color, added_volume / (added_volume+volume))
	color = data["color"]

/datum/reagent/paint/handle_data_copy(var/list/added_data=null, var/added_volume, var/mob/admin)
	if (added_data)
		data["color"] = added_data["color"]
		color = data["color"]
	else if (admin)
		data["color"] = input(admin,"Paint Color","Choose a Paint Color","#FFFFFF") as color
		color = data["color"]

/datum/reagent/paint/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.adjustToxLoss(0.3)//paint is toxic yo

/datum/reagent/paint/reaction_obj(var/obj/O, var/reac_volume)
	if(O)
		O.color = data["color"]

/datum/reagent/paint/reaction_turf(var/turf/T, var/volume, var/list/splashplosion=list())
	if(..())
		return TRUE

	var/turf/U = get_turf(holder.my_atom)
	if(isfloor(T))
		T.apply_paint_overlay(data["color"])
		if (splashplosion.len > 0)
			for (var/direction in cardinal)
				var/turf/R = get_step(T,direction)
				if (isfloor(R) && !(R in splashplosion) && T.Adjacent(R))
					if (get_dir(R,U) & get_dir(R,T))
						R.apply_paint_stroke(data["color"], 255, get_dir_cardinal(R,T), "border_splatter")
				else if (iswall(R) && !(R in splashplosion))
					if (get_dir(R,U) & get_dir(R,T))
						R.apply_paint_stroke(data["color"], 255, get_dir_cardinal(R,T), "wall_splatter")
	else if(iswall(T))
		if (T == U)
			T.apply_paint_overlay(data["color"])//if we're on top somehow, paint the whole tile
		else if (splashplosion.len > 0)
			for (var/direction in cardinal)
				var/turf/R = get_step(T,direction)
				if (isfloor(R) && (R in splashplosion))
					if (get_dir(T,U) & direction)
						T.apply_paint_stroke(data["color"], 255, get_dir_cardinal(T,R), "wall_splatter")
		else
			T.apply_paint_stroke(data["color"], 255, get_dir_cardinal(T,U), "wall_splatter")

//----------------------------------------------------------------------------------------------------

/datum/reagent/paint/nanopaint
	name = "Nano Paint"
	id = NANOPAINT
	description = "A paint with unaturally bright properties."

//Mixing Nano-paints together adds them together using the RGB color space
/datum/reagent/paint/nanopaint/handle_data_mix(var/list/added_data=null, var/added_volume, var/mob/admin)
	var/base_color = data["color"]
	var/added_color = base_color
	if (admin)
		added_color = input(admin,"Paint Color","Choose a Paint Color","#FFFFFF") as color
	else if (added_data)
		added_color = added_data["color"]
	data["color"] = AddRGB(base_color, added_color, added_volume / volume)
	color = data["color"]

/datum/reagent/paint/nanopaint/handle_data_copy(var/list/added_data=null, var/added_volume, var/mob/admin)
	if (added_data)
		data["color"] = added_data["color"]
		color = data["color"]
	else if (admin)
		data["color"] = input(admin,"Paint Color","Choose a Paint Color","#FFFFFF") as color
		color = data["color"]

/datum/reagent/paint/nanopaint/special_behaviour()
	//turning acrylic into more nano-paint while also mixing their colours
	for (var/datum/reagent/R in holder.reagent_list)
		if ((R.id == ACRYLIC) || (R.id == FLAXOIL))
			var/added_volume = R.volume
			var/added_color = R.data["color"]
			data["color"] = AddRGB(added_color, data["color"], volume / added_volume)
			color = data["color"]
			holder.del_reagent(R.id)
			volume += added_volume

/datum/reagent/paint/nanopaint/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.adjustToxLoss(0.2)//nano paint is even more toxic yo

//----------------------------------------------------------------------------------------------------

/datum/reagent/flaxoil
	name = "Flax Oil"
	id = FLAXOIL
	description = "An oil used in painting. Copies the coloration and opacity of reagents it is mixed with."
	color = "#303030"
	alpha = 100
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	density = 1.808
	specheatcap = 0.85
	flags = CHEMFLAG_PIGMENT
	data = list(
		"color" = "#303030",
		"alpha" = 100,
		)

/datum/reagent/flaxoil/handle_data_mix(var/list/added_data=null, var/added_volume, var/mob/admin)
	var/base_color = data["color"]
	var/base_alpha = data["alpha"]
	var/added_color = base_color
	var/added_alpha = base_alpha
	if (added_data)
		added_color = added_data["color"]
		added_alpha = added_data["alpha"]
	data["color"] = BlendRYB(added_color, base_color, added_volume / (added_volume+volume))
	color = data["color"]
	data["alpha"] = ((base_alpha * volume) + (added_alpha * added_volume)) / (added_volume+volume)
	alpha = data["alpha"]

/datum/reagent/flaxoil/handle_data_copy(var/list/added_data=null, var/added_volume, var/mob/admin)
	if (added_data)
		data["color"] = added_data["color"]
		color = data["color"]
		data["alpha"] = added_data["alpha"]
		alpha = data["alpha"]

/datum/reagent/flaxoil/special_behaviour()
	var/list/other_reagents = holder.reagent_list - src
	if (other_reagents.len <= 0)
		return
	var/target_color = mix_color_from_reagents(other_reagents)
	var/target_alpha = mix_alpha_from_reagents(other_reagents)
	data["color"] = BlendRYB(data["color"], target_color, 0.5)
	color = data["color"]
	data["alpha"] = (data["alpha"] + target_alpha) / 2
	alpha = data["alpha"]

/datum/reagent/flaxoil/reaction_turf(var/turf/T, var/volume)
	T.apply_paint_overlay(data["color"],data["alpha"])

//----------------------------------------------------------------------------------------------------

/datum/reagent/paint_remover
	name = "Acetone"
	id = ACETONE
	description = "Removes paint off floors, and everywhere else."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#808080"
	alpha = 50

/datum/reagent/paint_remover/reaction_turf(var/turf/T, var/volume)
	if(istype(T) && T.icon != initial(T.icon))
		T.icon = initial(T.icon)

/datum/reagent/paint_remover/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	for (var/datum/reagent/R in M.reagents.reagent_list)
		if (R.flags & CHEMFLAG_PIGMENT)
			M.reagents.remove_reagent(R.id, 2)

	if (tick < 50)
		if(prob(5))
			M.emote(pick("stare", "giggle"), null, null, TRUE)
	else
		if(prob(5))
			M.emote(pick("twitch","drool","moan"), null, null, TRUE)
		M.adjustBrainLoss(1)

//----------------------------------------------------------------------------------------------------

#define PAINT_CLEANER_THRESHOLD 0.7 // How much of the reagent should be water or some cleaner to clean paint off a canvas or brush
#define PAINT_CLEANER_AGENT_MULTIPLIER 2 // How effective cleaning products are, compared to water (aka they count as if there was n times water instead)

/proc/get_reagent_paint_cleaning_percent(obj/container)
	if(container.reagents)
		var/cleaner_volume = container.reagents.get_reagent_amount(WATER)
		cleaner_volume += container.reagents.get_reagent_amount(CLEANER) * PAINT_CLEANER_AGENT_MULTIPLIER
		cleaner_volume += container.reagents.get_reagent_amount(ACETONE) * PAINT_CLEANER_AGENT_MULTIPLIER
		return min(cleaner_volume > 0 ? cleaner_volume / container.reagents.total_volume : 0, 1)
	else
		return 0

#undef PAINT_CLEANER_AGENT_MULTIPLIER
