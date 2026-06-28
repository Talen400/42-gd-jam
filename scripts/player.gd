extends CharacterBody2D

const GRAVITY := 1500.0
const JUMP_VELOCITY := -600.0
const GROUND_Y := 320.0
const NO_CLIP_MAX_DURATION := 0.5
const NO_CLIP_MAX_COOLDOWN := 1.5
const NO_CLIP_DURATION := 0.4   # duração do efeito após ativação bem-sucedida
const INVULNERABLE_TIME := 1.0

var grounded := true
var no_clip_active := false
var no_clip_timer := 0.0
#var no_clip_cooldown := 0.0
var invulnerable_timer := 0.0

func _ready():
	add_to_group("players")
	setup_sounds()

func setup_sounds():
	var gen1 = AudioStreamGenerator.new()
	gen1.mix_rate = 44100
	gen1.buffer_length = 0.1
	$JumpSound.stream = gen1
	var gen2 = AudioStreamGenerator.new()
	gen2.mix_rate = 44100
	gen2.buffer_length = 0.15
	$NoClipSound.stream = gen2

func play_tone(player: AudioStreamPlayer, freq: float, duration: float, volume: float = 0.3):
	var playback = player.get_stream_playback()
	if playback and playback.get_frames_available() > 200:
		var sample_count = int(44100 * duration)
		for i in sample_count:
			var t = float(i) / 44100.0
			var value = sin(freq * t * TAU) * volume
			value *= max(0, 1.0 - t / duration)
			playback.push_frame(Vector2(value, value))

func _process(delta):
	if not grounded:
		velocity.y += GRAVITY * delta
	position.y += velocity.y * delta
	if position.y >= GROUND_Y:
		position.y = GROUND_Y
		velocity.y = 0
		grounded = true

	if no_clip_active:
		no_clip_timer -= delta
		if no_clip_timer <= 0:
			no_clip_active = false

	# Não há mais cooldown
	if invulnerable_timer > 0:
		invulnerable_timer -= delta

	if invulnerable_timer > 0:
		invulnerable_timer -= delta
		if invulnerable_timer < 0:
			invulnerable_timer = 0

	queue_redraw()

func _draw():
	if no_clip_active:
		draw_rect(Rect2(-15, -40, 30, 40), Color(0, 1, 1, 0.6))
		var jx = randf_range(-2, 2)
		draw_rect(Rect2(-15 + jx, -40, 30, 40), Color.WHITE, false, 2.0)
	else:
		draw_rect(Rect2(-15, -40, 30, 40), Color("#111111"))
		draw_rect(Rect2(-13, -38, 26, 6), Color("#ff0055"))
		draw_rect(Rect2(3, -25, 4, 4), Color("#00ffff"))
		draw_rect(Rect2(9, -25, 4, 4), Color("#00ffff"))

	#if invulnerable_timer > 0:
	#	visible = sin(Time.get_ticks_msec() * 0.09) > 0
	#else:
	#	visible = true

func jump():
	if grounded:
		velocity.y = JUMP_VELOCITY
		grounded = false
		play_tone($JumpSound, 400.0, 0.08, 0.25)

# Substitui a antiga activate_no_clip()
func try_activate_no_clip() -> bool:
	var main = get_node("/root/Main")
	if not main:
		return false

	var error = main.get_beat_error()
	if error <= main.BEAT_WINDOW:
		# Ativou no ritmo!
		no_clip_active = true
		no_clip_timer = NO_CLIP_DURATION
		# Som de sucesso (glitch ativado)
		play_tone($NoClipSound, 800.0, 0.08, 0.2)
		return true
	else:
		# Fora do ritmo: feedback de erro (som baixo e curto)
		play_tone($NoClipSound, 100.0, 0.06, 0.15)
		return false
