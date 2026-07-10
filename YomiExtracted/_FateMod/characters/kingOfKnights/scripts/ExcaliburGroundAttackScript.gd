extends KokNormalAttackState

## Variables ##

var attackEffect

export (PackedScene) var attackParticle
export (NodePath) var hitboxPath

onready var hitbox =  get_node(hitboxPath)

## Hitbox size edit functions ##

func _tick():
	host.opponent.hitlag_ticks += 1


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
