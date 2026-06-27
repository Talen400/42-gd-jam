extends Area2D

@export var victory_scene_path: String = "res://scenes/ui/victory.tscn"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_file(victory_scene_path)
