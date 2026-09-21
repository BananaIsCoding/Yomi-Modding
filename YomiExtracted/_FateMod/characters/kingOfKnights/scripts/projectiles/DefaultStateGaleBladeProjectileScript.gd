extends ObjectState

export var projSpeed = 5
var hit_something = false
var projDirX = 0
var projDirY = 0

var groundImmunity = false
var projLifetime = 30

func _enter():
	._enter()
	if data:
		projLifetime = data["lifetime"]
		host.set_grounded(false)
		var dir = data["dir"]
		projDirX = dir.x
		projDirY = dir.y
		host.sprite.rotation = float(fixed.vec_to_angle(data["dir"].x, data["dir"].y))
		host.particles.rotation = float(fixed.vec_to_angle(data["dir"].x, data["dir"].y))
		
		if float(dir.y) >= -1.5:
			groundImmunity = true
		
		for hitbox in all_hitbox_nodes:
			if hitbox is Hitbox:
				hitbox.rotation = float(fixed.vec_to_angle(data["dir"].x, data["dir"].y))
				hitbox.damage += hitbox.damage * data["dmgBoost"]

func _tick():
	if current_tick >= projLifetime or (host.is_grounded() and not groundImmunity):
		host.disable()
		return
	
	if not hit_something:
		host.move_directly(projDirX, projDirY)


func _on_hit_something(obj,hitbox):
	._on_hit_something(obj,hitbox)
	host.disable()
