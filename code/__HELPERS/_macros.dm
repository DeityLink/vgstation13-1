///MACRO FILE//
//Define your macros here if they're used in general code

//Typechecking macros
// fun if you want to typecast humans/monkeys/etc without writing long path-filled lines.
#define ishuman(A) istype(A, /mob/living/carbon/human)

#define isjusthuman(A) (ishuman(A) && A.species && istype(A.species, /datum/species/human))

#define ismonkey(A) istype(A, /mob/living/carbon/monkey)

#define isvox(A) (ishuman(A) && A.species && istype(A.species, /datum/species/vox))

#define isdiona(A) (ishuman(A) && A.species && istype(A.species, /datum/species/diona))

#define isgrey(A) (ishuman(A) && A.species && istype(A.species, /datum/species/grey))

#define isplasmaman(A) (ishuman(A) && A.species && istype(A.species, /datum/species/plasmaman))

#define isskellington(A) (ishuman(A) && A.species && istype(A.species, /datum/species/skellington))

#define iscatbeast(A) (ishuman(A) && A.species && istype(A.species, /datum/species/tajaran))

#define isunathi(A) (ishuman(A) && A.species && istype(A.species, /datum/species/unathi))

#define isskrell(A) (ishuman(A) && A.species && istype(A.species, /datum/species/skrell))

#define ismuton(A) (ishuman(A) && A.species && istype(A.species, /datum/species/muton))

#define isgolem(A) (ishuman(A) && A.species && istype(A.species, /datum/species/golem))

#define isslimeperson(A) (ishuman(A) && A.species && istype(A.species, /datum/species/slime))

#define ishorrorform(A) (ishuman(A) && A.species && istype(A.species, /datum/species/horror))

#define isgrue(A) (ishuman(A) && A.species && istype(A.species, /datum/species/grue))

#define isbrain(A) istype(A, /mob/living/carbon/brain)

#define isalien(A) istype(A, /mob/living/carbon/alien)

#define isalienadult(A) istype(A, /mob/living/carbon/alien/humanoid)

#define islarva(A) istype(A, /mob/living/carbon/alien/larva)

#define isslime(A) (istype(A, /mob/living/carbon/slime) || istype(A, /mob/living/simple_animal/slime))

#define isgremlin(A) (istype(A, /mob/living/simple_animal/hostile/gremlin))

#define isslimeadult(A) istype(A, /mob/living/carbon/slime/adult)

#define isrobot(A) istype(A, /mob/living/silicon/robot)

#define isanimal(A) istype(A, /mob/living/simple_animal)

#define iscorgi(A) istype(A, /mob/living/simple_animal/corgi)

#define iscrab(A) istype(A, /mob/living/simple_animal/crab)

#define iscat(A) istype(A, /mob/living/simple_animal/cat)

#define ismouse(A) istype(A, /mob/living/simple_animal/mouse)

#define isbear(A) istype(A, /mob/living/simple_animal/hostile/bear)

#define iscarp(A) istype(A, /mob/living/simple_animal/hostile/carp)

#define isclown(A) istype(A, /mob/living/simple_animal/hostile/retaliate/clown)

#define iscluwne(A) istype(A, /mob/living/simple_animal/hostile/retaliate/cluwne)

#define isAI(A) istype(A, /mob/living/silicon/ai)

#define isAIEye(A) istype(A, /mob/camera/aiEye)

#define ispAI(A) istype(A, /mob/living/silicon/pai)

#define iscarbon(A) istype(A, /mob/living/carbon)

#define issilicon(A) istype(A, /mob/living/silicon)

#define isMoMMI(A) istype(A, /mob/living/silicon/robot/mommi)

#define isbot(A) istype(A, /obj/machinery/bot)

#define isborer(A) istype(A, /mob/living/simple_animal/borer)

#define isshade(A) istype(A, /mob/living/simple_animal/shade)

#define isconstruct(A) istype(A, /mob/living/simple_animal/construct)

#define isliving(A) istype(A, /mob/living)

#define isobserver(A) istype(A, /mob/dead/observer)

#define isnewplayer(A) istype(A, /mob/new_player)

#define isovermind(A) istype(A, /mob/camera/blob)

#define isorgan(A) istype(A, /datum/organ/external)

#define isitem(A) istype(A, /obj/item)

#define isEmag(A) istype(A, /obj/item/weapon/card/emag)

#define istool(A) is_type_in_list(A, common_tools)

#define iswrench(A) istype(A, /obj/item/weapon/wrench)

#define iswelder(A) istype(A, /obj/item/weapon/weldingtool)

#define iscoil(A) istype(A, /obj/item/stack/cable_coil)

#define iscoin(A) is_type_in_list(A, list(/obj/item/weapon/coin, /obj/item/weapon/reagent_containers/food/snacks/chococoin))

