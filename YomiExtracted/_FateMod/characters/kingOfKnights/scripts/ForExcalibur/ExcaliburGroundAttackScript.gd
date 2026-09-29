extends KokNormalAttackState

## Variables ##

var attackEffect
var startTick 
var requiredHiding = false
var currentTick = 0
var opponentOrigPos = null

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
			hitbox.isEffectAlrSpawned = false
			startTick = host.current_tick
			requiredHiding = true
	
	if hitEffect.visible:
		if opponentOrigPos == null:
			opponentOrigPos = host.opponent.get_pos()
		# So it does not lift opponent up last frame
		if not "Parry" in host.opponent.current_state().name:
			host.opponent.set_pos(opponentOrigPos.x, host.opponent.get_pos().y - 1)
		else:
			host.opponent.set_pos(opponentOrigPos.x, host.opponent.get_pos().y )
		var opponentOrginalPos = Vector2(opponentOrigPos.x, opponentOrigPos.y)
		opponentOrginalPos.x += host.opponent.collision_box.x
		
		hitEffect.position.x = abs(opponentOrginalPos.x - host.get_pos().x)
	
	if not requiredHiding:
		return
	if ( host.current_tick - startTick > effectLifetimeAfterDeactivated):
		hitEffect.visible = false
		requiredHiding = false
