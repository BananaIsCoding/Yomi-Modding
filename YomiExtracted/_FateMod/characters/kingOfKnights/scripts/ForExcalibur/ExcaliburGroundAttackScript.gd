extends KokNormalAttackState

## Variables ##

var attackEffect
var startTick 
var requiredHiding = false

export (NodePath) var hitboxPath
export (NodePath) var hitEffectPath
export (int) var effectLifetimeAfterDeactivated = 30

onready var hitbox =  get_node(hitboxPath)
onready var hitEffect = get_node(hitEffectPath)

## Hitbox size edit functions ##

func _frame_1():
	hitbox.isEffectAlrSpawned = false
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

# Stop the particle from emitting
func _frame_49():
	hitEffect.stop_emitting()
	startTick = host.current_tick
	requiredHiding = true

# Fully hide particle after x ticks
func tick():
	if not requiredHiding:
		return
	if ( host.current_tick - startTick > effectLifetimeAfterDeactivated):
		hitEffect.visible = false
		requiredHiding = false
