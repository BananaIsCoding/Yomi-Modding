tool

extends Hitbox

## Variables ##

export (NodePath) var hitEffectPath
export (bool) var centreOnOpp = false

onready var hitEffect = get_node(hitEffectPath)

var isEffectAlrSpawned

## Functions ##

# Overriden function to also spawn the hit effect once
func hit(obj):
	.hit(obj)
	
	# if not a char e.g. projectile then don't spawn
	if(!obj.is_in_group("Fighter")):
		return
	
	if (!isEffectAlrSpawned):
		isEffectAlrSpawned = true
		
		# Reveal the star effect on opponent
		hitEffect.visible = true
		hitEffect.start_emitting()
		
		var hitPos = obj.get_pos()
		var opponentOrginalPos = Vector2(hitPos.x, hitPos.y)
		opponentOrginalPos.x += obj.collision_box.x
		opponentOrginalPos.y += obj.collision_box.y
		
		var distance = (opponentOrginalPos - Vector2(host.get_pos().x, host.get_pos().y))
		distance.x = abs(distance.x)
		
		hitEffect.position = distance + Vector2(0, 20)
