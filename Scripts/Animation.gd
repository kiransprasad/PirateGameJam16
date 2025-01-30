extends Sprite2D

@onready var currFrame = randi() % hframes

const FPS : float = 8
var tick : float = 0

func _process(delta: float) -> void:
	tick += delta
	if (tick > 1/FPS):
		tick -= 1/FPS
		frame = (frame + 1) % hframes
	
