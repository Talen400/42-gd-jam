extends Area2D

const SPEED := 300.0

signal reached()

func _ready():
	body_entered.connect(_on_body_entered)

func _process(delta):
	if not visible:
		return
	position.x -= SPEED * delta
	queue_redraw()

func _draw():
	draw_rect(Rect2(-20, -60, 40, 60), Color("#2f2"))
	var font = ThemeDB.fallback_font
	if font:
		var text = "SAIDA"
		var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10)
		draw_string(font, Vector2(-text_size.x / 2, -30), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)

func _on_body_entered(body):
	if body.is_in_group("players"):
		reached.emit()
