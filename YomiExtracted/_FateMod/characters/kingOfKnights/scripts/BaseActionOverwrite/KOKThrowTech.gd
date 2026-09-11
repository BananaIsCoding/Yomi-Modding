extends "res://characters/states/ThrowTech.gd"

export (String) var normal_StateAnimName
export (String) var normalArmour_StateAnimName
export (String) var hiddenArmour_StateAnimName
export (String) var hidden_StateAnimName

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
	match host.stance:
		"Normal":
			anim_name = normal_StateAnimName
		"Normal(Armour)":
			anim_name = normalArmour_StateAnimName
	
	._enter()
