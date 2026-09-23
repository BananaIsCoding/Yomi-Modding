extends CharacterState

export var _c_My_Stuff = 0
export (int) var pushForce = 10

export (bool) var toggleArmourChange = false 
export (Dictionary) var forAnimationChange = {"Key = Stance To Check" : "Value = Animation To Change Into"}
export (Dictionary) var stancesToCheckAndChange = { "Key = Stance To Check" : "Value = Stance To Change Into" }

var currentTick := 0
var lastframe := 0

func _enter():
	currentTick = 0
	
	for stance in stancesToCheckAndChange:
		if host.stance == stance:
			anim_name = forAnimationChange[stance]
			host.stance = stancesToCheckAndChange[stance]
			break
	
	if not host.is_ghost:
		if toggleArmourChange:
			host.ToggleArmorMode()
		else:
			host.RevealThyBlade()
	
func detect(obj):
	if obj.is_in_group("Fighter"):
		
		obj.reset_momentum()
		
		var opponentOrginalPos = Vector2(obj.get_pos().x, obj.get_pos().y)
		var hosPos = Vector2(host.get_pos().x, host.get_pos().y)

		var pushDir = opponentOrginalPos - hosPos
		pushDir = pushDir.normalized() * pushForce

		obj.apply_force(str(pushDir.x), str(pushDir.y))


#func _exit():
#	for stance in stancesToCheckAndChange:
#		if host.stance == stance:
#			host.stance = stancesToCheckAndChange[stance]
#			break
