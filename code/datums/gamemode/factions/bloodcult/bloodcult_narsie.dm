

/datum/zLevel/narsie
	name = "realm of Nar-Sie"
	base_turf = /turf/unsimulated/wall/bloodrealm
	base_area = /area/narsie
	teleJammed = 1
	movementJammed = 1
	bluespace_jammed = 1

/area/narsie
	name = "\improper Realm of Nar-Sie"
	requires_power = 0
	dynamic_lighting = 1

//this adds an empty Z Level full of blood clots that we'll be able to carve during the round.
proc/create_bloodrealm()
	for(var/datum/zLevel/z in map.zLevels)
		if (z.name == "realm of Nar-Sie")
			return
	world.maxz += 1
	map.addZLevel(new /datum/zLevel/narsie, world.maxz, TRUE, TRUE)
	bloodZ = world.maxz

/obj/structure/greasy_junk
