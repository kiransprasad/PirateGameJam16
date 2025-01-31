extends Panel

@onready var START_MENU = $StartMenu
@onready var SKILL_MENU = $SkillMenu
@onready var DEATH_MENU = $DeathMenu

var score = preload("res://score.tres")
var stats: PlayerStats = preload("res://playerStats.tres")

var SKILL_PREVIEW = preload("res://Prefabs/SkillPreview.tscn")
var randSkills = []
var skillSelected = -1
@onready var skillContainer = SKILL_MENU.get_child(1).get_child(0)

func setMenu(id : int):
	if id == 0:
		START_MENU.set_visible(true)
		SKILL_MENU.set_visible(false)
		DEATH_MENU.set_visible(false)
	elif id == -1:
		START_MENU.set_visible(false)
		SKILL_MENU.set_visible(false)
		DEATH_MENU.set_visible(true)
		
		DEATH_MENU.get_child(0).text = "Distance Travelled . . . " + str(score.get_meta("score")) + "m"
		DEATH_MENU.get_child(1).text = "Previous Best . . . . . . " + str(score.get_meta("highscore")) + "m"
		DEATH_MENU.get_child(2).set_visible(score.get_meta("score") > score.get_meta("highscore"))
		score.set_meta("highscore", max(score.get_meta("score"), score.get_meta("highscore")))
	else:
		START_MENU.set_visible(false)
		SKILL_MENU.set_visible(true)
		DEATH_MENU.set_visible(false)
		
		# Set skills text
		
		randSkills = []
		
		# From main menu
		if id == 10:
			for i in 3:
				var newSkillPreview = SKILL_PREVIEW.instantiate()
				newSkillPreview.skill = load(randomSkill())
				randSkills.append(newSkillPreview)
				skillContainer.add_child(newSkillPreview)
			pass
		
	set_visible(true)

func _on_play_pressed() -> void:
	setMenu(10)

func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()

func randomSkill():
	var pathName = "res://Skills/Templates/"
	var files = DirAccess.get_files_at(pathName)
	return pathName + files[randi() % len(files)]
	
func drawSkills():
	for i in 4:
		if not stats.skills[i]:
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
	replaceSkill(0)


func _on_skill_2_pressed() -> void:
	replaceSkill(1)


func _on_skill_3_pressed() -> void:
	replaceSkill(2)


func _on_skill_4_pressed() -> void:
	replaceSkill(3)

func replaceSkill(id : int):
	if skillSelected != -1:
		stats.skills[id] = randSkills[skillSelected]

func _on_skip_pressed() -> void:
	pass # Replace with function body.
