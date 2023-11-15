/*

/obj/structure/spinning_wheel
/obj/machinery/electric_loom

*/

////////////////////MANUAL LOOM//////////////////////

/obj/structure/spinning_wheel
	name = "spinning wheel"
	desc = " "
	icon = 'icons/obj/clothes_making.dmi'
	icon_state = "wooden_loom"
	density = 1
	anchored = 0

	var/inserted_flax = 0


///////////////////ELECTRIC LOOM//////////////////////

/obj/machinery/electric_loom
	name = "electric loom"
	desc = "Automatically turns flax into cloth while powered. You can set input and output directions with a multitool."
	icon = 'icons/obj/clothes_making.dmi'
	icon_state = "electric_loom"
	density = 1
	anchored = 1

	var/inserted_flax = 0
	var/stored_cloth = 0