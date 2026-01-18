extends CharacterState

onready var BG = load("res://Cataclysm/characters/Cataclysm/BG.tscn")
onready var Transition = load("res://Cataclysm/characters/Cataclysm/Transition.tscn")
onready var Rain = load("res://Cataclysm/characters/Cataclysm/Rain.tscn")
onready var Splash = load("res://Cataclysm/characters/Cataclysm/Splash.tscn")


func _tick():
	if not host.is_ghost:
		Global.current_game.time += 1

func _frame_0():
	host.play_sound("Awakening")
	host.set_camera_zoom(0.75)
	host.tween_camera_zoom(1, 0.75, 0.65, Tween.TRANS_QUART, Tween.EASE_OUT)
	host.opponent.hitlag_ticks += 190
	

func _frame_100():
	$"%Awaken".start_emitting() 
	host.spawn_particle_effect(Transition, Vector2.ZERO)
	host.spawn_particle_effect(BG, Vector2.ZERO)
	host.set_camera_zoom(1)
	host.tween_camera_zoom(1, 1, 0.65, Tween.TRANS_QUART, Tween.EASE_OUT)

func is_usable():
	return .is_usable() and host.bloodfeast > 90

func _frame_5():
	host.bloodfeast -= 90
