//NEVER USE THIS IT SUX	-PETETHEGOAT //Not any longer -Deity Link

var/global/list/cached_icons = list()
var/global/list/paint_types = subtypesof(/datum/reagent/paint)

/obj/item/weapon/reagent_containers/glass/paint
	name = "paint bucket"
	desc = "A bucket containing paint."
	icon = 'icons/obj/painting_items.dmi'
	icon_state = "paint_bucket"
	item_state = "paintcan"
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

/obj/item/weapon/reagent_containers/glass/paint/New()
	..()
	spots = icon(icon,"paint_spots")

/obj/item/weapon/reagent_containers/glass/paint/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] is taking \his hand and eating the [src.name]! It looks like \he's  trying to commit suicide!</span>")
	return (SUICIDE_ACT_TOXLOSS|SUICIDE_ACT_OXYLOSS)

/obj/item/weapon/reagent_containers/glass/paint/mop_act(obj/item/weapon/mop/M, mob/user)
	return 0

/obj/item/weapon/reagent_containers/glass/paint/afterattack(turf/simulated/target, mob/user , flag)
	if(!flag || user.stat)
		return ..()

	if(istype(target) && reagents.total_volume > 5)
		for(var/mob/O in viewers(user))
			O.show_message("<span class='warning'>\The [target] has been splashed with something by [user]!</span>", 1)
		spawn(5)
			reagents.reaction(target, TOUCH)
			reagents.remove_any(5)
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
	add_spots(2)

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

	if (reagents && reagents.total_volume)
		var/image/I = image(icon, src, "paint_inside")
		I.color = mix_color_from_reagents(reagents.reagent_list)
		I.alpha = mix_alpha_from_reagents(reagents.reagent_list)
		overlays += I

	if (flags & OPENCONTAINER)
		overlays += "paint_cover"
	/*
	var/image/balleft = image('icons/mob/in-hand/left/toys.dmi', src, "[icon_state]")
	var/image/balleftshine = image('icons/mob/in-hand/left/toys.dmi', src, "[icon_state]_shine")
	var/image/balright = image('icons/mob/in-hand/right/toys.dmi', src, "[icon_state]")
	var/image/balrightshine = image('icons/mob/in-hand/right/toys.dmi', src, "[icon_state]_shine")
	balleftshine.appearance_flags = RESET_COLOR
	balrightshine.appearance_flags = RESET_COLOR
	balleft.color = col
	balright.color = col
	balleft.overlays += balleftshine
	balright.overlays += balrightshine
	dynamic_overlay["[HAND_LAYER]-[GRASP_LEFT_HAND]"] = balleft
	dynamic_overlay["[HAND_LAYER]-[GRASP_RIGHT_HAND]"] = balright
	*/


/obj/item/weapon/reagent_containers/glass/paint/on_reagent_change()
	var/new_pigments = mix_color_from_reagents(reagents.reagent_list, TRUE)
	if (new_pigments)
		last_pigments = new_pigments
		name = "paint bucket ([get_paint_name(new_pigments)])"
	else
		name = "paint bucket"
	update_icon()

/obj/item/weapon/reagent_containers/glass/paint/clean_act(var/cleanliness)
	if (cleanliness >= CLEANLINESS_SPACECLEANER)
		color = ""
	if (cleanliness >= CLEANLINESS_BLEACH)
		spots = icon(icon,"paint_spots")
		last_pigments = ""
	on_reagent_change()

/obj/item/weapon/reagent_containers/glass/paint/proc/add_spots(var/spots_to_add = 1, var/color_override)
	if (!spots)
		spots = icon('icons/obj/painting_items.dmi',"paint_spots")
	var/spot_color = color_override
	if (!spot_color)
		spot_color = mix_color_from_reagents(reagents.reagent_list, TRUE)
	for (var/i = 1 to spots_to_add)
		var/icon/I = icon('icons/obj/painting_items.dmi', "paint_spots[rand(1,4)]")
		I.Blend(spot_color, ICON_MULTIPLY)
		spots.Blend(I, ICON_OVERLAY)
	update_icon()

/obj/item/weapon/reagent_containers/glass/paint/proc/get_paint_name(var/paint_name)
	var/list/known_paints = colors_acrylic_primary | colors_acrylic_secondary | colors_acrylic_tertiary | colors_acrylic_blackwhite | colors_acrylic_special | colors_nano_rgb
	if (paint_name in known_paints)
		return known_paints[paint_name]
	else
		return "[paint_name]"

//-------------------------------------------------------------------------------------------------

/obj/item/weapon/reagent_containers/glass/paint/filled
	last_pigments = "#FFFFFF"
	var/paint_color	= "#FFFFFF"
	var/paint_type	= ACRYLIC

