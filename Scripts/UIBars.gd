extends TextureRect

var score = preload("res://score.tres")
var scoreText

var stats: PlayerStats = preload("res://playerStats.tres")
var Confidence
var HP
var EXP
var Panic

func _ready():
	Confidence = get_child(0)
	HP = get_child(1)
	EXP = get_child(2)
	Panic = get_child(3)
	
	scoreText = get_child(4)

func _process(_delta: float) -> void:
	Confidence.value = stats.confidence
	HP.value = stats.hp
	EXP.value = stats.experience
	Panic.value = stats.panic
	
	scoreText.text = str(score.get_meta("score")) + "m"
