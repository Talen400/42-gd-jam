extends Camera2D

var shake_intensity := 0.0
var decay := 0.9

func _process(_delta):
	if shake_intensity > 0.5:
		offset = Vector2(
			randf_range(-1, 1) * shake_intensity,
			randf_range(-1, 1) * shake_intensity
		)
		shake_intensity *= decay
	else:
		offset = Vector2.ZERO
		shake_intensity = 0.0

func add_shake(intensity: float):
	shake_intensity = max(shake_intensity, intensity)
