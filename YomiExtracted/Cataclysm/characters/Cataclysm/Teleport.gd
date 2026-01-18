extends CharacterState

onready var Dust = load("res://Cataclysm/characters/Cataclysm/Dust6.tscn")

func _frame_4():
	host.spawn_particle_effect_relative(load("res://Cataclysm/characters/Cataclysm/Dust6.tscn"), Vector2(0, 0), Vector2(data.x, data.y))
	if data:
		var dir= xy_to_dir(data.x, data.y, "200")
		host.move_directly(dir.x, dir.y)
	if data:
		var dir= xy_to_dir(data.x, data.y, "6")
		host.apply_force(dir.x, dir.y)
	$"%Dust4".start_emitting()

func _frame_5():
	$"%Dust4".stop_emitting()

func _exit():
	$"%Dust4".stop_emitting()

func is_usable():
	return .is_usable() and host.bloodfeast > 20

func _frame_6():
	host.bloodfeast -= 20
