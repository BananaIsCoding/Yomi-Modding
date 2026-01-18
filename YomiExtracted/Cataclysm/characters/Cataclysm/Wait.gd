extends "res://characters/states/Idle.gd"

var idle_anim = 0

func _enter():
	if _previous_state_name() != state_name:
		idle_anim = 0
	return ._enter()

func _tick():
	idle_anim += 1
	return ._tick()

func update_sprite_frame():
	.update_sprite_frame()
	host.sprite.frame = int(idle_anim/ticks_per_frame)%sprite_anim_length

