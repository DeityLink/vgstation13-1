
/*

/obj/blood_dimension_object
/obj/machinery/blood_dimension_machine

*/

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

//gives objects a "greasy" look
/obj/proc/greasify()
	if (greased_up)
		return
	greased_up = image('icons/turf/bloodrealm.dmi',src,"grease2")
	greased_up.blend_mode = BLEND_INSET_OVERLAY
	appearance_flags |= KEEP_TOGETHER
	overlays += greased_up

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

/////////////////////LIGHT SOURCES////////////////////////////////////////

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