extends KokNormalAttackState

## Variables ##

var prevHitLag = 0
var cutscenePlaying
var startStun = false
var tickForCutscene = 0
var opponentHeight = 0

onready var swordChargeUp = $"%ExcaliburSwordSprite"
onready var excaliburCutscene = $"%ExcaliburCutscene"
onready var chargeUpEffect = $"%ExcaliburChargeUp"
onready var cutsceneFiller = $"%CutsceneFiller"
onready var cutsceneChargeParticles = $"%ExcaliburCutsceneChargeUp"

export (int) var cutsceneTPF

## Functions ##

func _frame_0():
	# Starting up the effects
	chargeUpEffect.start_emitting()
	swordChargeUp.frame = 0
	swordChargeUp.visible = true
	swordChargeUp.playing = true
	
func _frame_5():
	startStun = true
	if not "Parry" in host.opponent.current_state().name:
		host.opponent.state_machine.queue_state("Wait")
	host.start_invulnerability()

func _exit():
	._enter()
	# Ends effects if it haven't yet
	chargeUpEffect.stop_emitting()
	cutsceneChargeParticles.stop_emitting()
	swordChargeUp.visible = false
	swordChargeUp.playing = false
	# Release camera from following player
	host.release_camera_focus()

func _tick():
	
	if startStun:
		# Stops enemy in place
		host.opponent.hitlag_ticks += 1
		
	if cutscenePlaying:
		# Ensure cutscene is correctly 
		host.set_camera_zoom(1.0)
		host.grab_camera_focus()
		
		# To change cutscene frame every x ticks
		tickForCutscene += 1
		if tickForCutscene == cutsceneTPF:
			tickForCutscene = 0
			excaliburCutscene.frame += 1

## Specific Frame stuff: ##

func _frame_14():
	cutscenePlaying = true
	prevHitLag = host.opponent.hitlag_ticks
	busy_interrupt_type = BusyInterrupt.None

func _frame_93():
	
	swordChargeUp.playing = false
	swordChargeUp.visible = false
	
	cutsceneChargeParticles.start_emitting()
	
	# Set up for cutscene 
	host.quick_ui_hider()
	
	host.grab_camera_focus()
	host.set_camera_zoom(1.0)
	
	var playerPos = host.get_pos()
	var opponentPos =  host.opponent.get_pos()
	
	var game = Global.current_game
	
	match host.stance:
		"normal":
			excaliburCutscene.animation = "default"
		"Normal(Armour)":
			excaliburCutscene.animation = "Armour"
	
	excaliburCutscene.show()
	tickForCutscene = 0
	excaliburCutscene.frame = 0
	cutsceneFiller.show()

func _frame_272():
	# Stopping the cutscene 
	EndMove()
	
	opponentHeight = host.opponent.position.y

func detect(obj):
	if obj.is_in_group("Fighter"):
		
		EndMove()
		
		opponentHeight = host.opponent.position.y
		if opponentHeight < -50:
			queue_state_change("ExcaliburAirVar")
		else:
			queue_state_change("ExcaliburGroundVar")

func EndMove():
	startStun = false
	cutscenePlaying = false
	chargeUpEffect.stop_emitting()
	cutsceneChargeParticles.stop_emitting()
	excaliburCutscene.hide()
	cutsceneFiller.hide()
	host.quick_ui_revealer()
	
	host.end_invulnerability()
