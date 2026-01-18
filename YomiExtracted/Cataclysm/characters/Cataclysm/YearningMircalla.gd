extends CharacterState

onready var Hits = load("res://Cataclysm/characters/Cataclysm/YearningMircalla.tscn")
onready var Dust = load("res://Cataclysm/characters/Cataclysm/Yearning1.tscn")
onready var Dash = load("res://Cataclysm/characters/Cataclysm/Yearning2.tscn")
onready var Dust2 = load("res://Cataclysm/characters/Cataclysm/Dust2.tscn")

func _frame_0():
	host.play_sound("SwordSwush2")
	host.set_camera_zoom(0.70)
	host.tween_camera_zoom(0.99, 0.70, 0.65, Tween.TRANS_QUART, Tween.EASE_OUT)

func _frame_7():
	if data:
		var dir= xy_to_dir(data.x, data.y, "150")
		host.move_directly(dir.x, dir.y)
	$"%YearningMircalla".start_emitting()
	host.spawn_particle_effect_relative(load("res://Cataclysm/characters/Cataclysm/Yearning1.tscn"), Vector2(0, 0), Vector2(data.x, data.y))
	host.spawn_particle_effect_relative(load("res://Cataclysm/characters/Cataclysm/Dust2.tscn"), Vector2(0, 0), Vector2(data.x, data.y))
func _on_hit_something(obj, hitbox):
	._on_hit_something(obj, hitbox)
	host.play_sound("SwordSwush3")
	host.play_sound("SwordSwush4")
	host.play_sound("SwordSpin")

func _frame_10():
	host.spawn_particle_effect_relative(load("res://Cataclysm/characters/Cataclysm/Yearning2.tscn"), Vector2(0, 0), Vector2(data.x, data.y))

func _frame_11():
	$"%YearningMircalla".stop_emitting()

func _exit():
	if host.bloodfeast > 40:
		$"%bloodfeast".start_emitting()
	if host.bloodfeast < 40:
		$"%bloodfeast".stop_emitting()
	$"%YearningMircalla".stop_emitting()
	$"%YearningMircalla".hide()
	host.bloodfeast -= 30

func is_usable():
	return .is_usable() and host.bloodfeast > 25