/obj/item/weapon/reagent_containers/glass/paint/filled/New(turf/loc, var/p_type, var/p_color)
	..()
	if (p_type)
		paint_type = p_type
	if (p_color)
		paint_color = p_color
	reagents.add_reagent(paint_type, volume, list("color" = paint_color))
	update_icon()


/////////////////////////////////////////  REAGENTS  ////////////////////////////////////////////////

/*
	/datum/reagent/paint 			= Acrylic Paint
	/datum/reagent/paint/nanopaint	= Nano Paint
	/datum/reagent/paint_remover	= Acetone
	/datum/reagent/flaxoil			= Flax Oil
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

/datum/reagent/paint/reaction_turf(var/turf/T, var/volume)
	if(!istype(T) || istype(T, /turf/space))
		return
	var/ind = "[initial(T.icon)][color]"
	if(!cached_icons[ind])
		var/icon/overlay = new/icon(initial(T.icon))
		overlay.Blend(color,ICON_MULTIPLY)
		overlay.SetIntensity(1.4)
		T.icon = overlay
		cached_icons[ind] = T.icon
	else
		T.icon = cached_icons[ind]

//----------------------------------------------------------------------------------------------------

/datum/reagent/paint/nanopaint
	name = "Nano Paint"
	id = NANOPAINT
	description = "A paint with unaturally bright properties."

/datum/reagent/paint/nanopaint/handle_data_mix(var/list/added_data=null, var/added_volume, var/mob/admin)
	var/base_color = data["color"]
	var/added_color = base_color
	if (admin)
		added_color = input(admin,"Paint Color","Choose a Paint Color","#FFFFFF") as color
	else if (added_data)
		added_color = added_data["color"]
	data["color"] = BlendRGB(base_color, added_color, added_volume / (added_volume+volume))
	color = data["color"]

/datum/reagent/paint/nanopaint/handle_data_copy(var/list/added_data=null, var/added_volume, var/mob/admin)
	if (added_data)
		data["color"] = added_data["color"]
		color = data["color"]
	else if (admin)
		data["color"] = input(admin,"Paint Color","Choose a Paint Color","#FFFFFF") as color
		color = data["color"]

/datum/reagent/paint/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.adjustToxLoss(0.2)//nano paint is even more toxic yo

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


//----------------------------------------------------------------------------------------------------

/datum/reagent/flaxoil
	name = "Flax Oil"
	id = FLAXOIL
	description = "An oil used to create paints. Copies the coloration of surrounding reagents."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#303030"
	alpha = 100
	flags = CHEMFLAG_PIGMENT

//----------------------------------------------------------------------------------------------------

#define PAINT_CLEANER_THRESHOLD 0.7 // How much of the reagent should be water or some cleaner to clean paint off a canvas or brush
#define PAINT_CLEANER_AGENT_MULTIPLIER 2 // How effective cleaning products are, compared to water (aka they count as if there was n times water instead)

/proc/get_reagent_paint_cleaning_percent(obj/container)
	if(container.reagents)
		var/cleaner_volume = container.reagents.get_reagent_amount(WATER)
		cleaner_volume += container.reagents.get_reagent_amount(CLEANER) * PAINT_CLEANER_AGENT_MULTIPLIER
		cleaner_volume += container.reagents.get_reagent_amount("paint_remover") * PAINT_CLEANER_AGENT_MULTIPLIER
		return min(cleaner_volume > 0 ? cleaner_volume / container.reagents.total_volume : 0, 1)
	else
		return 0

#undef PAINT_CLEANER_AGENT_MULTIPLIER


var/list/colors_acrylic_primary = list(
	"#D52127" = "Red",
	"#FCED23" = "Yellow",
	"#2357BC" = "Blue",
)
var/list/colors_acrylic_secondary = list(
	"#F6851E" = "Orange",
	"#07B151" = "Green",
	"#733B97" = "Violet",
)
var/list/colors_acrylic_tertiary = list(
	"#F36621" = "Vermilion",
	"#FBB40F" = "Amber",
	"#AF3A94" = "Magenta",
	"#4C489B" = "Indigo",
	"#2FBBB3" = "Turquoise",
	"#8CC640" = "Chartreuse",
)
var/list/colors_acrylic_blackwhite = list(
	"#333333" = "Black",
	"#FFFFFF" = "White",
)
var/list/colors_acrylic_special = list(
	"#000000" = "Blackest Black",
	"#ED1871" = "Pinkest Pink",
)
var/list/colors_nano_rgb = list(
	"#FF0000" = "Red",
	"#00FF00" = "Green",
	"#0000FF" = "Blue",
)