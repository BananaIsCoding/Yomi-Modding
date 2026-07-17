extends ParticleEffect

func tick():
	if hooks:
		hooks.tick()
	set_enabled(true)
	tick_timer.start()
	tick += 1
	for child in get_children():
		if child is AnimatedSprite:
			if child.frames == null:
				continue
			if child.frames.get_frame_count(child.animation) > tick:
				child.frame = tick
			
		if child is AudioStreamPlayer2D:
			if not child.playing and not sounds_played[child]:
				child.play()
				sounds_played[child] = true
	if free:
		if tick / 60.0 >= lifetime:
			queue_free()
			print ("Bye Bye")
