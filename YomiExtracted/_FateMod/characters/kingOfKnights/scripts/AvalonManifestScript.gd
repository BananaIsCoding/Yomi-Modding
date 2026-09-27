extends CharacterState

func spawn_exported_projectile():
	if projectile_scene:
		var pos = get_projectile_pos()
		var projData = {"AnchorPos" : Vector2(projectile_pos_x, projectile_pos_y)}
		var obj = host.spawn_object(projectile_scene, pos.x, pos.y, true, projData, projectile_local_pos)
		process_projectile(obj)
