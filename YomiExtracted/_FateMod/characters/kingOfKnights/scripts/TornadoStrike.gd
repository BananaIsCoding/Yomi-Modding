extends KokNormalAttackState

export var _c_ExtraStuffForProjectile = 0
export var static_x_dir = 1
export var static_y_dir = 0
export var lifetime = 200
export var maxTickPerMove := 5

func spawn_exported_projectile():
	if projectile_scene:
		var pos = get_projectile_pos()
		var projData = get_projectile_data()
		var obj = host.spawn_object(projectile_scene, pos.x, pos.y, true, projData, projectile_local_pos)
		if projectile_match_facing:
			obj.set_facing(host.get_facing_int())
		process_projectile(obj)

func get_projectile_data() -> Dictionary:
	
	var newLifetime = lifetime
	
	if data.x > 1:
		newLifetime = lifetime / data.x
	
	return {
		"dir" : xy_to_dir(static_x_dir * host.get_facing_int(), static_y_dir, "1.0" , "1.0"),
		"speed": str(data.x / 2.0),
		"lifetime":newLifetime,
		"maxTickPerMove": maxTickPerMove,
		"dmgBoost": host.dmgBoost + host.specialBoost
	}
