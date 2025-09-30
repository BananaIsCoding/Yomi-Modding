extends ObjectState
var _tickCountTillEnd = 0
var _charging = false

func _ready():
	._ready()
	# reset when move is ready to use
	_tickCountTillEnd = 0
	_charging = false


func _enter():
	._enter()
	_charging = true

func _frame10():
	print("Yo")
	
func _exit():
	host.disable()
