extends CharacterState

func _enter():
	if not host.is_ghost:
		host.ToggleArmorMode()
