extends CharacterState

export (String) var hiddenArmour_StateAnimName

func _ready():
	if (hiddenArmour_StateAnimName == ""):
		hiddenArmour_StateAnimName = sprite_animation + "(Armour)"
	._ready()

func _enter():
	print(host.stance)
	if host.stance == "Hidden(Armour)":
		anim_name = hiddenArmour_StateAnimName

func _exit():
	if host.stance == "Hidden(Armour)":
		host.stance = "Normal(Armour)"
	else:
		host.stance = "Normal"
