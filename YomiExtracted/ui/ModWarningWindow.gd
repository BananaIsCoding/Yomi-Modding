extends Window

onready var timer = $Timer
onready var ok_button = $"%OkButton"







func _ready():
	set_process(false)
	pass

func start():
	show()
	set_process(true)
	timer.start()

func _process(delta):
	$"%TimerLabel".text = str(ceil(timer.time_left))
	pass

func _on_OkButton_pressed():
	self.queue_free()
	pass


func _on_Timer_timeout():
	ok_button.disabled = false
	pass
