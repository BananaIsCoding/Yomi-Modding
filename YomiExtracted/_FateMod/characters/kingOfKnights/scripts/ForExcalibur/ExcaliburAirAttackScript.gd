extends KokNormalAttackState

## Variables ##
var attackEffect
var startTick 
var requiredHiding = false
var tick = 0
var targetIsHit

export (PackedScene) var attackParticle
export (NodePath) var beamEffectPath
export (int) var beamLengthIncrPerTick

onready var beamEffect = get_node(beamEffectPath)

func _tick():
	tick += 1
	host.opponent.hitlag_ticks += 1
	
	beamEffect.points[1].x += beamLengthIncrPerTick
	
	if not requiredHiding:
		return
	if ( host.current_tick - startTick > 30):
		beamEffect.visible = false
		requiredHiding = false


# Resets beam
func _enter():
	
	beamEffect.points[0].x = 0
	beamEffect.points[1].x = 0
	beamEffect.visible = true
	
	var opponentOrginalPos = host.opponent.position
	opponentOrginalPos.x += host.opponent.collision_box.x
	opponentOrginalPos.y += host.opponent.collision_box.y
	
	beamEffect.look_at(opponentOrginalPos)

func _exit():
	beamEffect.visible = false
