extends ObjectState

var player
var followAnchor := Vector2(0, 0)

func _frame_0():
	if data != null:
		player = data["Character"]
		followAnchor = data["AnchorPos"]

func _tick():
	
	if not player:
		host.disable()
		return
	
	var anchorPos = player.get_pos()
	anchorPos.x = anchorPos.x + followAnchor.x
	anchorPos.y = anchorPos.y + followAnchor.y
	print("anchor pos: ", anchorPos)
	print("avalon pos: ", host.get_pos())
