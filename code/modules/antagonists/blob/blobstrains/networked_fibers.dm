//does massive brute and burn damage, but can only expand manually
/datum/blobstrain/reagent/networked_fibers
	name = "Sowa Włóknista"
	description = "zadajesz bardzo poważne obrażenia fizyczne oraz ciężkie poparzenia, oraz generujesz zasoby szybciej, ale możesz tylko rozprzestrzeniać się manualnie."
	shortdesc = "zadajesz wysokie obrażenia fizyczne oraz poważne poparzenia."
	effectdesc = "twój rdzeń zostanie przesunięty jeżeli rozprzestrzenisz się w jego pobliżu."
	analyzerdescdamage = "zadaje wysokie obrażenia fizyczne oraz poważne poparzenia."
	analyzerdesceffect = "jest wysoce mobilny oraz szybciej generuje zasoby."
	color = "#CDC0B0"
	complementary_color = "#FFF68F"
	reagent = /datum/reagent/blob/networked_fibers

/datum/blobstrain/reagent/networked_fibers/expand_reaction(obj/structure/blob/B, obj/structure/blob/newB, turf/T, mob/camera/blob/O)
	if(!O && newB.overmind)
		if(!istype(B, /obj/structure/blob/node))
			newB.overmind.add_points(1)
			qdel(newB)
	else
		var/area/A = get_area(T)
		if(!isspaceturf(T) && !istype(A, /area/shuttle))
			for(var/obj/structure/blob/core/C in range(1, newB))
				if(C.overmind == O)
					newB.forceMove(get_turf(C))
					C.forceMove(T)
					C.setDir(get_dir(newB, C))
					O.add_points(1)

//does massive brute and burn damage, but can only expand manually
/datum/reagent/blob/networked_fibers
	name = "Networked Fibers"
	taste_description = "efficiency"
	color = "#CDC0B0"
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN

/datum/reagent/blob/networked_fibers/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	reac_volume = ..()
	M.apply_damage(0.6*reac_volume, BRUTE)
	if(M)
		M.apply_damage(0.6*reac_volume, BURN)
