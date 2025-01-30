extends TextureRect

var stats: PlayerStats = preload("res://playerStats.tres")
var Confidence
var Bond
var EXP
var Panic

func _ready():
	Confidence = get_child(0)
	Bond = get_child(1)
	EXP = get_child(2)
	Panic = get_child(3)

func _process(_delta: float) -> void:
	Confidence.value = stats.confidence
	Bond.value = stats.bond
	EXP.value = stats.experience
	Panic.value = stats.panic
