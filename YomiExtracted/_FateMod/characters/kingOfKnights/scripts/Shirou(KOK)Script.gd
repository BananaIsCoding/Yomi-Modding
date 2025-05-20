extends "res://projectile/BaseProjectile.gd"

signal action_selected(action, data)
signal super_started(freeze_ticks)
signal parried()
#signal got_parried()
signal undo()
signal forfeit()
signal clashed()

signal blocked_melee_attack()
signal blocked_melee_attack_at_frame(frame)
signal predicted(freeze_ticks)

var MAX_HEALTH = 1500

const MAX_STALES = 15
const MIN_STALE_MODIFIER = "0.2"

const WALL_SLAM_DAMAGE = "0.75"
const DI_SNAP_DISTANCE = "0.01"

const DAMAGE_SUPER_GAIN_DIVISOR = 1
const DAMAGE_TAKEN_SUPER_GAIN_DIVISOR = 3
const HITLAG_COLLISION_TICKS = 4
const PROJECTILE_PERFECT_PARRY_WINDOW = 3
const BURST_ON_DAMAGE_AMOUNT = 5
const AUTO_PARRY_TICKS = 20
const SADNESS_IMMUNITY_TICKS = 60

const VISUAL_GUTS_RATIO = 1.5

const MAX_WALL_SLAMS = 3

const COUNTER_HIT_ADDITIONAL_HITLAG_FRAMES = 0

const MAX_GROUNDED_HITS = 7
const PREDICTION_CORRECT_SUPER_GAIN = 30
const INCORRECT_PREDICTION_LAG = 7

const PARRY_CHIP_DIVISOR = 3
const PUSH_BLOCK_CHIP_MODIFIER = "0.33"
const PARRY_KNOCKBACK_DIVISOR = "3"

const PARRY_COMBO_SCALING = "0.85"
const PARRY_GROUNDED_KNOCKBACK_DIVISOR = "1.5"
const PUSH_BLOCK_FORCE = "-10"
const PUSH_BLOCK_DIST = "220"
const PUSH_BLOCK_ADVANTAGE_PENALTY = 0
const AIR_BLOCK_PUSHBACK_MODIFIER = "0.35"
const WAKEUP_THROW_IMMUNITY_TICKS = 3

const GLOBAL_HITLAG_MODIIFER = 0.6
const GLOBAL_BLOCKLAG_MODIFIER = 0.25
const MAX_GLOBAL_HITLAG = 10

const BASE_PLUS_FRAMES = 0
const VS_AERIAL_ADDITIONAL_PLUS_FRAMES = 2
const WRONG_HIT_HEIGHT_ADDITIONAL_PLUS_FRAMES = 2

const DISTANCE_EXTRA_SADNESS = "180"
const MIN_DIST_SADNESS = "128"

const GUARD_BREAK_SCALING = 1

const MISSED_BRACE_DAMAGE_MULTIPLIER = "1.0"
const SUCCESSFUL_BRACE_HITSTUN_MODIFIER = "0.35"
const SUCCESSFUL_BRACE_DI_MODIFIER = "1.5"
const COUNTER_HIT_DAMAGE_MODIFIER = "1.1"

var HOLD_RESTARTS = [
	"Wait", 
	"Fall", 
	"DashForward", 

	"ParryHigh", 
	"BlockHigh", 
	"ParryLow", 
	"ParryAir", 
]

var HOLD_FORCE_STATES = {
	"ParrySuper":"ParryHigh", 


	"DashBackward":"Wait", 

}

const P1_COLOR = Color("aca2ff")
const P2_COLOR = Color("ff7a81")

const GUTS_REDUCTIONS = {
	"1.0":"1.0", 
}

const GUTS_REDUCTIONS_OLD = {
	"1":"1", 
	"0.70":"0.90", 
	"0.60":"0.80", 
	"0.50":"0.70", 
	"0.40":"0.60", 
	"0.30":"0.55", 
	"0.20":"0.52", 
	"0.10":"0.50", 
}

const MAX_GUTS = 10

const MAX_BURSTS = 1
const BURST_BUILD_SPEED = 4
const MAX_BURST_METER = 1500
const START_BURSTS = 1

const MAX_SUPER_METER = 125
const MAX_SUPERS = 9
const VEL_SUPER_GAIN_DIVISOR = 4
const AERIAL_VELOCITY_SUPER_GAIN_MODIFIER = "0.5"

