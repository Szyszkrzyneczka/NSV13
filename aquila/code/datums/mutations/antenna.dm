/datum/mutation/human/mindreader
	name = "Mind Reader"
	desc = "The affected person can look into the recent memories of others."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>You hear distant voices at the corners of your mind.</span>"
	text_lose_indication = "<span class='notice'>The distant voices fade.</span>"
	power = /obj/effect/proc_holder/spell/targeted/mindread
	instability = 40
	difficulty = 8
	locked = TRUE

/obj/effect/proc_holder/spell/targeted/mindread
	name = "Mindread"
	desc = "Read the target's mind."
	charge_max = 50
	range = 7
	clothes_req = FALSE
	action_icon_state = "mindread"

/obj/effect/proc_holder/spell/targeted/mindread/cast(list/targets, mob/living/carbon/human/user = usr)
	for(var/mob/living/M in targets)
		if(istype(usr.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/foilhat) || istype(M.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/foilhat))
			to_chat(usr, "<span class='warning'>As you reach out with your mind, you're suddenly stopped by a vision of a massive tinfoil wall that streches beyond visible range. It seems you've been foiled.</span>")
			return
		if(M.stat == DEAD)
			to_chat(user, "<span class='boldnotice'>[M] is dead!</span>")
			return
		if(M.mind)
			to_chat(user, "<span class='boldnotice'>You plunge into [M]'s mind...</span>")
			if(prob(20))
				to_chat(M, "<span class='danger'>You feel something foreign enter your mind.</span>")//chance to alert the read-ee
			var/list/recent_speech = list()
			var/list/say_log = list()
			var/log_source = M.logging
			for(var/log_type in log_source)//this whole loop puts the read-ee's say logs into say_log in an easy to access way
				var/nlog_type = text2num(log_type)
				if(nlog_type & LOG_SAY)
					var/list/reversed = log_source[log_type]
					if(islist(reversed))
						say_log = reverseRange(reversed.Copy())
						break
			if(LAZYLEN(say_log))
				for(var/spoken_memory in say_log)
					if(recent_speech.len >= 3)//up to 3 random lines of speech, favoring more recent speech
						break
					if(prob(50))
						recent_speech[spoken_memory] = say_log[spoken_memory]
			if(recent_speech.len)
				to_chat(user, "<span class='boldnotice'>You catch some drifting memories of their past conversations...</span>")
				for(var/spoken_memory in recent_speech)
					to_chat(user, "<span class='notice'>[recent_speech[spoken_memory]]</span>")
			if(iscarbon(M))
				var/mob/living/carbon/human/H = M
				to_chat(user, "<span class='boldnotice'>You find that their intent is to [H.a_intent]...</span>")
				var/datum/dna/the_dna = H.has_dna()
				if(the_dna)
					to_chat(user, "<span class='boldnotice'>You uncover that their true identity is [the_dna.real_name].</span>")
		else
			to_chat(user, "<span class='boldnotice'>You can't find a mind to read inside of [M].</span>")

/datum/mutation/human/mindreader/New(class_ = MUT_OTHER, timer, datum/mutation/human/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "antenna", -FRONT_MUTATIONS_LAYER+1))

/datum/mutation/human/mindreader/get_visual_indicator()
	return visual_indicators[type][1]
