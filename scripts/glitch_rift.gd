extends Area2D

var obs_type := "glitch_rift"
var obs_width := 60.0
var obs_height := 40.0
const PULSE_INTERVAL := 60.0 / 130.0 * 4   # 2 batidas
var time_since_last_shot := 0.0
var shockwave_scene = preload("res://scenes/shockwave.tscn")
var active := false   # controle de ativação

func _ready():
	time_since_last_shot = randf() * PULSE_INTERVAL
	# Procura o jogador para medir distância
	var player = get_node_or_null("/root/Main/Player")
	if player:
		# Ativa se já estiver perto o suficiente
		active = abs(global_position.x - player.global_position.x) < 700

func _process(delta):
	# Atualiza a verificação de distância periodicamente
	if not active:
		var player = get_node_or_null("/root/Main/Player")
		if player and abs(global_position.x - player.global_position.x) < 700:
			active = true

	if not active:
		return   # não faz nada enquanto estiver longe

	time_since_last_shot += delta
	if time_since_last_shot >= PULSE_INTERVAL:
		time_since_last_shot -= PULSE_INTERVAL
		shoot_shockwave()
	queue_redraw()

func shoot_shockwave():
	var wave = shockwave_scene.instantiate()
	wave.global_position = Vector2(global_position.x, 320)   # GROUND_Y = 320
	get_parent().add_child(wave)

func _draw():
	var center = Vector2.ZERO
	# Visual mínimo quando inativo (desbotado)
	if not active:
		draw_circle(center, 10.0, Color("#660066", 0.3))
		return
	# Ativo: brilho pulsante
	draw_circle(center, 10.0, Color("#660066", 0.6))
	draw_circle(center, 5.0, Color("#ff00ff", 0.8))
