extends Control

@export var main_menu_path: String = "res://scenes/ui/main_menu.tscn"

func _on_back_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_path)
	
