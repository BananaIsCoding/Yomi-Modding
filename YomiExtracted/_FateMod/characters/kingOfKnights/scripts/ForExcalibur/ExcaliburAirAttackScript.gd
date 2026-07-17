extends KokNormalAttackState

## Variables ##

var attackEffect
var startTick 
var requiredHiding = false
var tick = 0
var targetIsHit
var isEnding = false

export (NodePath) var beamEffectPath
export (NodePath) var hitboxPath
export (int) var beamLengthIncrPerTick

onready var hitbox =  get_node(hitboxPath)
onready var beamEffect = get_node(beamEffectPath)

## Functions ##

# Enlarge beam effect as it ticks
# [NOTE] need to add particle dispersal effects
func _tick():
	tick += 1
	host.opponent.hitlag_ticks += 1
	
	if isEnding:
		beamEffect.points[0].x += beamLengthIncrPerTick
	else:
		beamEffect.points[1].x += beamLengthIncrPerTick

# Resets beam
func _enter():
	
	isEnding = false
	hitbox.isEffectAlrSpawned = false
	beamEffect.points[0].x = 0
	beamEffect.points[1].x = 0
	beamEffect.visible = true
	
	var opponentOrginalPos = host.opponent.position
	opponentOrginalPos.x += host.opponent.collision_box.x
	opponentOrginalPos.y += host.opponent.collision_box.y
	
	beamEffect.look_at(opponentOrginalPos)


func _frame_40():
	isEnding = true

func _exit():
	beamEffect.visible = false
