tool

extends Hitbox

## Variables ##

export (NodePath) var hitEffectPath

onready var hitEffect = get_node(hitEffectPath)

var isEffectAlrSpawned
var charDistance

## Functions ##

# Getting variables at start so it does not need to fetch it again during game
func _enter_tree():
	if not get_parent().host.is_ghost:
		charDistance = Vector2(Global.current_game.char_distance, 20)

# Overriden function to also spawn the hit effect once
func hit(obj):
	.hit(obj)
	
	# if not a char e.g. projectile then don't spawn
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
