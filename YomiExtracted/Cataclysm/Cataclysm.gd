extends Fighter

var tween

var bloodfeast = 0

onready var bloodpoolexplosion = load("res://Cataclysm/characters/Cataclysm/SFX/casette_7_2-1.wav")
var bloodpools = [] #array to store all the bloodpools
var bloodpool_states = ["ToImpale", "Pivote", "Attract", "Carmilla", "Mutilate", "String"] #array of state names that can spawn the bloodpools, you can add more by following the same format that i used
onready var BLOODPOOL = load("res://Cataclysm/characters/Cataclysm/BLOODPOOL SCENE.tscn") #loading the bloodpool projectile earlier just for simplicity

func spawn_bloodpool(x = 0, y = 0): #x and y are the coordinates of where the bloodpool should spawn, you cal just leave it empty when calling this function to use 0,0 as the coordinates
	
	var bp = spawn_object(BLOODPOOL, x, y)
	bp.set_facing(get_facing_int())
	bloodpools.append(bp.obj_name)

#i made this a function so that you can use this inside a state by doing host.spawn_bloodpool() to manually spawn one
#could be cool setup, maybe leave a bloodpool whereever Chimera lands by doing host.spawn_bloodpool(data.x, 0) inside its script
#eh just throwing out ideas

func tick():
	.tick()
	if bloodfeast > 100:
		bloodfeast = 100
	if bloodfeast < 0:
		bloodfeast = 0
		
	for bp in bloodpools: #checks every bloodpool in the array
		var pool = obj_from_name(bp)
		if is_instance_valid(pool): 
			pass #if it exists, do nothing
		else:
			bp = "REMOVE" #otherwise set its name to be REMOVE
		bloodpools.erase("REMOVE") #rmeoves everything that has REMOVE written


func _on_hit_something(obj, hitbox): #runs everytime you hit something
	._on_hit_something(obj, hitbox)
	if obj == get_opponent() and current_state().state_name in bloodpool_states: #checks if you hit the opponent and the current state youre in can spawn bloodlpools
		spawn_bloodpool() #calls the function made earlier


func process_extra(extra): #this gets the data from the playerextra
	.process_extra(extra)
	if extra.has("attack"): #checks if its real
		if extra.attack == true:
			for bp in bloodpools: #checks every bloodpool
				var pool = obj_from_name(bp)
				if is_instance_valid(pool) and pool.current_state().state_name == "Default": #if therye valid and not attacking, then change their state
					print("attacking bloodpool " + bp) #testing purposes, you can remove this line
					pool.change_state("attack")
	if extra.has("bloodfeast"): #same thing as before
		if extra.bloodfeast == true:
			for bp in bloodpools:
				var pool = obj_from_name(bp)
				play_sound("BloodPoolExplosion2")
				if is_instance_valid(pool) and pool.current_state().state_name == "Default":
					print("bloodfeasting bloodpool " + bp) #testing purposes, you can remove this line
					pool.spawn_particle_effect_relative(load("res://Cataclysm/characters/Cataclysm/BloodPoolExplode.tscn"), Vector2(0, 0)) #this is the particle effect, you can just change the particle file path inside of load() and itll work out
					bloodfeast += 10
					pool.disable() #kills the bloodpool



func tween_camera_zoom(initial_value, end_value, duration, transition_type, ease_type):
	if is_ghost or ReplayManager.resimulating:
		return 
	var game = Global.current_game
	
	emit_signal("zoom_changed")
	if tween:
		tween.kill()
		set_camera_zoom(initial_value)
		
	tween = game.create_tween()
	
	tween.set_parallel(true)
	tween.set_trans(transition_type)
	tween.set_ease(ease_type)
	
	tween.tween_property(game, "camera_zoom", initial_value, 0.0025)
	
	tween.set_ease(ease_type)
	tween.tween_property(game, "camera_zoom", end_value, duration)
	
	yield (tween, "finished")
	if not is_instance_valid(self):
		return 
	tween.kill()
	game.update_camera_limits()
	
func set_camera_zoom(value):
	if is_ghost or ReplayManager.resimulating:
		return 
	if tween:
		tween.kill()
	var game = Global.current_game
	game.camera_zoom = value
	emit_signal("zoom_changed")
	game.update_camera_limits()

onready var default_parry = preload("res://fx/ParryEffect.tscn")
onready var custom_parry = preload("res://Cataclysm/characters/Cataclysm/ParryEffect.tscn")

func spawn_particle_effect(particle_effect:PackedScene, pos:Vector2, dir = Vector2.RIGHT):
	if particle_effect == default_parry:
		particle_effect = custom_parry
	.spawn_particle_effect(particle_effect, pos, dir)
