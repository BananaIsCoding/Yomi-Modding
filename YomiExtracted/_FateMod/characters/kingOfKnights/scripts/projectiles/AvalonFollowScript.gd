extends ObjectState

## Variables ##

export var _c_momement_parameters = 0
export (String) var moveSpeed := "5.0"
export (int) var moveDelayTick := 10
export (int) var move_time := 10
export (float) var accelerationPerTick = 0.5
export (float) var maxSpeed = 4.5
export (int) var axisStopDistance = 4

var currentSpeed : float = 0.0
var player
var followAnchor := Vector2(0, 0)
var arriveTime = 0

## Functions ##

func _frame_0():
	# grabbing data passed from charater
	if data != null:
		player = data["Character"]
		followAnchor = data["AnchorPos"]
		Global.current_game.get_player(player.id).avalonGhost = self

func _tick():
	# If player character disappear, therefore this is a prediction so I should go too
	if not player:
		host.disable()
		return
	
	# Getting Pos
	var anchorPos = player.get_pos()
	anchorPos.x = anchorPos.x + (followAnchor.x * player.get_facing_int())
	anchorPos.y = anchorPos.y + followAnchor.y
	var selfPos = host.get_pos()
	
	# Calcuating direction
	var dirX
	var dirY
	
	if abs(selfPos.x - anchorPos.x) <= axisStopDistance:
		dirX = 0
	else:
		 dirX = Utils.int_sign(anchorPos.x - selfPos.x)
	
	if abs(selfPos.y - anchorPos.y) <= axisStopDistance:
		dirY = 0
	else:
		 dirY = Utils.int_sign(anchorPos.y - selfPos.y)
	
	if dirX == 0 and dirY == 0:
		# To later use to delay avalon's movement
		arriveTime = current_tick
	elif current_tick > arriveTime + moveDelayTick:
		var dis = int(fixed.vec_dist(str(selfPos.x), str(selfPos.y), str(anchorPos.x), str(anchorPos.y)))
		var speed = dis / move_time
		
		if abs(currentSpeed - speed) >= 0.5: 
			if currentSpeed < speed:
				currentSpeed += accelerationPerTick
			elif currentSpeed > speed:
				currentSpeed -= accelerationPerTick
			
			clamp(currentSpeed, 0, maxSpeed)
		
		var move_vec = fixed.normalized_vec_times(str(dirX), str(dirY), str(currentSpeed))
		host.move_directly(move_vec.x, move_vec.y)
