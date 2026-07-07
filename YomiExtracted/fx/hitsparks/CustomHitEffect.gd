extends ParticleEffect







var custom_config = null

func _ready():
	._ready()
	if custom_config is Dictionary:
		_apply_config(custom_config)

func _apply_config(config):
	var sprite_name = str(config.get("sprite", ""))
	var animated = get_node_or_null("AnimatedSprite")
	if animated:
		if sprite_name == "":
			var empty: = SpriteFrames.new()
			animated.frames = empty
			animated.visible = false
		else:
			var frames = load("res://fx/hitsparks/frames/%s_frames.tres" % sprite_name)
			if frames:
				animated.frames = frames
			animated.scale = Custom.HITSPARK_SPRITE_SCALES.get(sprite_name, Vector2(1, 1))
	_apply_particle_slot(
		get_node_or_null("CustomTrailParticle"), 
		bool(config.get("show_particles", false)), 
		config.get("particles", null))
	_apply_particle_slot(
		get_node_or_null("CustomTrailParticle2"), 
		bool(config.get("show_particles_2", false)), 
		config.get("particles_2", null))

func _apply_particle_slot(particle, show, settings):
	if particle == null:
		return
	if show and settings is Dictionary:
		
		
		
		particle.no_preprocess = true
		particle.auto_start_on_ready = true
		particle.load_settings(settings)
		particle.start_emitting()
	else:
		particle.queue_free()
