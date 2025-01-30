extends HBoxContainer

var stats: PlayerStats = preload("res://playerStats.tres")

@onready var skillButton = [
	$Left/Skill1,
	$Left/Skill2,
	$Right/Skill3,
	$Right/Skill4,
]

@onready var nameText = [
	$Left/Skill1/Name,
	$Left/Skill2/Name,
	$Right/Skill3/Name,
	$Right/Skill4/Name,
]

@onready var cooldownText = [
	$Left/Skill1/CD,
	$Left/Skill2/CD,
	$Right/Skill3/CD,
	$Right/Skill4/CD,
]

func _ready() -> void:
	for i in 4:
		nameText[i].text = stats.skills[i].name

func _process(delta: float) -> void:
	for i in 4:
		if Input.is_action_just_pressed("Skill " + str(i+1)):
			stats.selectedSkill = i if stats.skills[i].cooldown <= 0 and stats.selectedSkill != i else -1
		
		if i == stats.selectedSkill:
			cooldownText[i].text = "Selected"
			skillButton[i].modulate = stats.skills[i].colour
		elif stats.skills[i].cooldown - delta > 0:
			stats.skills[i].cooldown -= delta
			cooldownText[i].text = str(snapped(stats.skills[i].cooldown, 0.1))
			skillButton[i].modulate = Color(0.25, 0.25, 0.25)
		else:
			stats.skills[i].cooldown = 0
			cooldownText[i].text = "Ready"
			skillButton[i].modulate = stats.skills[i].colour

func _on_skill_1_pressed() -> void:
	stats.selectedSkill = 0 if stats.skills[0].cooldown <= 0 and stats.selectedSkill != 0 else -1

func _on_skill_2_pressed() -> void:
	stats.selectedSkill = 1 if stats.skills[1].cooldown <= 0 and stats.selectedSkill != 1 else -1

func _on_skill_3_pressed() -> void:
	stats.selectedSkill = 2 if stats.skills[2].cooldown <= 0 and stats.selectedSkill != 2 else -1

func _on_skill_4_pressed() -> void:
	stats.selectedSkill = 3 if stats.skills[3].cooldown <= 0 and stats.selectedSkill != 3 else -1
