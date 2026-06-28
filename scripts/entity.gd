extends Node2D

const GROUND_Y := 320

var visual_x := -180.0
var target_visual_x := -180.0

func _process(delta):
	visual_x = lerp(visual_x, target_visual_x, 0.05)
	queue_redraw()

func _draw():
	if visual_x + 40 <= 0:
		return

	draw_rect(Rect2(0, 0, visual_x + 40, GROUND_Y), Color(1, 0, 0.33, 0.3))

	draw_rect(Rect2(0, 0, visual_x + 40, GROUND_Y), Color(0.04, 0.04, 0.04, 0.85))

	for y in range(0, GROUND_Y + 1, 15):
		var ext = randf_range(0, 40)
		draw_rect(Rect2(visual_x + 40, y, ext, 8), Color("#ff0055"))
		if randf() > 0.8:
			draw_rect(Rect2(visual_x + 40 + ext, y + 2, 15, 3), Color("#00ffff"))
