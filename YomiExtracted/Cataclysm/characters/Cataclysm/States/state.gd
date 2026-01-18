extends CharacterState

class_name CharacterStateCATACLYSM

export  var _c_Clashing_System = 0 # Creates Category on Inspector
export var clash_start = 0
export var clash_end = 0
export var clash_hitlag = 0

export var clash_ready_frame = 0

var clashed = false

export var custom_knockback = false
export (Vector2) var clash_knockback = Vector2(0, 0)
export (AudioStream) var clash_sound = null
export var clash_sound_volume_db = 0
export (PackedScene) var clash_particle_effect = null
export var custom_particle_direction = false
export (Vector2) var particle_direction = Vector2(0, 0)

var clash_available = false

var hb_disabled = false
var hb_return = false
var clash_candidates = []
var clashes_registered = []

func _frame_0():
	
	# Initializes Variables.

	hb_disabled = false
	hb_return = false
	clash_available = false
	clash_candidates.clear()
	clashes_registered.clear()
	clashed = false
	
	host.has_hyper_armor = false
	
	# Resets Hitbox Status.
	var shb = get_state_hitboxes()
	for hb in shb:
		hb.reset_hit_objects()
		hb.hit_objects.clear()

func _tick():
	
	# Self Clash Availability Check.
	clash_available = false 
	if current_tick >= clash_start and current_tick <= clash_end and host.CLASH_ELIGIBLE == true:
		clash_available = true
	else:
		clash_available = false
	
	
	# Identifies Objects that are Candidates to Clash ( Compares Availability ).
	for obj in host.objs_map.values():
		if is_instance_valid(obj):
			if obj.is_in_group("Fighter") and obj != host:
				if obj.current_state().get("clash_available") != null:
					if obj.current_state().clash_available and clash_available:
						clash_candidates.append(obj)
						
						# Debug Print:
						# print(str(host.name) + " Clashing With: " + str(obj.name))
	
	# Checks Clash Timing for Each Candidate.
	for object in clash_candidates:
		if object.current_state().get("clash_available") != null:
			
			# Opp / Own State Hitboxes.
			var own_hbs = get_state_hitboxes()
			var opp_hbs = object.current_state().get_state_hitboxes()
			
			# Opp / Own Active Hitboxes.
			var own_ahbs = get_active_hitboxes()
			var opp_ahbs = object.get_active_hitboxes()
			
			# Adds Opponent / Self to Hit Hitbox Group Exclusion.
			if hb_disabled != true:
				for own_hb in own_hbs:
					own_hb.save_hit_object(object)
				for opp_hb in opp_hbs:
					opp_hb.save_hit_object(host)
				hb_disabled = true

			# Executes Clashes:
			for own_hb in own_ahbs:
				for opp_hb in opp_ahbs:
					if own_hb.overlaps(opp_hb):
						if !clashes_registered.has(opp_hb):
							clashed = true
							host.reset_momentum()
							host.set_camera_zoom(0.75)
							host.tween_camera_zoom(0.75, 1.00, 0.60, Tween.TRANS_QUINT, Tween.EASE_OUT)
							host.screen_bump(Vector2.RIGHT * host.get_facing_int(), 10, 10 / 65.0)
							host.hitlag_ticks += clash_hitlag
							host.opponent.hitlag_ticks += clash_hitlag
							host.refresh_feints()
							host.opponent.refresh_feints()
							host.has_hyper_armor = true
							# Debug Print:
							# print(str(host.name) + " - Clash Triggered At: " + str(current_tick))
							
							#host.reset_momentum()
							
							if custom_knockback:
								object.set_vel( str(float(object.get_vel().x) + float(clash_knockback.x * host.get_facing_int())) , str(float(object.get_vel().y) + float(clash_knockback.y)) )
							else:
								object.set_vel(str(float(object.get_vel().x) + float(float(own_hb.dir_x) * float(own_hb.knockback) * host.get_facing_int())), str(float(object.get_vel().y) + float(own_hb.dir_y) * float(own_hb.knockback) ))
							
							var xy = own_hb.get_overlap_center_float(opp_hb)
							
							if custom_particle_direction:
								host.spawn_particle_effect(clash_particle_effect, Vector2(xy.x, xy.y), particle_direction)
							else:
								host.spawn_particle_effect(clash_particle_effect, Vector2(xy.x, xy.y), Vector2( float(own_hb.dir_x) * host.get_facing_int(), float(own_hb.dir_y) ))
							
							play_clash_sound()
							clashes_registered.append(opp_hb)
						else:
							pass
	
	# Returns Candidates's Hitbox / Active Hitbox Exclusion list to normal after clash timing ends.
	if current_tick > clash_end and hb_return == false:
		for pl in clash_candidates:
			if pl.current_state().get("clash_available") != null:
				var ohb = pl.current_state().get_state_hitboxes()
				var oahb = pl.get_active_hitboxes()
				for hb in ohb:
					while hb.hit_objects.has(host.name):
						hb.hit_objects.erase(host.name)
				for hb in oahb:
					while hb.hit_objects.has(host.name):
						hb.hit_objects.erase(host.name)
		hb_return = true
		
	
	# Makes you ready on set Frame after Clash
	if current_tick == clash_ready_frame and clashed == true:
		host.state_interruptable = true
		next_state_on_hold = false
	
	
	
	._tick()

func get_state_hitboxes():
	var hitboxes = []
	for child in get_children():
		if child is Hitbox:
			hitboxes.append(child)
	return hitboxes
	
func play_clash_sound():
	if host:
		var Player = VariableSound2D.new()
		Player.volume_db = 0
		Player.bus = "Fx"
		Player.pitch_variation = 0.0
		Player.stream = clash_sound
		Player.one_shot = true
		host.get_node("Sounds").add_child(Player)
		Player.play()
