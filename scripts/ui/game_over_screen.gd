extends Control

@export var game_scene_path: String = "res://scenes/world.tscn"
@export var main_menu_path: String = "res://scenes/ui/main_menu.tscn"

@onready var retry_button: Button = $VBoxContainer/RetryButton
@onready var menu_button: Button = $VBoxContainer/MenuButton

func _ready() -> void:
	print("Game over screen loaded")
	retry_button.pressed.connect(_on_retry_button_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)

func _on_retry_button_pressed() -> void:
	print("Retry pressed")
	get_tree().change_scene_to_file(game_scene_path)

func _on_menu_button_pressed() -> void:
	print("Menu pressed")
	get_tree().change_scene_to_file(main_menu_path)