const NUDGE_DISTANCE = 20

const PARRY_METER = 50

const METER_GAIN_MODIFIER = "0.85"

const CLASH_MOVE_BACK = 3

const MIN_PENALTY = - 20
const MAX_PENALTY = 75
const PENALTY_MIN_DISPLAY = 50

const PENALTY_TICKS = 120

export  var _c_NEW_MODDED_CHARACTERS_IMPORTANT = 0
export  var _c_ENABLE_THIS_SETTING_IF_YOU_WANT_CONSISTENCY_WITH_THE_BASE_CAST = 0
export  var enable_extra_aesthetic_hitstop = false
export  var _c_THANK_YOU = 0

export  var num_air_movements = 2
export  var lose_one_air_option_in_neutral = true
export  var use_air_option_bar = false
export  var air_option_bar_max = 100
export  var air_option_bar = 0
export  var air_option_bar_name = "Air Options"

export (Texture) var character_portrait
export (Texture) var character_portrait2

onready var you_label = $YouLabel
onready var actionable_label = $ActionableLabel
onready var quitter_label = $"%QuitterLabel"
onready var velocity_label_container = $VelocityLabelContainer
onready var grounded_indicator = $GroundedIndicator
onready var block_frame_label = $BlockFrameLabel
onready var hit_frame_label = $HitFrameLabel

var input_state = InputState.new()

var color = Color.white

var style_extra_color_1 = extra_color_1
var style_extra_color_2 = extra_color_2

export (PackedScene) var player_info_scene
export (PackedScene) var player_extra_params_scene

export  var damage_taken_modifier = "1.0"
export  var knockback_taken_modifier = "1.0"
export  var di_modifier = "1.0"
export  var num_feints = 2

export  var use_extra_color_1 = false
export  var extra_color_1 = Color("ff00ff")
export  var use_extra_color_2 = false
export  var extra_color_2 = Color("ff00ff")

var global_damage_modifier = "1.0"
var global_hitstun_modifier = "1.0"
var global_hitstop_modifier = "1.0"
var min_di_scaling = "1.0"
var max_di_scaling = "6.0"
var di_combo_limit = 15

var ghost_blocked_melee_attack = - 1
var ghost_got_hit = false

var opponent

var actions = 0

var visible_combo_count = 0
var buffered_global_hitlag = 0

var queued_action = null
var queued_data = null
var queued_extra = null
var buffered_input = {}
var last_input = {}
var previous_input = {}
var use_buffer = false

var hit_out_of_brace = false
var braced_attack = false
var brace_effect_applied_yet = false

var dummy_interruptable = false

var game_over = false
var forfeit = false
var will_forfeit = false

var applied_style = null
var is_color_active = false
var is_aura_active = false
var is_style_active = null
var touching_wall = false
var was_my_turn = false



var touch_of_death = true

var ivy_effect = false
var ivy_effect_t = 0.0

var colliding_with_opponent = true

var air_movements_left = 0

var action_cancels = {
}

var ghost_ready_tick = null
var ghost_ready_set = false
#var got_parried = false
var got_blocked = false

var block_used_air_movement = false

var di_enabled = true
var turbo_mode = false
var extremely_turbo_mode = false
var infinite_resources = false
var one_hit_ko = false
var burst_enabled = true
var always_perfect_parry = false
var blocked_last_hit = false
var blocked_last_turn = false
var sadness_enabled = false
var last_turn_block = false

var trail_hp:int = MAX_HEALTH
var hp:int = 999999999
var super_meter:int = 0
var supers_available:int = 0
var combo_proration:int = 0
var last_parry_tick = 0

var parried_last_state = false
var initiative_effect = false

var clipping_wall = false
var burst_meter:int = 0
var bursts_available:int = 0
var turn_frames = 0

var busy_interrupt = false
var any_available_actions = true
var refresh_prediction = false
var burst_cancel_combo = false

var parry_chip_divisor = PARRY_CHIP_DIVISOR
var parry_knockback_divisor = PARRY_KNOCKBACK_DIVISOR

var moved_forward = false
var buffer_moved_forward = false

var moved_backward = false
var buffer_moved_backward = false
var blocked_hitbox_plus_frames = 0

var had_sadness = false

var state_changed = false
var on_the_ground = false
var nudge_amount = "1.0"
var used_air_dodge = false
var used_buffer = false

