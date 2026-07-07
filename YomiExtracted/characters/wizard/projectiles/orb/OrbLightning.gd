extends BaseProjectile






const NATIVE_SPRITE_WIDTH = 512
const BOLT_TOP_SOURCE_Y = 256
const BOLT_BOTTOM_SOURCE_Y = 390
const BOLT_HEIGHT = BOLT_BOTTOM_SOURCE_Y - BOLT_TOP_SOURCE_Y


const GROUND_ANCHOR_Y = 0





const PARTICLE_ABOVE_BOLT_BOTTOM = 22

func init(pos = null):
	.init(pos)
	_fit_sprite_to_spawn_height()

func on_got_push_blocked():
	if creator and not creator.disabled:
		creator.on_got_push_blocked()

func _fit_sprite_to_spawn_height():
	if not sprite:
		return
	var spawn_y = get_pos().y
	
	
	
	var vh = int(clamp(GROUND_ANCHOR_Y - spawn_y, 0, BOLT_HEIGHT))
	sprite.centered = false
	sprite.offset = Vector2( - NATIVE_SPRITE_WIDTH / 2.0, 0)
	sprite.scale = Vector2(1, 1)
	sprite.position = Vector2(0, 0)
	if vh <= 0:
		sprite.visible = false
		return
	
	
	var y_start = BOLT_BOTTOM_SOURCE_Y - vh
	var frames_copy: SpriteFrames = sprite.frames.duplicate()
	for anim in frames_copy.get_animation_names():
		for i in range(frames_copy.get_frame_count(anim)):
			var src = frames_copy.get_frame(anim, i)
			if src == null:
				continue
			var atlas: = AtlasTexture.new()
			atlas.atlas = src
			atlas.region = Rect2(0, y_start, NATIVE_SPRITE_WIDTH, vh)
			frames_copy.set_frame(anim, i, atlas)
	sprite.frames = frames_copy
	
	
	
	
	var particle = get_node_or_null("Flip/Particles/ParticleEffect")
	if particle:
		particle.position.y = vh - PARTICLE_ABOVE_BOLT_BOTTOM
