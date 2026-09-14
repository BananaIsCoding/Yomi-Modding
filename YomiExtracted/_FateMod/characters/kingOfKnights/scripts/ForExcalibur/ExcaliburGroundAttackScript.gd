extends KokNormalAttackState

## Variables ##

var attackEffect
var startTick 
var requiredHiding = false
var currentTick = 0

export (NodePath) var hitboxPath
export (NodePath) var hitEffectPath
export (NodePath) var attackEffectPath
export (int) var effectLifetimeAfterDeactivated = 30

onready var hitbox =  get_node(hitboxPath)
onready var hitEffect = get_node(hitEffectPath)
onready var excailburAttackEffect = get_node(attackEffectPath)

## Hitbox size edit functions ##

func ChangeHitboxSize(width: int):
	hitbox.pos_x = width + 15
	hitbox.width = width


func _enter():
	._enter()
	host.opponent.hitlag_ticks += 1

# Fully hide particle after x ticks
func _tick():
	currentTick += 1
	match currentTick:
		1:
			excailburAttackEffect.visible = true
			excailburAttackEffect.frame = 0
			excailburAttackEffect.playing = true
		2:
			loop_animation = true
			ChangeHitboxSize(460)
		3:
			ChangeHitboxSize(680)
		4:
			ChangeHitboxSize(900)
		5:
			ChangeHitboxSize(1015)
		26:
			loop_animation = false
		40:
			excailburAttackEffect.visible = false
			excailburAttackEffect.playing = false
		49:
			hitEffect.stop_emitting()
			startTick = host.current_tick
			requiredHiding = true
	
	if not requiredHiding:
		return
	if ( host.current_tick - startTick > effectLifetimeAfterDeactivated):
		hitEffect.visible = false
		requiredHiding = false