var has_hyper_armor = false
var has_projectile_armor = false
var hit_during_armor = false

var projectile_hit_cancelling = false

var melee_attack_combo_scaling_applied = false

var wall_slams = 0

var counterhit_this_turn = false
var guard_broken_this_turn = false

var last_pos = null
var penalty = 0
var penalty_buffer = 0
var penalty_ticks = 0
var blockstun_ticks = 0
var sadness_immunity_ticks = 0

var emote_tween:SceneTreeTween

var feints = 2
var feinted_last = false
var feint_parriable = false

var grounded_last_frame = true

var super_meter_used_recently = 0
var super_meter_grace_ticks = 0
const SUPER_METER_GRACE_PERIOD = 3
const SUPER_METER_GRACE_DIVISOR = 2



var ghost_was_in_air = false
var ghost_wrong_block = ""

var current_nudge = {
	"x":"0", 
	"y":"0", 
}

var current_di = {
	"x":"0", 
	"y":"0", 
}

var last_vel = {
	"x":"0", 
	"y":"0", 
}

var last_aerial_vel = {
	"x":"0", 
	"y":"0", 
}

var combo_moves_used = {}

var reverse_state = false
var ghost_reverse = false

var nudge_distance_left = 0

var can_nudge = false
var parried = false

var busy = false

var initiative = false
var aura_particle = null

var in_blockstring = false
var brace_enabled = false

var parry_combo = false

var feinting = false
var clashing = false

var last_action = 0

var stance = "Normal"

var parried_hitboxes = []

var grounded_hits_taken = 0

var throw_pos_x = 16
var throw_pos_y = - 5

var combo_supers = 0
var combo_damage = 0
var hitlag_applied = 0
var forfeit_ticks = 0

var minus_frames = 0

var hitstun_decay_combo_count = 0

var lowest_tick = 0
var wakeup_throw_immunity_ticks = 0

class InputState:
	var name
	var data


#hello cat and others! If you see this, play white knuckle its really really good!
func use_super_meter(amount):
	if infinite_resources:
		return 
	super_meter -= amount
	if super_meter < 0:
		if supers_available > 0:
			super_meter = MAX_SUPER_METER + super_meter
			use_super_bar()
		else :
			super_meter = 0
func use_super_bar():
	if infinite_resources:
		return 
	supers_available -= 1
	if supers_available < 0:
		supers_available = 0
		super_meter = 0
	super_meter_grace_ticks = SUPER_METER_GRACE_PERIOD
	super_meter_used_recently += MAX_SUPER_METER

func take_damage(damage:int, minimum = 0, meter_gain_modifier = "1.0", combo_scaling_offset = 0, damage_taken_meter_gain_modifier = "1.0"):
	
	if opponent.combo_count == 0:
		trail_hp = get_visual_hp()

	if damage == 0:
		return 

	gain_burst_meter(damage / BURST_ON_DAMAGE_AMOUNT)
	var damage_score = Utils.int_max(damage, minimum)
	damage = Utils.int_max(combo_stale_damage(damage, combo_scaling_offset), 1)
	damage = Utils.int_max(damage, minimum)
	damage = Utils.int_max(guts_stale_damage(damage), 1)
	if opponent.parry_combo:
		damage = fixed.round(fixed.mul(str(damage), PARRY_COMBO_SCALING))
	damage = fixed.round(fixed.mul(str(damage), get_penalty_damage_modifier()))
	var meter_gain = fixed.round(fixed.mul(str(damage / DAMAGE_SUPER_GAIN_DIVISOR), meter_gain_modifier))

	opponent.gain_super_meter(meter_gain)
	gain_super_meter(fixed.round(fixed.mul(str(damage / DAMAGE_TAKEN_SUPER_GAIN_DIVISOR), damage_taken_meter_gain_modifier)))
	damage = fixed.round(fixed.mul(fixed.mul(str(damage), damage_taken_modifier), global_damage_modifier))
	opponent.combo_damage += damage
	hp -= damage
	add_penalty( - 25)
	if hp < 0:
		hp = 0
	if current_state().get("IS_NEW_PARRY") and current_state().push:
		if hp <= 0:
			hp = 1

