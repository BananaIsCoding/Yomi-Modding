extends CharacterState

class_name KokNormalAttackState

var originalHbDmg = []

# Overriding set_up to also add the original hitbox damage 
# when it loops though the children 
func setup_hitboxes():
	all_hitbox_nodes = []
	for child in get_children():
		if child is Hitbox:
			if child is ThrowBox:
				is_grab = true
			all_hitbox_nodes.append(child)
			host.hitboxes.append(child)
			originalHbDmg.append(child.damage)
			child.native = native
			if child.guard_break:
				is_guard_break = true
	var earliest = 999999999
	for hitbox in all_hitbox_nodes:
		hitbox.host = host
		hitbox.init()
		var detect = hitbox.hitbox_type == Hitbox.HitboxType.Detect
		if not detect:
			has_hitboxes = true
		if not host.is_ghost:
			hitbox.property_list = get_script().get_property_list()
		if hitbox.start_tick > 0:
			if hitbox_start_frames.has(hitbox.start_tick):
				hitbox_start_frames[hitbox.start_tick].append(hitbox)
			else:
				hitbox_start_frames[hitbox.start_tick] = [hitbox]
			if not detect:
				if hitbox.start_tick < earliest:
					earliest = hitbox.start_tick
					earliest_hitbox_node = hitbox
		hitbox.connect("hit_something", self, "__on_hit_something")
		hitbox.connect("got_parried", self, "__on_got_parried")
		for hitbox2 in all_hitbox_nodes:
			if hitbox2.group == hitbox.group:
				hitbox.grouped_hitboxes.append(hitbox2)
	if earliest_hitbox <= 0 and earliest != 999999999:
		earliest_hitbox = earliest

func _enter():
#	for start_frame in hitbox_start_frames:
#		var items = hitbox_start_frames[start_frame]
#		for hitbox in items:
#			if hitbox is Hitbox:
#				hitbox.damage = 0
	for hitbox in all_hitbox_nodes:
		if hitbox is Hitbox:
			print(hitbox.damage)
			hitbox.damage += hitbox.damage * 0.3
			print(hitbox.damage)
			
func _exit():
	var index = 0
	for hitbox in all_hitbox_nodes:
		if hitbox is Hitbox:
			hitbox.damage = originalHbDmg[index]
