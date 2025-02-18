extends Area2D

@export var leverNum : int

func interact():
	$OFF.set_visible(false)
	$ON.set_visible(true)
	
	var children = get_parent().get_children()
	for child in children:
		if child.is_in_group("Gate" + str(leverNum)):
			var loc = child.global_position
			child.queue_free()
			get_parent().get_parent().call_deferred("bake_navigation_polygon")
			return loc - Vector2(0, 300)
