extends KokNormalAttackState

## Variables ##

var attackEffect
var startTick 
var requiredHiding = false
var tick
var targetIsHit

var opponentOrginalPos = Vector2.ZERO
var directionVector

export (PackedScene) var attackParticle
export (NodePath) var hitboxPath
export (NodePath) var beamEffectPath
export (int) var beamLengthIncrPerTick

onready var hitbox =  get_node(hitboxPath)
onready var beamEffect = get_node(beamEffectPath)

func tick():
	tick += 1
	host.opponent.position = opponentOrginalPos
	
	beamEffect.points[1].x += beamLengthIncrPerTick
	#ChangeHitboxSize(hitbox.pos_x + beamLengthIncrPerTick)
	
	if not requiredHiding:
		return
	if ( host.current_tick - startTick > 30):
		beamEffect.visible = false
		requiredHiding = false

## Hitbox size edit functions ##
func _ready():
	beamEffect.visble = true
	opponentOrginalPos = host.opponent.position
	directionVector = (opponentOrginalPos - host.position).normalized()


func ChangeHitboxSize(width: int):
	hitbox.pos_x = width + 15
	hitbox.width = width
	
#func _frame_49():
#	beamEffect.stop_emitting()
#	startTick = host.current_tick
#	requiredHiding = true