func gain_burst_meter(amount = null):
	if not burst_enabled:
		return 

	if penalty_ticks > 0:
		return 
		
	if bursts_available < MAX_BURSTS:
		var burst_build_speed = BURST_BUILD_SPEED if amount == null else amount
		if amount == null:
			
			if combo_count <= 0 and opponent.combo_count <= 0:
				burst_build_speed -= 1
				if not is_grounded():
					burst_build_speed -= 1
		if burst_cancel_combo:
			burst_build_speed -= 3

		burst_meter += burst_build_speed
		if burst_meter > MAX_BURST_METER:
			gain_burst()

func combo_stale_damage(damage:int, combo_scaling_offset = 0):
	var staling = get_combo_stale(Utils.int_max(opponent.combo_count - combo_scaling_offset + (opponent.combo_proration if opponent.combo_count > 1 else 0) - 1, 0))
	return fixed.round(fixed.mul(str(damage), staling))

func guts_stale_damage(damage:int):
	var guts = get_guts()
	damage = fixed.round(fixed.mul(str(damage), guts))
	return damage
	
func get_penalty_damage_modifier():
	var min_penalty_for_damage = 20
	if penalty_ticks > 0:
		return "1.5"
	if penalty < min_penalty_for_damage:
		return "1.0"
	return fixed.add("1.0", fixed.mul(fixed.div(str(penalty - min_penalty_for_damage), str(MAX_PENALTY - min_penalty_for_damage)), "0.5"))

func gain_super_meter(amount, stale_amount = "1.0"):
	
	if amount == null:
		return 

	var full_staled_amount = combo_stale_meter(amount)
	amount = fixed.round(fixed.lerp_string(str(amount), str(full_staled_amount), stale_amount))
	amount = meter_gain_modified(amount)
	var super_modified_amount = fixed.round(fixed.div(str(amount), fixed.powu("2", combo_supers)))
	amount = fixed.round(fixed.lerp_string(str(amount), str(super_modified_amount), stale_amount))
	gain_super_meter_raw(amount)


func add_penalty(amount, ignore_min_distance = false):
	if not sadness_enabled:
		return 

	if sadness_immunity_ticks > 0:
		return 

	if amount > 0:
		if not ignore_min_distance:
			var opp_pos = obj_local_center(opponent)
			var opp_dist = fixed.vec_len(str(opp_pos.x), str(opp_pos.y))
			if fixed.lt(opp_dist, MIN_DIST_SADNESS):
				return 
				
		var modifier = "1.0"
		if is_grounded() and not opponent.is_grounded():
			modifier = "0.25"
		elif not is_grounded() and opponent.is_grounded():
			modifier = "1.0"
		amount = fixed.round(fixed.mul(str(amount), modifier))
	else :
		var modifier = "1.0"
		if not is_grounded() and opponent.is_grounded():
			modifier = "0.75"
		amount = fixed.round(fixed.mul(str(amount), modifier))
	
	if hp < opponent.hp:
		var diff = Utils.int_abs(hp - opponent.hp)
		var ratio = fixed.sub("1", fixed.div(str(diff), "3000"))

		amount = fixed.round(fixed.mul(str(amount), ratio))
	

	penalty += amount
	if penalty > MAX_PENALTY:
		supers_available = 0
		super_meter = 0
		penalty = 0
		penalty_buffer = 0
		penalty_ticks = PENALTY_TICKS
		had_sadness = true
	if penalty < MIN_PENALTY:
		penalty = MIN_PENALTY

func get_visual_hp():
	var ratio = float(hp) / MAX_HEALTH
	return MAX_HEALTH * pow(ratio, VISUAL_GUTS_RATIO)

func gain_burst():
	if bursts_available < MAX_BURSTS:
		bursts_available += 1
		burst_meter = 0

func get_combo_stale(count):
	var ratio = fixed.div(fixed.sub(str(MAX_STALES), str(Utils.int_min(count, MAX_STALES))), str(MAX_STALES))
	var mod = fixed.mul(fixed.sub("1", MIN_STALE_MODIFIER), fixed.powu(ratio, 2))
	mod = fixed.add(mod, MIN_STALE_MODIFIER)
	return mod
	
func get_guts():
	var current_guts = "1"
	for level in GUTS_REDUCTIONS:
		var hp_level = fixed.div(str(hp), str(MAX_HEALTH))
		if fixed.le(hp_level, level):
			current_guts = GUTS_REDUCTIONS[level]
	return current_guts

