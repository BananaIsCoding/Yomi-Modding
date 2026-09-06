extends KokNormalAttackState

## Variables ##

var attackEffect
var startTick 
var requiredHiding = false
var tick = 0
var targetIsHit
var isEnding = false
var angleForPrediction

export (NodePath) var beamEffectPath
export (NodePath) var hitboxPath
export (int) var beamLengthIncrPerTick

onready var hitbox =  get_node(hitboxPath)
onready var beamEffect = get_node(beamEffectPath)

## Functions ##

func _enter():
	._enter()
	tick = 0

# Rotate beam and play enlarge effect as it ticks
# [NOTE] need to add particle dispersal effects
func _tick():
	tick += 1
	
	match tick:
		1: 
			# Resets stuff just in-case it not a fresh state
			loop_animation = true
			isEnding = false
			hitbox.isEffectAlrSpawned = false
			beamEffect.points[0].x = 0
			beamEffect.points[1].x = 0
			beamEffect.visible = true
			
			# Getting actual global positions
			var basePos = Network.game.p1.global_transform.origin
			var oppBasePos = Network.game.p2.global_transform.origin
			
			if (host.name == "P2"):
				var tempPosHolder = basePos
				basePos = oppBasePos
				oppBasePos = basePos
			
			# Getting opponent prediction pos
			var opponentOrginalPos = Vector2(host.opponent.get_pos().x, host.opponent.get_pos().y)
			opponentOrginalPos.x += host.opponent.collision_box.x
			opponentOrginalPos.y += host.opponent.collision_box.y
			
			# Getting beam's actual global pos 
			var beamGlobalPos = basePos + Vector2(beamEffect.position.x * host.get_facing_int(), beamEffect.position.y)
			
			# Rotating it to point at target
			beamEffect.global_rotation = (opponentOrginalPos - beamGlobalPos).angle()
			
			# Flipping it based on user facing direction
			beamEffect.rotation_degrees *= host.get_facing_int()
			
			# Checks if player and beam rotation is in range
			if beamEffect.rotation_degrees < -30:
				if ( beamEffect.rotation_degrees < -46):
					hitbox.activated = false
				else:
					hitbox.activated = true
				beamEffect.rotation_degrees = -30
			else:
				hitbox.activated = true
		35:
			# Allow character to play the last few frames
			loop_animation = false
		40:
			isEnding = true

	if hitbox.activated:
		host.opponent.hitlag_ticks += 1
	
	if isEnding:
		beamEffect.points[0].x += beamLengthIncrPerTick
	else:
		beamEffect.points[1].x += beamLengthIncrPerTick

func _exit():
	._exit()
	beamEffect.visible = false
