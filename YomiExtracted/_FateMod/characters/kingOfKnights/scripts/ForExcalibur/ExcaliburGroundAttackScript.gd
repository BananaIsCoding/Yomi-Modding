extends KokNormalAttackState

## Variables ##

var attackEffect
var startTick 
var requiredHiding = false

export (PackedScene) var attackParticle
export (NodePath) var hitboxPath
export (NodePath) var hitEffectPath

onready var hitbox =  get_node(hitboxPath)
onready var hitEffect = get_node(hitEffectPath)

## Hitbox size edit functions ##

func _frame_1():
	ChangeHitboxSize(460)

func _frame_2():
	ChangeHitboxSize(680)

func _frame_3():
	ChangeHitboxSize(90)

func _frame_4():
	ChangeHitboxSize(1015)

func ChangeHitboxSize(width: int):
	hitbox.pos_x = width + 15
	hitbox.width = width
	
func _frame_49():
	hitEffect.stop_emitting()
	startTick = host.current_tick
	requiredHiding = true

func tick():
	if not requiredHiding:
		return
	if ( host.current_tick - startTick > 30):
		hitEffect.visible = false
		requiredHiding = false
