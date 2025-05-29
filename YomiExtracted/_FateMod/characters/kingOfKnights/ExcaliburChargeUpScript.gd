extends CharacterState

var _effectScene

func spawn_particle_relative(scene: PackedScene, pos = Vector2(), dir = Vector2.RIGHT):
	var p = host.get_pos_visual()
	_effectScene = host.spawn_particle_effect(scene, p + pos, dir)
	return _effectScene
