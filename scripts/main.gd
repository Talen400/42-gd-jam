extends Node2D

enum State { START, PLAYING, GAMEOVER, VICTORY }
# timer bpm
const BPM := 130.0
const BEAT_INTERVAL := 60.0 / BPM
var beat_progress := 0.0          # 0 a 1 dentro de cada batida
var beat_pulse_strength := 0.0    # intensidade do pulso (1 no beat, decai)

# apague @onready var beat_timer: Timer = $BeatTimer

const WORLD_SPEED := 300.0
const LEVEL_LENGTH := 8000.0
const GROUND_Y := 320

var state := State.START
var distance_travelled := 0.0
var death_reason := ""

var projectile_scene = preload("res://scenes/projectile.tscn")
var obstacle_scene = preload("res://scenes/obstacle.tscn")
var tendril_scene = preload("res://scenes/tendril.tscn")
var glitch_rift_scene = preload("res://scenes/glitch_rift.tscn")
var shockwave_scene = preload("res://scenes/shockwave.tscn")

var obstacle_map = [
	# ── FASE 1: Tutorial (0 – 1500) ──
	{ "x": 700,  "type": "normal" },
	{ "x": 1000, "type": "normal" },
	{ "x": 1200, "type": "projectile", "y_offset": -20 },  
	{ "x": 1500, "type": "glitch" },             

	# ── FASE 2: Primeiros desafios (1500 – 3500) ──
	{ "x": 1800, "type": "tendril" },
	{ "x": 2100, "type": "projectile", "y_offset": -40 },
	{ "x": 2400, "type": "double" },            
	{ "x": 2700, "type": "glitch" },
	{ "x": 3000, "type": "normal" },
	{ "x": 3200, "type": "tendril" },
	{ "x": 3400, "type": "projectile", "y_offset": -30 },

	# ── FASE 3: Apresentação do Glitch Rift (3500 – 5000) ──
	{ "x": 3700, "type": "glitch_rift" },             
	{ "x": 4000, "type": "glitch" },
	{ "x": 4200, "type": "projectile", "y_offset": -50 },
	{ "x": 4400, "type": "tendril" },
	{ "x": 4600, "type": "normal" },
	{ "x": 4800, "type": "glitch_rift" },                 
	{ "x": 5000, "type": "double" },

	# ── FASE 4: Sincronia intensa (5000 – 6500) ──
	{ "x": 5200, "type": "glitch" },
	{ "x": 5400, "type": "projectile", "y_offset": -60 },   
	{ "x": 5600, "type": "tendril" },
	{ "x": 5800, "type": "normal" },
	{ "x": 6100, "type": "glitch_rift" },                  
	{ "x": 6200, "type": "glitch" },
	{ "x": 6300, "type": "glitch" },
	{ "x": 6500, "type": "tendril" },

	# ── FASE 5: Corrida final (6500 – 8000) ──
	{ "x": 6700, "type": "projectile", "y_offset": -20 },
	{ "x": 6900, "type": "double" },
	{ "x": 7000, "type": "glitch_rift" },
	{ "x": 7100, "type": "glitch" },
	{ "x": 7200, "type": "normal" },
	{ "x": 7400, "type": "tendril" },
	{ "x": 7500, "type": "projectile", "y_offset": -10 },
	{ "x": 7600, "type": "glitch" },
	{ "x": 7700, "type": "glitch_rift" },
	{ "x": 7800, "type": "double" },
	{ "x": 7900, "type": "normal" },
]

var obstacles := []

@onready var player: CharacterBody2D = $Player
@onready var entity: Node2D = $Entity
@onready var obstacle_container: Node = $ObstacleContainer
@onready var collision_sound: AudioStreamPlayer = $CollisionSound

var beat_timer: Timer

func _ready():
		# Cria e configura o BeatTimer
	beat_timer = Timer.new()
	beat_timer.name = "BeatTimer"
	beat_timer.wait_time = BEAT_INTERVAL
	beat_timer.one_shot = false
	add_child(beat_timer)
	beat_timer.timeout.connect(_on_beat_timeout)
	
	setup_sounds()
	setup_ui()

func setup_sounds():
	var gen = AudioStreamGenerator.new()
	gen.mix_rate = 44100
	gen.buffer_length = 0.2
	collision_sound.stream = gen

const BEAT_WINDOW := 0.12   # tolerância em segundos

