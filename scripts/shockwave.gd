extends Area2D

var obs_type := "shockwave"
var obs_width := 10.0
var obs_height := 600.0
var speed := 800.0

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	position.x -= speed * delta
	if position.x < -100:
		queue_free()
	queue_redraw()

func _on_body_entered(body):
	if body.name == "Player":
		var main = get_node("/root/Main")
		if main:
			# Se o jogador está com No‑Clip ativo, a onda não causa dano
			if main.player.no_clip_active:
				queue_free()   # some sem dano
				return
			# Caso contrário, aplica dano normal
			if main.player.invulnerable_timer <= 0.0:
				main.player.invulnerable_timer = 0.8
				main.entity.visual_x += 100
				main.play_collision_sound()
				main.get_node("Camera2D").add_shake(12)
		queue_free()

func _draw():
	var center = Vector2.ZERO
	var height = obs_height / 2.0
	for i in range(3):
		var alpha = 0.5 - i * 0.15
		var width = 2.0 + i * 2.0
		draw_line(Vector2(0, -height), Vector2(0, height), Color("#ff00ff", alpha), width)
	var pulse = abs(sin(Time.get_ticks_msec() * 0.015)) * 0.8 + 0.2
	draw_line(Vector2(0, -height), Vector2(0, height), Color.WHITE * pulse, 1.5)
