extends CharacterState

class_name KokNormalAttackState

export var _c_My_Stuff = 0
export (String) var normal_StateAnimName
export (String) var normalArmour_StateAnimName
export (String) var hidden_StateAnimName
export (String) var hiddenArmour_StateAnimName
export var _c_Hidden_Blade_Stuff = 0

export (bool) var applyHiddenInstallBuff = true

var originalHbDmg = []
var originalHbParriable = []
var originalHbSize = []

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
			originalHbParriable.append(child.parriable)
			originalHbSize.append(Vector2(child.width, child.height))
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

func _ready():
	if (normal_StateAnimName == ""):
		normal_StateAnimName = sprite_animation
	if (normalArmour_StateAnimName == ""):
		normalArmour_StateAnimName = normal_StateAnimName + "(Armour)"
	if (hiddenArmour_StateAnimName == ""):
		hiddenArmour_StateAnimName = normal_StateAnimName + "(HiddenArmour)"
	if (hidden_StateAnimName == ""):
		hidden_StateAnimName = normal_StateAnimName + "(Hidden)"
	._ready()

func _enter():
	
	if host.is_ghost:
		host.stance = Network.game.get_player(host.id).stance
	
	match host.stance:
		"Normal":
			anim_name = normal_StateAnimName
		"Normal(Armour)":
			anim_name = normalArmour_StateAnimName
		"Hidden":
			anim_name = hidden_StateAnimName
		"Hidden(Armour)":
			anim_name = hiddenArmour_StateAnimName
	
	sprite_anim_length = host.sprite.frames.get_frame_count(anim_name)
	
	var canParry := true
	
	if applyHiddenInstallBuff:
		if host.stance == "Hidden" or host.stance =="Hidden(Armour)":
			if not host.is_ghost: 
				print(host.stance)
				if ReplayManager.frames[host.id].has(host.current_tick):
					host.SaveTick()
					if ReplayManager.frames[host.id][host.current_tick].has("CanParry"):
						canParry = ReplayManager.frames[host.id][host.current_tick]["CanParry"]
					else:
						randomize()
						var num = randi() % 100
						if num <= host.hiddenBladePercentChance:
							canParry = false
						ReplayManager.frames[host.id][host.current_tick]["CanParry"] = canParry
				else:
					canParry = ReplayManager.frames[host.id][host.lastAttackLockIn]["CanParry"]
			else:
				if host.is_you() and host.tipToggle:
					Network.game.get_player(host.id).ShowHintText( str(host.hiddenBladePercentChance) + "% unparriable + increase hitbox" )
				if (Global.current_game.real_tick % anim_length) % 2 == 1:
					canParry = false

	for hitbox in all_hitbox_nodes:
		if hitbox is Hitbox:
			hitbox.damage += hitbox.damage * host.dmgBoost
			if not canParry:
				if not host.is_ghost or host.is_you():
					hitbox.parriable = false
					hitbox.width *= 1.3
					hitbox.height *= 1.3

func _exit():
	
	if not host.is_ghost:
		Network.game.get_player(host.id).HideHintText()
	
	var index = 0
	for hitbox in all_hitbox_nodes:
		if hitbox is Hitbox:
			hitbox.damage = originalHbDmg[index]
			hitbox.parriable = originalHbParriable[index]
			hitbox.width = originalHbSize[index].x
			hitbox.height = originalHbSize[index].y
			index += 1

func _frame_1():
	if host.stance == "Normal":
		current_real_tick -= 1
		host.state_tick()
