extends BaseProjectile

class_name TelekinesisProjectile

var launched = false





var got_perfect_parried = false




var got_push_blocked = false

export (PackedScene) var disable_obj
export (PackedScene) var disable_particle
export  var rumble = true
export  var no_hitlag = true
export  var disable_on_block = false

func _ready():
	
	
	._ready()
	state_variables.append_array(["got_perfect_parried", "got_push_blocked"])

func on_got_parried():
	.on_got_parried()
	got_perfect_parried = true

func on_got_push_blocked():
	.on_got_push_blocked()
	got_push_blocked = true

func disable():
	disable_action()

	if disable_obj:
		var obj = disable_obj
		var pos = get_pos()
		spawn_object(obj, 0, 0)
	
	if disable_particle:
		spawn_particle_effect_relative(disable_particle)

	.disable()
	if creator:
		if creator.boulder_projectile == obj_name:
			creator.boulder_projectile = null

func disable_action():
	if rumble:
		var camera: GoodCamera = get_camera()
		if camera:
			camera.bump(Vector2(), 10, 0.25)

func hit_action(obj):
	pass

func on_got_blocked():
	if disable_on_block:
		disable()

func tick():
	.tick()
	if no_hitlag:
		hitlag_ticks = 0

func drop():
	if current_state().name == "Default":
		current_state().drop()

func launch(data):

	state_machine.queue_state("Launch", data)

func launch_redirect(data):
	
	
	
	state_machine.queue_state("LaunchRedirect", data)