func combo_stale_meter(meter:int):
	var staling = get_combo_stale(combo_count)
	return fixed.round(fixed.mul(fixed.mul(str(meter), staling), METER_GAIN_MODIFIER if current_tick > 0 else "1.0"))
	
func meter_gain_modified(amount):
	if penalty_ticks > 0:
		return 0
	var pen = fixed.div(str(penalty), str(MAX_PENALTY))
	if penalty <= 0:
		pen = fixed.div(pen, "5.0")
	amount = fixed.round(fixed.mul(fixed.sub("1", pen), str(amount)))
	return amount

func gain_super_meter_raw(amount):
	super_meter += amount
	var played_sound = false
	while super_meter >= MAX_SUPER_METER:
		if supers_available < MAX_SUPERS:
			super_meter -= MAX_SUPER_METER
			supers_available += 1
			if not played_sound:
				played_sound = true
				play_sound("SuperGain")
				play_sound("SuperGain2")
		else :
			super_meter = MAX_SUPER_METER

func is_in_hurt_state(count_all = true):
	var state = current_state()
	if count_all:
		return state.busy_interrupt_type == CharacterState.BusyInterrupt.Hurt or state.is_hurt_state
	else :
		return state.is_hurt_state

func update_facing():
	if obj_data.position_x < opponent.obj_data.position_x:
		set_facing(1)
	elif obj_data.position_x > opponent.obj_data.position_x:
		set_facing( - 1)
	if initialized:
		update_data()

func change_stance_to(stance):
	self.stance = stance

func set_lowest_tick(tick):
	if lowest_tick == null or tick < lowest_tick:
		lowest_tick = tick

func was_moving_forward():
	return moved_forward and current_state().has_hitboxes

func init(pos = null):
	opponent=get_opponent()
	.init(pos)
	#remove_from_group("Fighter")
func _ready():
	can_be_hit_by_melee=true
	#remove_from_group("Fighter")
#	print(creator_name)
#	print(objs_map[creator_name])
#	print(obj_from_name(creator_name))
#	breakpoint
#	var awful=creator
#	creator=null
	
#	sprite.frames=get_fighter().sprite.frames
#	creator=awful
	
func get_move_dir():
	return fixed.sign(last_vel.x)

func hit_by(hitbox, force_hit = false):
#	if parried:
#		return 
#	if hitbox.name in parried_hitboxes:
#		return 
#	if not hitbox.hits_otg and is_otg():
#		return 
#	if not hitbox.hits_vs_dizzy and current_state().state_name == "HurtDizzy":
#		return 
#	if can_counter_hitbox(hitbox):
#		counter_hitbox(hitbox)
#	elif current_state() is CounterAttack:
#		hit_out_of_brace = true
#
#	if hitbox.throw and not is_otg():
#		return thrown_by(hitbox)
#	if force_hit or ( not can_parry_hitbox(hitbox)):
	ghost_got_hit = true
	match hitbox.hitbox_type:
		Hitbox.HitboxType.Normal:
			launched_by(hitbox)
		Hitbox.HitboxType.NoHitstun:
			take_damage(hitbox.damage if opponent.combo_count <= 0 else hitbox.damage_in_combo)
		Hitbox.HitboxType.Burst:
			launched_by(hitbox)
#		Hitbox.HitboxType.Flip:
#			set_facing(get_facing_int() * - 1, true)
#			var vel = get_vel()
#			set_vel(fixed.mul(vel.x, "-1"), vel.y)
#			for hitbox in hitboxes:
#				hitbox.facing = get_facing()
#				pass
#			emit_signal("got_hit")
#			increment_opponent_combo(hitbox)
#			take_damage(hitbox.get_damage(), hitbox.minimum_damage, hitbox.meter_gain_modifier)
		Hitbox.HitboxType.ThrowHit:
			emit_signal("got_hit")
			apply_hitlag(hitbox)
			opponent.apply_hitlag(hitbox)
			if hitbox.rumble:
				rumble(hitbox.screenshake_amount, hitbox.victim_hitlag if hitbox.screenshake_frames < 0 else hitbox.screenshake_frames)
			take_damage(hitbox.get_damage(), hitbox.minimum_damage, hitbox.meter_gain_modifier)

			opponent.incr_combo(hitbox.scale_combo, false, false, hitbox.combo_scaling_amount)
		Hitbox.HitboxType.OffensiveBurst:
			opponent.hitstun_decay_combo_count = 0

			launched_by(hitbox)
			reset_pushback()
			opponent.reset_pushback()
