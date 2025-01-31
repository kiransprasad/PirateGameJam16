extends Node2D

var MIMIC = preload("res://Prefabs/Slime.tscn")
var chestType

func _ready() -> void:
	chestType = randi() % 7
	
	if chestType == 0:
		var mimic = MIMIC.instantiate()
		mimic.global_position = global_position
		get_parent().call_deferred("add_child", mimic)
		queue_free()
	elif chestType == 1:
		$Bronze.set_visible(false)
		$Gold.set_visible(true)
	elif chestType <= 3:
		$Bronze.set_visible(false)
		$Silver.set_visible(true)

func interact():
	
	for c in get_tree().root.get_child(0).get_children():
		if c.is_in_group("ChestOpen"):
			c.play()
	
	if chestType == 1:
		$Gold.set_visible(false)
		$GoldOpen.set_visible(true)
		return 3
	elif chestType <= 3:
		$Silver.set_visible(false)
		$SilverOpen.set_visible(true)
		return 2
	else:
		$Bronze.set_visible(false)
		$BronzeOpen.set_visible(true)
		return 1
