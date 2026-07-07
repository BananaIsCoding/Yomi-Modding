extends CharacterState

class_name FrozenState

const PARTICLE = preload("res://characters/wizard/projectiles/telekinesis/IceCrash2.tscn")
















const FROZEN_INNER_COLOR = Color("94e4ff")
const FROZEN_OUTLINE_COLOR = Color("ffffff")
const DEFAULT_DURATION = 60

var duration = DEFAULT_DURATION
var freeze_forces = false
var hitbox = null
var can_act = false








var saved_color = null
var saved_use_outline = false
var saved_outline_color = null
var saved_use_extra_color_1 = false
var saved_use_extra_color_2 = false
var did_snapshot = false

func _enter_tree():
	
	
	is_hurt_state = true

func _enter():
	duration = DEFAULT_DURATION
	freeze_forces = false
	hitbox = null
	can_act = false
	if data is Dictionary and data.has("hitbox"):
		hitbox = data["hitbox"]
		if hitbox != null:
			duration = hitbox.hitstun_ticks
			freeze_forces = "FreezeForces" in hitbox.misc_data
	if freeze_forces:
		host.set_vel("0", "0")
	else:
		var vel = host.get_vel()
		vel = fixed.vec_mul(vel.x, vel.y, "0.5")
		host.set_vel(vel.x, vel.y)
	var mat = host.sprite.get_material()
	
	
	
	
	if not host.is_ghost:
		saved_color = mat.get_shader_param("color")
		saved_use_outline = mat.get_shader_param("use_outline")
		saved_outline_color = mat.get_shader_param("outline_color")
		saved_use_extra_color_1 = mat.get_shader_param("use_extra_color_1")
		saved_use_extra_color_2 = mat.get_shader_param("use_extra_color_2")
		did_snapshot = true
	mat.set_shader_param("color", FROZEN_INNER_COLOR)
	mat.set_shader_param("use_outline", true)
	mat.set_shader_param("outline_color", FROZEN_OUTLINE_COLOR)
	
	
	
	
	mat.set_shader_param("use_extra_color_1", false)
	mat.set_shader_param("use_extra_color_2", false)

func _frame_0():
	host.release_opponent()
	host.spawn_particle_effect(PARTICLE, host.get_center_position_float())

func _tick():
	if freeze_forces:
		
		
		host.set_vel("0", "0")
	else:
		host.apply_grav()
		host.apply_fric()
		host.apply_forces()
	
	
	
	
	host.update_grounded()
	
	
	
	
	
	if current_tick >= duration:
		if can_act:
			return fallback_state
		else:
			enable_interrupt()
			can_act = true

func _exit():

	host.spawn_particle_effect(PARTICLE, host.get_center_position_float())
	if host.is_ghost:
		
		
		
		host.reset_color()
	elif did_snapshot:
		var mat = host.sprite.get_material()
		mat.set_shader_param("color", saved_color)
		mat.set_shader_param("use_outline", saved_use_outline)
		mat.set_shader_param("outline_color", saved_outline_color)
		mat.set_shader_param("use_extra_color_1", saved_use_extra_color_1)
		mat.set_shader_param("use_extra_color_2", saved_use_extra_color_2)
		did_snapshot = false
