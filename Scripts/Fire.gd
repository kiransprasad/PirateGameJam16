extends Area2D

const FIRE_SCALE = 0.25

var hitList = []
var radius : float = 0

var tick = 0
var lifetime = 5

func _ready() -> void:
	$CollisionShape2D.scale = Vector2(radius, radius)
	$Sprite2D.scale = Vector2(radius/2500, radius/2500)
	$Sprite2D/Sprite2D.scale = Vector2(2500/radius * FIRE_SCALE, 2500/radius * FIRE_SCALE)
	$Sprite2D/Sprite2D.region_rect = Rect2(0, 0, radius*2/FIRE_SCALE, radius*2/FIRE_SCALE)
	
	var flameSprite = $FlameSprite
	for i in floor(radius / 20):
		print(i)
		var newFlame = flameSprite.duplicate()
		newFlame.position += Vector2(randf_range(10, radius), 0).rotated(randf_range(0, 2*PI))
		newFlame.frame = randi_range(0, 7)
		add_child(newFlame)

func _process(delta: float) -> void:
	
	tick += delta
	if tick > 0.1:
		tick -= 0.1
		
		for body in hitList:
			if is_instance_valid(body):
				body.damage(1)
		
		lifetime -= 0.1
		if lifetime <= 0:
			queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.is_in_group("Enemy") or body.is_in_group("Ice"):
		hitList.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") or body.is_in_group("Enemy") or body.is_in_group("Ice"):
		hitList.erase(body)
