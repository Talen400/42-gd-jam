extends Area2D

var obs_type := "tendril"
var obs_width := 18.0
var base_height := 70.0       # altura máxima
var current_height := 0.0     # varia a cada frame
var frequency := 2.5
var time_offset := 0.0

func _ready():
	time_offset = randf() * TAU

func _process(_delta):
	# Altura oscila entre 20 e base_height
	var t = Time.get_ticks_msec() * 0.001 * frequency + time_offset
	current_height = 20.0 + (base_height - 20.0) * (abs(sin(t)))
	queue_redraw()

func _draw():
	var segments = 10
	var step = current_height / segments
	var color1 = Color("#ff00ff")  # magenta
	var color2 = Color("#00ffff")  # ciano

	# Desenha segmentos ondulados
	for i in range(segments):
		var y = -i * step
		var offset_x = sin(i * 1.8 + Time.get_ticks_msec() * 0.008) * 7.0
		var alpha = 1.0 - i * 0.08
		draw_circle(Vector2(offset_x, y), 5.0, Color(color1.r, color1.g, color1.b, alpha))
		if i % 2 == 0:
			draw_circle(Vector2(offset_x, y), 2.5, color2 * alpha)

	# Ponta brilhante
	draw_circle(Vector2(0, -current_height), 6.0, Color.WHITE * 0.8)
	draw_circle(Vector2(0, -current_height), 3.0, Color("#ff44ff"))
