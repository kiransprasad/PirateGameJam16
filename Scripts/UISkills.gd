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

func _ready():
	for i in 4:
		nameText[i].text = "None"
		cooldownText[i].text = ""

func _process(delta: float) -> void:
	for i in 4:
		if Input.is_action_just_pressed("Skill " + str(i+1)):
			pressSkill(i)
		
		if not stats.skills[i]:
			nameText[i].text = "None"
			cooldownText[i].text = ""
			skillButton[i].modulate = Color(0.25, 0.25, 0.25)
		elif i == stats.selectedSkill:
			nameText[i].text = stats.skills[i].name
			cooldownText[i].text = "Selected"
			skillButton[i].modulate = stats.skills[i].colour
		elif stats.skills[i].cooldown - delta > 0:
			nameText[i].text = stats.skills[i].name
			stats.skills[i].cooldown -= delta
			cooldownText[i].text = str(snapped(stats.skills[i].cooldown, 0.1)) + "s"
			skillButton[i].modulate = Color(0.25, 0.25, 0.25)
		else:
			nameText[i].text = stats.skills[i].name
			stats.skills[i].cooldown = 0
			cooldownText[i].text = "Ready"
			skillButton[i].modulate = stats.skills[i].colour

func _on_skill_1_pressed() -> void:
	pressSkill(0)

func _on_skill_2_pressed() -> void:
	pressSkill(1)

func _on_skill_3_pressed() -> void:
	pressSkill(2)

func _on_skill_4_pressed() -> void:
	pressSkill(4)

func pressSkill(id : int):
	if stats.skills[id]:
		stats.selectedSkill = id if stats.skills[id].cooldown <= 0 and stats.selectedSkill != id else -1