#	else :
#		block_hitbox(hitbox)

func launched_by(hitbox):
	
	if super_meter_used_recently > 0:
		gain_super_meter_raw(super_meter_used_recently / SUPER_METER_GRACE_DIVISOR)
		super_meter_used_recently = 0
		super_meter_grace_ticks = 0
	

	apply_hitlag(hitbox, hitbox.followup_state == "")
	feinting = false
	
	if objs_map.has(hitbox.host):
		var host = objs_map[hitbox.host]
		var host_hitlag_ticks = fixed.round(fixed.mul(str(hitbox.hitlag_ticks), global_hitstop_modifier))
		if host.hitlag_ticks < host_hitlag_ticks:
			host.hitlag_ticks = host_hitlag_ticks
	
	if hitbox.rumble:
		var length = hitbox.victim_hitlag if hitbox.screenshake_frames < 0 else hitbox.screenshake_frames
		rumble(hitbox.screenshake_amount, length + (length * GLOBAL_HITLAG_MODIIFER))
	
	nudge_amount = hitbox.sdi_modifier
	
	var host = objs_map[hitbox.host]
	var projectile = not host.is_in_group("Fighter")
	
	var will_launch = hitbox.ignore_armor or not has_armor()
	if not hitbox.ignore_armor:
		if projectile and has_projectile_armor() and not hitbox.ignore_projectile_armor:
			will_launch = false
	var will_block = false
	var autoblock = has_autoblock_armor()
	if will_launch:
		if autoblock:
			if not hitbox.ignore_projectile_armor and not hitbox.ignore_armor:
				will_launch = false
				will_block = not projectile

	var scaling_offset = hitbox.combo_scaling_amount - 1
	

	

	if will_launch:
		var state
		if is_grounded():
			state = hitbox.grounded_hit_state
		else :
			state = hitbox.aerial_hit_state

		if state == "HurtGrounded":
			grounded_hits_taken += 1
			if grounded_hits_taken >= MAX_GROUNDED_HITS:
				if not hitbox.force_grounded:
					state = "HurtAerial"
					grounded_hits_taken = 0

#		increment_opponent_combo(hitbox)
		
		
		state_machine._change_state(state, {"hitbox":hitbox})
		if hitbox.disable_collision:
			colliding_with_opponent = false

		busy_interrupt = true
		can_nudge = true
#
#		if not projectile:
#			refresh_feints()
#			opponent.refresh_feints()


		
		on_launched()

#	elif will_block:
#		change_state("ParryHigh" if not autoblock else "ParryAuto")
#		block_hitbox(hitbox, false, true, false, autoblock)

	if has_hyper_armor:
		hit_during_armor = true

	emit_hit_by_signal(hitbox)
	var damage = hitbox.get_damage()
	if will_block:
		damage = fixed.round(fixed.mul(str(damage), "0.5"))
	if hitbox.counter_hit:
		damage = fixed.round(fixed.mul(str(damage), COUNTER_HIT_DAMAGE_MODIFIER))
	take_damage(damage, hitbox.minimum_damage, hitbox.meter_gain_modifier, scaling_offset)

	if will_launch:
		state_tick()

func apply_hitlag(hitbox, global = true):
	hitlag_ticks = (hitbox.victim_hitlag) + (COUNTER_HIT_ADDITIONAL_HITLAG_FRAMES if hitbox.counter_hit else 0)
	if braced_attack:
		hitlag_ticks = fixed.round(fixed.mul(str(hitlag_ticks), SUCCESSFUL_BRACE_HITSTUN_MODIFIER))
	hitlag_ticks = fixed.round(fixed.mul(str(hitlag_ticks), global_hitstop_modifier))
	hitlag_applied = hitlag_ticks
	var host = obj_from_name(hitbox.host)
	if global and host and host.get("enable_extra_aesthetic_hitstop"):
		buffered_global_hitlag = min(hitbox.hitlag_ticks * GLOBAL_HITLAG_MODIIFER, MAX_GLOBAL_HITLAG)
		
func has_armor():
	return has_hyper_armor

func has_autoblock_armor():
	return false

func has_projectile_armor():
	return has_projectile_armor

