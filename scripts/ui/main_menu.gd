extends Control

@export var game_scene_path: String = "res://scenes/world.tscn"

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	print("Main menu loaded")
	start_button.pressed.connect(_on_start_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _on_start_button_pressed() -> void:
	print("Start pressed")
	get_tree().change_scene_to_file(game_scene_path)

func _on_quit_button_pressed() -> void:
	print("Quit pressed")
	get_tree().quit()
