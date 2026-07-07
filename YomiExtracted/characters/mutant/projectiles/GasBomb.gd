extends BaseProjectile

const TRAIL_SCENE = preload("res://characters/mutant/projectiles/GasBombTrail.tscn")
var trail_spawned = false

func init(pos = null):
	.init(pos)
	
	
	
	
	if trail_spawned or ReplayManager.resimulating:
		return
	trail_spawned = true
	var trail = TRAIL_SCENE.instance()
	trail.target = self
	
	
	trail.positions.append(get_pos_visual())
	
	
	var bomb_game = get_parent().get_parent() if get_parent() else null
	if bomb_game and bomb_game.has_method("process_fx"):
		bomb_game.fx_node.add_child(trail)
		bomb_game.effects.append(trail)
		trail.connect("tree_exited", bomb_game, "_on_fx_exit_tree", [trail])
	else:
		get_parent().add_child(trail)