func get_beat_error() -> float:
	# Retorna a diferença entre agora e o beat mais próximo (0 = no beat)
	var raw = fmod(beat_progress, 1.0)   # beat_progress já é cíclico entre 0 e 1
	# A distância para 0 ou 1 é o erro
	var error = min(raw, 1.0 - raw)
	return error * BEAT_INTERVAL   # converte para segundos
	
func play_collision_sound():
	var playback = collision_sound.get_stream_playback()
	if playback and playback.get_frames_available() > 400:
		var sample_count = int(44100 * 0.15)
		for i in sample_count:
			var t = float(i) / 44100.0
			var value = sin(150.0 * t * TAU) * 0.3
			value *= max(0, 1.0 - t / 0.15)
			playback. _frame(Vector2(value, value))

func setup_ui():
	var ui = CanvasLayer.new()
	ui.name = "UI"
	add_child(ui)

	var make_screen = func(name: String) -> ColorRect:
		var screen = ColorRect.new()
		screen.name = name
		screen.color = Color(0, 0, 0, 0.85)
		screen.size = Vector2(800, 400)
		screen.position = Vector2(0, 0)
		screen.mouse_filter = Control.MOUSE_FILTER_STOP
		ui.add_child(screen)
		return screen

	var make_label = func(parent: Control, name: String, text: String, color: Color, y: int, size: int = 32):
		var label = Label.new()
		label.name = name
		label.text = text
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.modulate = color
		label.add_theme_font_size_override("font_size", size)
		label.position = Vector2(0, y)
		label.size = Vector2(800, 60)
		parent.add_child(label)
		return label

	var make_button = func(parent: Control, name: String, text: String, y: int):
		var btn = Button.new()
		btn.name = name
		btn.text = text
		btn.position = Vector2(300, y)
		btn.size = Vector2(200, 50)
		btn.add_theme_font_size_override("font_size", 20)
		parent.add_child(btn)
		return btn

	var start_screen = make_screen.call("StartScreen")
	make_label.call(start_screen, "TitleLabel", "THE GLITCHROOMS", Color("#ff0055"), 120, 48)
	var desc = Label.new()
	desc.text = "Voce clipou para fora da realidade. Corra e sobreviva."
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	desc.modulate = Color("#dddddd")
	desc.add_theme_font_size_override("font_size", 16)
	desc.position = Vector2(100, 180)
	desc.size = Vector2(600, 40)
	start_screen.add_child(desc)
	var hint = Label.new()
	hint.text = "[ESPACO] - Pular Obstaculos Normais (Vermelhos)\n[SHIFT] ou [C] - Ativar NO-CLIP para passar por Paredes Glitchadas (Cianas)"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint.modulate = Color("#ffffff")
	hint.add_theme_font_size_override("font_size", 12)
	hint.position = Vector2(200, 220)
	hint.size = Vector2(450, 50)
	start_screen.add_child(hint)
	var start_btn = make_button.call(start_screen, "StartButton", "INICIAR FUGUEM", 290)
	start_btn.pressed.connect(start_game)

	var gameover_screen = make_screen.call("GameOverScreen")
	gameover_screen.visible = false
	make_label.call(gameover_screen, "GameOverTitle", "DELETADO", Color("#ff0000"), 120, 48)
	var death_label = Label.new()
	death_label.name = "DeathReason"
	death_label.text = ""
	death_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	death_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	death_label.modulate = Color("#dddddd")
	death_label.add_theme_font_size_override("font_size", 14)
	death_label.position = Vector2(0, 190)
	death_label.size = Vector2(800, 40)
	gameover_screen.add_child(death_label)
	var retry_btn = make_button.call(gameover_screen, "RetryButton", "TENTAR NOVAMENTE", 250)
	retry_btn.pressed.connect(start_game)

	var victory_screen = make_screen.call("VictoryScreen")
	victory_screen.visible = false
	make_label.call(victory_screen, "VictoryTitle", "ARQUIVO SALVO", Color("#00ffcc"), 120, 48)
	var vic_desc = Label.new()
	vic_desc.text = "Voce encontrou a porta de saida e escapou das Glitchrooms!"
	vic_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vic_desc.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	vic_desc.modulate = Color("#dddddd")
	vic_desc.add_theme_font_size_override("font_size", 14)
	vic_desc.position = Vector2(0, 190)
	vic_desc.size = Vector2(800, 40)
	victory_screen.add_child(vic_desc)
	var win_btn = make_button.call(victory_screen, "WinButton", "JOGAR DE NOVO", 250)
	win_btn.pressed.connect(start_game)