func emit_hit_by_signal(hitbox):
	emit_signal("got_hit")
	if hitbox == null:
		return 
	if hitbox.get("host") == null:
		return 
	if hitbox.host is String:
		var host = objs_map[hitbox.host]
		if host.is_in_group("Fighter"):
			emit_signal("got_hit_by_fighter")
		else :
			emit_signal("got_hit_by_projectile")
			
func on_launched():
	pass

func release_opponent():
	if opponent.current_state().state_name == "Grabbed":
		opponent.change_state("Fall")
func refresh_air_movements():
	if not lose_one_air_option_in_neutral:
		air_movements_left = num_air_movements
		return 
	if num_air_movements == 0:
		air_movements_left = 0
		return 
	air_movements_left = Utils.int_max(num_air_movements - 1, 1) if combo_count == 0 else num_air_movements
func clear_buffer():
	buffered_input = {}

func get_scaled_di(di):
#	var scaling = get_di_scaling()
#	var result = xy_to_dir(di.x, di.y, scaling)
#	var result = xy_to_dir("0", "0", scaling)
#	var length = fixed.vec_len(result.x, result.y)
#	if fixed.lt(fixed.abs(fixed.sub(length, scaling)), DI_SNAP_DISTANCE) or fixed.gt(length, scaling):
#		result = fixed.normalized_vec_times(result.x, result.y, scaling)
	#i didnt see the point of preserving di, feel free to uncomment out this code and get it to work
	return {"x":"0.0","y":"0.0"}
	
func get_di_scaling(brace = true):
	if brace and hit_out_of_brace:
		return "0"
	var max_extra_di = fixed.sub(max_di_scaling, min_di_scaling)
	var scaling_amount = str(Utils.int_clamp(opponent.combo_count, 0, di_combo_limit))
	var scaling_ratio = fixed.div(scaling_amount, str(di_combo_limit))
	var total_extra_scaling = fixed.mul(max_extra_di, scaling_ratio)
	var total = fixed.add(min_di_scaling, total_extra_scaling)
	if brace and braced_attack:
		total = fixed.mul(total, SUCCESSFUL_BRACE_DI_MODIFIER)
	total = fixed.mul(total, di_modifier)
#	return total
	return 0
func start_sadness_immunity():
	sadness_immunity_ticks = SADNESS_IMMUNITY_TICKS

func on_grabbed():
	pass

func gain_air_option_bar(amount):
	air_option_bar += amount
	if air_option_bar > air_option_bar_max:
		air_option_bar = air_option_bar_max

func get_active_projectiles():
	var objs = []
	for obj_name in objs_map:
		var obj = obj_from_name(obj_name)
		if obj and not obj.disabled and obj.id == id and not obj.is_in_group("Fighter"):
			objs.append(obj)
	return objs

func unlock_achievement(achievement_name, multiplayer_only = false):
	pass

func get_opponent_dir_vec(normalized = true):
	var my_pos = get_pos()
	var opp_pos = opponent.get_pos()
	
	if normalized:
		return fixed.normalized_vec(str(opp_pos.x - my_pos.x), str(opp_pos.y - my_pos.y))
	return {
		"x":opp_pos.x - my_pos.x, 
		"y":opp_pos.y - my_pos.y
	}
func get_opponent_dir():
	return Utils.int_sign(opponent.get_pos().x - get_pos().x)

func drain_air_option_bar(amount):
	if infinite_resources:
		return 
	air_option_bar -= amount
	if air_option_bar < 0:
		air_option_bar = 0

func stack_move_in_combo(move_name):
	if combo_moves_used.has(move_name):
		combo_moves_used[move_name] += 1
	else :
		combo_moves_used[move_name] = 1

func on_state_interruptable(state = null):
	if not dummy:
		state_interruptable = true
		was_my_turn = true
	else :
		dummy_interruptable = true
		refresh_prediction = true

func incr_combo(scale = true, projectile = false, force = false, combo_scale_amount = 1):
	if (scale and ( not melee_attack_combo_scaling_applied or projectile)) or force:
		combo_count += combo_scale_amount
		hitstun_decay_combo_count += 1
	visible_combo_count += 1
	if combo_count == 2 and combo_moves_used.has("Burst"):
		unlock_achievement("ACH_UNFAIR")

func get_global_throw_pos():
	var pos = get_pos()
	pos.x += throw_pos_x * get_facing_int()
	pos.y += throw_pos_y
	return pos