#define iswirecutter(A) istype(A, /obj/item/weapon/wirecutters)

#define iswiretool(A) (iswirecutter(A) || ismultitool(A) || issignaler(A))

#define isscrewdriver(A) istype(A, /obj/item/weapon/screwdriver)

#define isbikehorn(A) istype(A, /obj/item/weapon/bikehorn)

#define ispowercell(A) istype(A, /obj/item/weapon/cell)

#define ismultitool(A) istype(A, /obj/item/device/multitool)

#define iscrowbar(A) istype(A, /obj/item/weapon/crowbar)

#define iswire(O) istype(O, /obj/item/stack/cable_coil)

#define issolder(A) istype(A, /obj/item/weapon/solder)

#define iscamera(A) istype(A, /obj/machinery/camera)

#define islightingoverlay(A) (istype(A, /atom/movable/lighting_overlay))

#define ischair(A) (istype(A, /obj/structure/bed/chair))

#define isvehicle(A) (istype(A, /obj/structure/bed/chair/vehicle))

#define issilicatesprayer(A) (istype(A, /obj/item/device/silicate_sprayer))

#define iswindow(A) (istype(A, /obj/structure/window))

#define isimage(A) (istype(A, /image))

#define isdatum(A) (istype(A, /datum))

#define isclient(A) (istype(A, /client))

#define isatom(A) (istype(A, /atom))

#define isatommovable(A) (istype(A, /atom/movable))

#define ismatrix(A) (istype(A, /matrix))

//Macros for antags

#define isvampire(H) H.mind && H.mind.GetRole(VAMPIRE)

#define iscult(H) H.mind && (iscultist(H) || faction == "cult")

#define iscultist(H) H.mind && H.mind.GetRole(CULTIST)

#define ischangeling(H) H.mind && H.mind.GetRole(CHANGELING)

#define isrev(H) H.mind && (H.mind.GetRole(REV) || isrevhead(H))

#define isrevhead(H) H.mind && H.mind.GetRole(HEADREV)

#define istraitor(H) H.mind && H.mind.GetRole(TRAITOR)

#define ismalf(H) H.mind && H.mind.GetRole(MALF)

#define isnukeop(H) H.mind && H.mind.GetRole(NUKE_OP)

#define iswizard(H) H.mind && H.mind.GetRole(WIZARD)

#define isapprentice(H) H.mind && H.mind.GetRole(WIZAPP)

#define isbadmonkey(H) ((/datum/disease/jungle_fever in H.viruses) || (H.mind && H.mind.GetRole(MADMONKEY)))

#define isdeathsquad(H) H.mind && H.mind.GetRole(DEATHSQUAD)




//Macro for AREAS!

#define isspace(A) (A.type == /area)

//This one returns the "space" area
//#define get_space_area (get_area(locate(1,1,2))) //xd
proc/get_space_area()
	//global.space_area is defined in code/game/areas/areas.dm, and set when the space area is created
	if(!global.space_area)
		var/area/new_space_area = new /area

		global.space_area = new_space_area

	return global.space_area

//1 line helper procs compressed into defines.
#define Clamp(x, y, z) 	(x <= y ? y : (x >= z ? z : x))
//x is the number you want to clamp
//y is the minimum
//z is the maximum

//Returns 1 if the variable contains a protected list that can't be edited
#define variable_contains_protected_list(var_name) (((var_name) == "contents") || ((var_name) == "locs") || ((var_name) == "vars"))

#define CLAMP01(x) 		(Clamp(x, 0, 1))

//CPU lag shit
#define calculateticks(x)	x * world.tick_lag // Converts your ticks to proper tenths.
#define tcheck(CPU,TOSLEEP)	if(world.cpu > CPU) sleep(calculateticks(TOSLEEP)) //Shorthand of checking and then sleeping a process based on world CPU

#define FOR_DVIEW(type, range, center, invis_flags) \
	dview_mob.loc = center;           \
	dview_mob.see_invisible = invis_flags; \
	for(type in view(range, dview_mob))

//get_turf(): Returns the turf that contains the atom.
//Example: A fork inside a box inside a locker will return the turf the locker is standing on.
//Yes, this is the fastest known way to do it.
#define get_turf(A) (get_step(A, 0))

//HARDCORE MODE STUFF (mainly hunger)

#define hardcore_mode_on (hardcore_mode)//((ticker) && (ticker.hardcore_mode))
#define eligible_for_hardcore_mode(M) (M.ckey && M.client)

//Helper macro for eggs, called in process() of all fertilized eggs. If it returns 0, the egg will no longer be able to hatch
#define is_in_valid_nest(egg) (isturf(egg.loc))


#define subtypesof(A) (typesof(A) - A)

#define LIBVG(function, arguments...) call("./libvg.[world.system_type == "UNIX" ? "so" : "dll"]", function)(arguments)
