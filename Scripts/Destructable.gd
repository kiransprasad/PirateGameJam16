extends StaticBody2D

func damage(_dmgNum : int) -> void:
	get_parent().queue_free()
	get_parent().get_parent().call_deferred("bake_navigation_polygon")
