extends Area2D

@export var velocity = 300

func _process(delta: float) -> void:
	position.x += velocity * delta

func _on_body_entered(body: Node2D) -> void:
	print_rich("[color=green] Entrou![/color]")
	if body.is_in_group("players"):
		body.call_deferred("death")
