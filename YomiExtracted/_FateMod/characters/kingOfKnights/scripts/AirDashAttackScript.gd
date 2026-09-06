extends KokNormalAttackState

export (NodePath) var bodyHitBoxPath

onready var bodyHitBox = get_node(bodyHitBoxPath)

func _frame_0():
	if data:
		var dir = xy_to_dir(data.x, data.y, "1.5")
		force_dir_x = float(dir.x)
		force_dir_y = float(dir.y)
		
		var dirVec = Vector2(force_dir_x , force_dir_y)
		host.sprite.rotation = dirVec.angle()
		
		var pos = particle_position
		pos.x *= host.get_facing_int()
		var dashScene = spawn_particle_relative(particle_scene, pos, dirVec)
		
		bodyHitBox.rotation = host.sprite.rotation
		
		if force_dir_x < 0:
			host.sprite.scale.x = -1
			host.sprite.rotation -= deg2rad(180)

func _exit():
	._exit()
	host.sprite.scale.x = 1
	host.sprite.rotation = 0
