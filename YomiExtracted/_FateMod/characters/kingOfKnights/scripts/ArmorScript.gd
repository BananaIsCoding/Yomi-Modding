extends CharacterState

export var pushForce = 5

func _enter():
	if not host.is_ghost:
		host.ToggleArmorMode()
	
func detect(obj):
	if obj.is_in_group("Fighter"):
		obj.reset_momentum()

		var opponentOrginalPos = Vector2(obj.get_pos().x, obj.get_pos().y)
		var hosPos = Vector2(host.get_pos().x, host.get_pos().y)

		var pushDir = opponentOrginalPos - hosPos
		pushDir = pushDir.normalized() * pushForce

		obj.apply_force(str(pushDir.x), str(pushDir.y))

func _exit():
	if host.stance == "Normal":
		host.stance = "Normal(Armour)"
	elif host.stance == "Hidden":
		host.stance = "Hidden(Armour)"