func start_game():
	state = State.PLAYING
	distance_travelled = 0.0
	death_reason = ""

	entity.visual_x = -180
	entity.target_visual_x = -180

	player.position = Vector2(165, 320)
	player.velocity = Vector2.ZERO
	player.grounded = true
	player.no_clip_active = false
	player.no_clip_timer = 0.0
	player.invulnerable_timer = 0.0

	for child in obstacle_container.get_children():
		child.queue_free()
	obstacles.clear()

	for entry in obstacle_map:
		var y_off = entry.get("y_offset", 0.0)
		if entry.type == "double":
			spawn_obstacle(entry.x, "normal")
			spawn_obstacle(entry.x + 35, "normal")
		else:
			spawn_obstacle(entry.x, entry.type, y_off)

	$UI/StartScreen.visible = false
	$UI/GameOverScreen.visible = false
	$UI/VictoryScreen.visible = false
	
	if beat_timer:
		beat_timer.start()

func spawn_obstacle(x: float, type: String, y_offset: float = 0.0):
	var obs: Node2D
	var obs_width = 25.0
	var obs_height = 30.0
	var speed_multi = 1.0

	if type == "tendril":
		obs = tendril_scene.instantiate()
		obs_width = 18.0
		obs_height = obs.base_height  # altura máxima para o array
		speed_multi = 1.0
	elif type == "projectile":
		obs = projectile_scene.instantiate()
		obs_width = 20.0
		obs_height = 10.0
		speed_multi = 1.8
	elif type == "glitch_rift":
		obs = glitch_rift_scene.instantiate()
		obs_width = 60.0
		obs_height = 40.0
		speed_multi = 1.0
	elif type == "glitch":
		obs = obstacle_scene.instantiate()
		obs_width = 30.0
		obs_height = 60.0
	else: # normal
		obs = obstacle_scene.instantiate()
		obs_width = 25.0
		obs_height = 30.0


	# Atribuir as propriedades ao nó (IMPORTANTE!)
	obs.obs_type = type
	obs.obs_width = obs_width
	
	# para tendril, a altura é dinâmica, mas definimos a máxima
	if type != "tendril":   
		obs.obs_height = obs_height
	
	obs.position = Vector2(x, GROUND_Y + y_offset)
	obstacle_container.add_child(obs)

	obstacles.append({
		"x": x,
		"y": GROUND_Y + y_offset,
		"width": obs_width,
		"height": obs_height,
		"type": type,
		"speed": speed_multi,
		"node": obs
	})
	
func _on_beat_timeout():
	beat_pulse_strength = 1.0   # força total do pulso
	
func _process(delta):
	match state:
		State.START:
			if Input.is_action_just_pressed("jump"):
				start_game()
		State.PLAYING:
			update_playing(delta)
		State.GAMEOVER, State.VICTORY:
			if Input.is_action_just_pressed("jump"):
				start_game()

	queue_redraw()
	# Atualizar progresso do beat para o indicador
	beat_progress += delta / BEAT_INTERVAL
	if beat_progress >= 1.0:
		beat_progress -= 1.0
	# Decaimento do pulso
	beat_pulse_strength = max(0.0, beat_pulse_strength - delta * 5.0)

