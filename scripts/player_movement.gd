extends CharacterBody2D


@export var SPEED = 450.0
@export var JUMP_VELOCITY = -1200.0
@export var GRAVITY_SCALE = 3.5 
@export var JUMP_RELEASE_MULTIPLIER = 0.4

func death() -> void:
	get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * GRAVITY_SCALE * delta

	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= JUMP_RELEASE_MULTIPLIER

	velocity.x = SPEED

	move_and_slide()
