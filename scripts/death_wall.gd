extends Area2D

@export var velocity = 15


func _process(delta: float) -> void:
	position.x += velocity * delta


func _on_body_entered(body: Node2D) -> void:
	print("Entrou!")
	if body.is_in_group("players"):
		body.death()
