extends Node2D

var score = preload("res://score.tres")

var SLIME = preload("res://Prefabs/Slime.tscn")
var WRAITH = preload("res://Prefabs/Wraith.tscn")

func _ready() -> void:
	
	var currScore = score.get_meta("score")
	
	var isSpawning = randi() % 100
	
	if isSpawning < clamp(currScore/50 + 5, 5, 90) or isSpawning < currScore/85:
		var enemyType = randi() % 100
		
		var enemyInstance = (SLIME if enemyType < clamp(100 - currScore/100, 30, 100) else WRAITH).instantiate()
		enemyInstance.global_position = global_position
		get_tree().get_root().get_child(0).call_deferred("add_child", enemyInstance)
		
