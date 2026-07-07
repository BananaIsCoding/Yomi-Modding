extends Node2D







const DOT_SPRITE = preload("res://fx/particle_round_hollow_4x4.png")
const COLOR = Color("1d8df5")
const DOT_SPACING = 8.0



const MAX_DOTS = 11



const TETHER_SPEED_MAX = 1.5
const TETHER_FALLOFF = 0.96
const TETHER_SPEED_MIN = 0.05

var wizard = null
var orb = null

func _ready():
	
	
	
	
	z_as_relative = false
	z_index = - 100

func tick():
	var alive = is_instance_valid(wizard)\
	and is_instance_valid(orb)\
	and not orb.disabled\
	and wizard.tether_ticks > 0
	if not alive:
		queue_free()
		return
	update()

func _draw():
	if not is_instance_valid(wizard) or not is_instance_valid(orb):
		return
	var origin = global_position
	
	
	
	var start = wizard.get_hurtbox_center_float() - origin
	var end = orb.get_hurtbox_center_float() - origin
	var color = COLOR
	color.a = _alpha_from_tether_speed()
	var diff = end - start
	var dist = diff.length()
	if dist < 0.001:
		_draw_dot(start, color)
		return
	var dir = diff / dist
	var max_span_at_default = DOT_SPACING * (MAX_DOTS - 1)
	if dist > max_span_at_default:
		
		
		var spacing = dist / float(MAX_DOTS - 1)
		for i in range(MAX_DOTS):
			_draw_dot(start + dir * (i * spacing), color)
	else:
		
		
		
		var t = 0.0
		while t < dist:
			_draw_dot(start + dir * t, color)
			t += DOT_SPACING
		_draw_dot(end, color)

func _draw_dot(pos: Vector2, color: Color):
	var size = DOT_SPRITE.get_size()
	draw_texture(DOT_SPRITE, pos - size * 0.5, color)




func _alpha_from_tether_speed() -> float:
	var elapsed = wizard.TETHER_TICKS - wizard.tether_ticks
	var falloff_power = elapsed / 3.0
	var speed = TETHER_SPEED_MAX * pow(TETHER_FALLOFF, falloff_power)
	var span = TETHER_SPEED_MAX - TETHER_SPEED_MIN
	var t = clamp((speed - TETHER_SPEED_MIN) / span, 0.0, 1.0)
	return lerp(0.25, 1.0, t)
