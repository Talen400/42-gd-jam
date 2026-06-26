extends Area2D

const velocity = 5
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += velocity * delta
	pass

func _on_body_entered(body: Node2D) -> void:
	print("Entrou!")
	if body.is_in_group("players"):
		body.death()
	pass # Replace with function body.
