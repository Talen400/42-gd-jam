extends Area2D

var obs_type := "normal"
var obs_width := 25.0
var obs_height := 30.0

func _process(_delta):
	queue_redraw()

func _draw():
	if obs_type == "glitch":
		if randf() > 0.3:
			var flicker_color = Color("#00ffff") if randf() > 0.5 else Color("#ff00ff")
			draw_rect(Rect2(-obs_width/2, -obs_height, obs_width, obs_height), flicker_color)
			var num_lines = randi_range(1, 3)
			for i in num_lines:
				var ly = randf_range(-obs_height, 0)
				draw_rect(Rect2(-obs_width/2, ly, obs_width, 3), Color.WHITE)
	elif obs_type == "projectile":
		# Visual do projétil: um retângulo neon horizontal
		draw_rect(Rect2(-obs_width/2, -obs_height/2, obs_width, obs_height), Color("#ffaa00"))
		# Rastro
		draw_rect(Rect2(-obs_width/2 - 10, -2, 8, 4), Color(1, 1, 1, 0.5))
	else:
		var left_bottom = Vector2(-obs_width/2, 0)
		var top_center = Vector2(0, -obs_height)
		var right_bottom = Vector2(obs_width/2, 0)
		draw_colored_polygon(PackedVector2Array([left_bottom, top_center, right_bottom]), Color("#ff0044"))
