/*
	MouseDrop:

	Called on the atom you're dragging.  In a lot of circumstances we want to use the
	receiving object instead, so that's the default action.  This allows you to drag
	almost anything into a trash can.
*/
/atom/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	if(!usr || !over)
		return
	if(SEND_SIGNAL(src, COMSIG_MOUSEDROP_ONTO, over, usr) & COMPONENT_NO_MOUSEDROP)	//Whatever is receiving will verify themselves for adjacency.
		return
	if(over == src)
		return usr.client.Click(src, src_location, src_control, params)
	if(!Adjacent(usr) || !over.Adjacent(usr))
		return // should stop you from dragging through windows

	over.MouseDrop_T(src,usr)
	return

// receive a mousedrop
/atom/proc/MouseDrop_T(atom/dropping, mob/user)
	SEND_SIGNAL(src, COMSIG_MOUSEDROPPED_ONTO, dropping, user)
	return

/client
	var/obj/active_mousedown_item = null //NSV13 - changed from obj/item to obj
	var/middragtime = 0
	var/atom/middragatom

//Nsv13 - This proc has been extensively changed to handle auto-firing in a slightly more sane way which shouldn't cause people to get kicked by the anti-spam defenses...

/client/MouseDown(object, location, control, params)
	if (mouse_down_icon)
		mouse_pointer_icon = mouse_down_icon
	active_mousedown_item = mob.canMobMousedown(object, location, params)
	if(active_mousedown_item)
		//NSV13 type conversion before mousedown - formerly active_mousedown_item.onMouseDown(object, location, params, mob)
		if(istype(active_mousedown_item, /obj/item))
			var/obj/item/I = active_mousedown_item
			I.onMouseDown(object, location, params, mob)
		else if(istype(active_mousedown_item, /obj/structure/overmap))
			var/obj/structure/overmap/OM = active_mousedown_item
			OM.onMouseDown(object, location, params, mob)
		//NSV13 end


/client/MouseUp(object, location, control, params)
	if (mouse_up_icon)
		mouse_pointer_icon = mouse_up_icon
	if(active_mousedown_item)
		//NSV13 type conversion before mouseup - formerly active_mousedown_item.onMouseUp(object, location, params, mob)
		if(istype(active_mousedown_item, /obj/item))
			var/obj/item/I = active_mousedown_item
			I.onMouseUp(object, location, params, mob)
		else if(istype(active_mousedown_item, /obj/structure/overmap))
			var/obj/structure/overmap/OM = active_mousedown_item
			OM.onMouseUp(object, location, params, mob)
		//NSV13 end
		active_mousedown_item = null

/mob/proc/CanMobAutoclick(object, location, params)

/mob/living/carbon/CanMobAutoclick(atom/object, location, params)
	if(!object.IsAutoclickable())
		return
	var/obj/item/h = get_active_held_item()
	if(h)
		. = h.CanItemAutoclick(object, location, params)

/mob/proc/canMobMousedown(atom/object, location, params)

/mob/living/canMobMousedown(atom/object, location, params) //NSV13 - allow non-carbons to do this too
	var/obj/item/H = get_active_held_item()
	if(H)
		. = H.canItemMouseDown(object, location, params)
	else if(src.overmap_ship && (src.overmap_ship.gunner == src || (GetComponent(/datum/component/overmap_gunning)))) //NSV13 - let us mouse-down if we're a ship operator
		. = src.overmap_ship

/obj/item/proc/CanItemAutoclick(object, location, params)

/obj/item/proc/canItemMouseDown(object, location, params)
	if(canMouseDown)
		return src

/obj/item/proc/onMouseDown(object, location, params, mob)
	return

/obj/item/proc/onMouseUp(object, location, params, mob)
	return

/obj/item
	var/canMouseDown = FALSE

/obj/item/gun
	var/automatic = 0 //can gun use it, 0 is no, anything above 0 is the delay between clicks in ds

/obj/item/gun/CanItemAutoclick(object, location, params)
	. = automatic

/atom/proc/IsAutoclickable()
	. = 1

/atom/movable/screen/IsAutoclickable()
	. = 0

/atom/movable/screen/click_catcher/IsAutoclickable()
	. = 1

//NSV13 start
/client/MouseMove(object,location,control,params)
	if(mob && LAZYLEN(mob.mousemove_intercept_objects))
		for(var/datum/D in mob.mousemove_intercept_objects)
			D.onMouseMove(object, location, control, params)
	..()

/datum/proc/onMouseMove(object, location, control, params)
	return

/datum/proc/onMouseDrag(src_object, over_object, src_location, over_location, params, mob)
	return
//NSV13 end

/client/MouseDrag(src_object,atom/over_object,src_location,over_location,src_control,over_control,params)
	var/list/L = params2list(params)
	if (L["middle"])
		if (src_object && src_location != over_location)
			middragtime = world.time
			middragatom = src_object
		else
			middragtime = 0
			middragatom = null
	if(active_mousedown_item)
		active_mousedown_item.onMouseDrag(src_object, over_object, src_location, over_location, params, mob)

/* NSV13 - don't need this sice we defined it on /datum
/obj/item/proc/onMouseDrag(src_object, over_object, src_location, over_location, params, mob)
	return
*/

/client/MouseDrop(src_object, over_object, src_location, over_location, src_control, over_control, params)
	if (middragatom == src_object)
		middragtime = 0
		middragatom = null
	..()
