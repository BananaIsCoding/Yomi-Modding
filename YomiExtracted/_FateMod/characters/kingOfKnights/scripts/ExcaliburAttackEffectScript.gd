extends KokNormalAttackState

## Variables ##

var attackEffect

export (PackedScene) var attackParticle
export (NodePath) var hitboxPath
export (NodePath) var hitEffect

onready var hitbox =  get_node(hitboxPath)

func _frame_1():
	hitbox.pos_x = 475
	hitbox.width = 460

func _frame_2():
	hitbox.pos_x = 695
	hitbox.width = 680

func _frame_3():
	hitbox.pos_x = 915
	hitbox.width = 900