func update_playing(delta):
	distance_travelled += WORLD_SPEED * delta

	if Input.is_action_just_pressed("jump"):
		player.jump()
	if Input.is_action_just_pressed("no_clip"):
		player.try_activate_no_clip()

	for obs_data in obstacles:
		# Move cada objeto baseado em sua velocidade própria
		# Se o objeto não tiver a chave "speed" (obstáculos antigos), usamos 1.0
		var s = obs_data.get("speed", 1.0) 
		obs_data.x -= (WORLD_SPEED * s) * delta
		obs_data.node.position.x = obs_data.x

	var i = 0
	while i < obstacles.size():
		if obstacles[i].x < -100:
			obstacles[i].node.queue_free()
			obstacles.remove_at(i)
		else:
			i += 1

	entity.target_visual_x = -180 + (200 if player.invulnerable_timer > 0.0 else 0)
	
	var p_left = player.position.x - 15
	var p_top = player.position.y - 40
	var player_rect = Rect2(p_left, p_top, 30, 40)

	for obs_data in obstacles:
		var obs_rect = Rect2(obs_data.x - obs_data.width / 2, obs_data.y - obs_data.height, obs_data.width, obs_data.height)

		if player_rect.intersects(obs_rect):
			if obs_data.type == "glitch_rift":
				continue
			# Passa por glitch se No‑Clip estiver ativo
			if obs_data.type == "glitch" and player.no_clip_active:
				continue
			if obs_data.type == "projectile" and player.no_clip_active:
				continue

			# Colisão normal (normal, double, projectile, tendril, etc.)
			if player.invulnerable_timer <= 0.0:
				$Camera2D.add_shake(15)
				player.invulnerable_timer = 1.0
				entity.visual_x += 150
				play_collision_sound()

				if entity.visual_x >= p_left - 20:
					end_game(State.GAMEOVER, "A entidade-glitch interceptou seus dados e deletou voce.")
					return

	if entity.visual_x >= p_left - 10:
		end_game(State.GAMEOVER, "Voce foi consumido pelo Glitch.")
		return

	if distance_travelled >= LEVEL_LENGTH:
		end_game(State.VICTORY)
		return

func end_game(end_state: State, reason: String = ""):
	state = end_state
	death_reason = reason
	if end_state == State.GAMEOVER:
		$UI/GameOverScreen/DeathReason.text = reason
		$UI/GameOverScreen.visible = true
	elif end_state == State.VICTORY:
		$UI/VictoryScreen.visible = true

func _draw():
	if state == State.START:
		return

	draw_rect(Rect2(0, 0, 800, 400), Color("#edd391"))

	var offset_x = fmod(distance_travelled, 80.0)
	var x = 800.0 - offset_x
	while x > -80:
		draw_line(Vector2(x, 0), Vector2(x, GROUND_Y), Color("#dbbf74"), 2.0)
		x -= 80

	var light_offset = fmod(distance_travelled, 200.0)
	var lx = 800.0 - light_offset
	while lx > -200:
		draw_rect(Rect2(lx, 10, 60, 10), Color("#fffdf0"))
		lx -= 200

	draw_rect(Rect2(0, GROUND_Y, 800, 80), Color("#2b2516"))
	draw_rect(Rect2(0, GROUND_Y, 800, 4), Color("#00ffff"))

	draw_hud()

func draw_hud():
	var font = ThemeDB.fallback_font
	if not font:
		return

	var progress = min(distance_travelled / LEVEL_LENGTH, 1.0)
	draw_rect(Rect2(200, 20, 400, 12), Color(0, 0, 0, 0.5))
	draw_rect(Rect2(200, 20, 400 * progress, 12), Color("#ff0055"))
	draw_rect(Rect2(200, 20, 400, 12), Color.WHITE, false, 1.0)

	draw_rect(Rect2(595, 16, 8, 20), Color("#00ffff"))

	draw_string(font, Vector2(30, 28), "NO-CLIP (SHIFT):", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	draw_rect(Rect2(150, 18, 40, 12), Color(0, 0, 0, 0.5))

	# Indicador de No‑Clip rítmico
	var beat_error = get_beat_error()
	var can_noclip = beat_error <= BEAT_WINDOW
	var noclip_color = Color.GREEN if can_noclip else Color.DARK_GRAY
	draw_string(font, Vector2(30, 28), "NO-CLIP (SHIFT):", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	draw_circle(Vector2(165, 24), 6, noclip_color)
	if can_noclip:
		# Brilha quando está no ritmo
		draw_circle(Vector2(165, 24), 9, Color.GREEN * 0.3)
	
	# Indicador de ritmo (canto inferior direito)
	var indicator_center = Vector2(750, 370)
	var base_radius = 12.0
	var pulse_radius = base_radius + beat_pulse_strength * 8.0

	# Círculo base
	draw_circle(indicator_center, base_radius, Color(0.2, 0.2, 0.2, 0.6))
	# Círculo pulsante (quanto mais próximo do beat, maior/mais brilhante)
	var glow = Color("#00ffff") * (0.4 + beat_pulse_strength * 0.6)
	draw_circle(indicator_center, pulse_radius, glow, false, 2.0)
	# Preenchimento central que pisca no beat exato
	if beat_pulse_strength > 0.7:
		draw_circle(indicator_center, base_radius * 0.7, Color.WHITE * beat_pulse_strength)
	
