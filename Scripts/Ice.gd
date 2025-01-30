extends Node2D

var tick = 0
var lifetime = 5

func _process(delta: float) -> void:
	
	tick += delta
	if tick > 1:
		tick -= 1
		
		lifetime -= 1
		if lifetime <= 0:
			queue_free()
