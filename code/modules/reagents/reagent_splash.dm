
//Hits every turfs in view and their content with our reagents (provided they are not blocked by windows or other turfs)
/datum/reagents/proc/splashplosion(var/range=3)
	if (reagent_list.len <= 0)
		return

	var/list/hit_turfs = list()
	var/turf/epicenter = get_turf(my_atom)

	var/datum/effect/system/steam_spread/steam = new /datum/effect/system/steam_spread()
	steam.set_up(10, 0, get_turf(src), mix_color_from_reagents(reagent_list))
	steam.attach(src)
	steam.start()

	for(var/turf/T in dview(range, epicenter, INVISIBILITY_MAXIMUM))
		if (cheap_pythag(T.x - epicenter.x,T.y - epicenter.y) <= range + 0.5)
			if (test_reach(epicenter,T,PASSTABLE|PASSGRILLE|PASSMOB|PASSMACHINE|PASSGIRDER))
				hit_turfs += T

	for(var/datum/reagent/R in reagent_list)
		var/volume_per_tile = max(1,R.volume/hit_turfs.len)//the volume is split between all turfs hit. The less turfs hit, the more concentrated the splashing.

		for (var/turf/T in hit_turfs)
			if (!T.density)
				for (var/atom/movable/AM in T.contents)
					if (ismob(AM))
						if (isanimal(AM))
							R.reaction_animal(AM, TOUCH, volume_per_tile,hit_turfs)
						else
							R.reaction_mob(AM, TOUCH, volume_per_tile, ALL_LIMBS,hit_turfs)
					else if (isobj(AM))
						R.reaction_obj(AM, volume_per_tile,hit_turfs)
			R.reaction_turf(T, volume_per_tile,hit_turfs)

	clear_reagents()
