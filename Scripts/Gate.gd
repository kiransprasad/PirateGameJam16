extends Node2D

func openGate():
	$NavigationObstacle2D.queue_free()
	get_parent().get_parent().bake_navigation_polygon()
	queue_free()
