extends Area2D

@export var leverNum : int

func interact():
	$OFF.set_visible(false)
	$ON.set_visible(true)
	
	for c in get_tree().root.get_child(0).get_children():
		if c.is_in_group("LeverAudio"):
			c.play()
	
	var children = get_parent().get_children()
	for child in children:
		if child.is_in_group("Gate" + str(leverNum)):
			var loc = child.global_position
			child.openGate()
			return loc - Vector2(0, 300)
