extends ObjectState

export var projSpeed = 5
var hit_something = false
var projDirX = 0
var projDirY = 0

var ungroundRegisterPeriod = 0

func _enter():
	ungroundRegisterPeriod = 0

func _frame_0():
	print(host.rotation_degrees)
	
	var twoDirMult = sqrt(projSpeed * projSpeed)
	
	if host.rotation_degrees == 0:
		projDirX = host.get_facing_int() * projSpeed
	elif host.rotation_degrees == -45:
		projDirX = host.get_facing_int() * projSpeed
		projDirY = -projSpeed
	elif host.rotation_degrees == 45:
		projDirX = host.get_facing_int() * projSpeed
		projDirY = projSpeed
	elif host.rotation_degrees == -90:
		projDirY = -projSpeed
	elif host.rotation_degrees == 90:
		projDirY = projSpeed
#	match host.rotation_degrees:
#		0:
#			print("its " + host.get_facing_int())
#			projDirX = host.get_facing_int()
#		-45:
#			projDirX = host.get_facing_int()
#			projDirY = -1
#		45:
#			projDirX = host.get_facing_int()
#			projDirY = 1
#		-90:
#			projDirY = -1
#		90:
#			projDirY = 1
#		_:
#			print ("lol")
	if host.get_facing_int() == -1:
		host.sprite.flip_h = true

func _tick():
	ungroundRegisterPeriod += 1
	if not hit_something:
		host.move_directly(projDirX, projDirY)
		
	if host.is_grounded() and ungroundRegisterPeriod > 2:
		hit_something = true
		host.disable()
		
func _frame_30():
	hit_something = true
	host.disable()
	
func _on_hit_something(obj,hitbox):
	._on_hit_something(obj,hitbox)
	hit_something = true
	host.disable()
