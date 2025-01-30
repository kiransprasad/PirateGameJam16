extends Node2D

@export var DAMAGE = 10
# Vector2.RIGHT = forward
@export var KNOCKBACK : Vector2
@export var RECOIL : Vector2

#const FLIP = false
@export var FIRE : Array[Vector3] = []
@export var ICE : Array[Vector2] = []

func use():
	
	var MAP = get_parent().get_parent()
	
	var NAVMESH = null
	for child in MAP.get_children():
		if child is NavigationRegion2D:
			NAVMESH = child
	
	
	# Recoil Player
	get_parent().knockback(RECOIL.rotated(rotation))
	
	var bodies = $Hitbox.get_overlapping_bodies()
	for body in bodies:
		if(body.is_in_group("Enemy")):
			# Hit Enemies
			body.damage(DAMAGE)
			body.knockback(KNOCKBACK.rotated(rotation), true)
	
	# Place fire
	for fireData in FIRE:
		var fire = load("res://Prefabs/Fire.tscn").instantiate()
		fire.global_position = global_position + Vector2(fireData.x, fireData.y).rotated(rotation)
		fire.radius = fireData.z
		MAP.add_child(fire)
	
	for iceData in ICE:
		var ice = load("res://Prefabs/Ice.tscn").instantiate()
		ice.global_position = global_position + Vector2(iceData.x, iceData.y).rotated(rotation)
		NAVMESH.add_child(ice)

	if FIRE or ICE:
		set_visible(false)
		NAVMESH.bake_navigation_polygon()
		await get_tree().create_timer(5.1).timeout
		NAVMESH.bake_navigation_polygon()
	
	queue_free()
