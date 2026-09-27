extends ObjectState

var player
var followAnchor := Vector2(0, 0)

func _frame_0():
	player = host.get_fighter()
	
	if data != null:
		followAnchor = data["AnchorPos"]

func _tick():
	var playerPos = player.get_pos()
	print(playerPos)
	
	host.position = player.position + followAnchor
