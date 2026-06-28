extends Node2D

func _process(_delta):
	queue_redraw()

func _draw():
	draw_rect(Rect2(0, 50, 800, 270), Color("#c8b078"))
	draw_rect(Rect2(0, 320, 800, 80), Color("#5a4a3a"))
