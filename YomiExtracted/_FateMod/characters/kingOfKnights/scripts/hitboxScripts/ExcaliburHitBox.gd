tool

extends Hitbox

export (NodePath) var hitEffectPath

onready var hitEffect = get_node(hitEffectPath)

var isEffectAlrSpawned
var charDistance

func _enter_tree():
	if not get_parent().host.is_ghost:
		charDistance = Vector2(Global.current_game.char_distance, 20)

func hit(obj):
	.hit(obj)
	
	if(!obj.is_in_group("Fighter")):
		return
	
	if (!isEffectAlrSpawned):
		isEffectAlrSpawned = true
		hitEffect.visible = true
		hitEffect.start_emitting()
		
		var hitPos = host.opponent.get_center_position_float()
		if (host.get_facing_int() == -1):
			hitPos.x *= -1

		hitEffect.position = hitPos + charDistance
