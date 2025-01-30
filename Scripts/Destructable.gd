extends StaticBody2D

func damage(dmgNum : int) -> void:
	get_parent().get_parent().bake_navigation_polygon()
	get_parent().queue_free()
