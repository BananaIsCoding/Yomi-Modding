extends "res://characters/states/Idle.gd"

export (String) var normal_StateAnimName
export (String) var normalArmour_StateAnimName
export (String) var hiddenArmour_StateAnimName
export (String) var hidden_StateAnimName

var idle_anim := 0

func _enter():
	var next_state = ._enter()
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
	
	if _previous_state_name() != state_name:
		idle_anim = 0
	
	return ._enter()

func _tick():
	idle_anim += 1
	return ._tick()

func update_sprite_frame():
	.update_sprite_frame()
	host.sprite.frame = int(idle_anim/ticks_per_frame)%sprite_anim_length

func _ready():
	if (normal_StateAnimName == ""):
		normal_StateAnimName = "Wait"
	if (normalArmour_StateAnimName == ""):
		normalArmour_StateAnimName = normal_StateAnimName + "(Armour)"
	if (hiddenArmour_StateAnimName == ""):
		hiddenArmour_StateAnimName = normal_StateAnimName + "(HiddenArmour)"
	if (hidden_StateAnimName == ""):
		hidden_StateAnimName = normal_StateAnimName + "(Hidden)"
	._ready()
