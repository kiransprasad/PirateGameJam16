extends Panel

@onready var START_MENU = $StartMenu
@onready var SKILL_MENU = $SkillMenu
@onready var DEATH_MENU = $DeathMenu
@onready var PAUSE_MENU = $PauseMenu

var fromTitle = true

var score = preload("res://score.tres")
var stats: PlayerStats = preload("res://playerStats.tres")

var SKILL_PREVIEW = preload("res://Prefabs/SkillPreview.tscn")
var randSkills = []
var skillSelected = -1
@onready var skillContainer = SKILL_MENU.get_child(1).get_child(0)
@onready var overwriteText = SKILL_MENU.get_child(1).get_child(3)

@onready var skillButton = [
	$SkillMenu/Left/Skill1,
	$SkillMenu/Left/Skill2,
	$SkillMenu/Right/Skill3,
	$SkillMenu/Right/Skill4,
]

@onready var nameText = [
	$SkillMenu/Left/Skill1/Name,
	$SkillMenu/Left/Skill2/Name,
	$SkillMenu/Right/Skill3/Name,
	$SkillMenu/Right/Skill4/Name,
]

@onready var cooldownText = [
	$SkillMenu/Left/Skill1/CD,
	$SkillMenu/Left/Skill2/CD,
	$SkillMenu/Right/Skill3/CD,
	$SkillMenu/Right/Skill4/CD,
]

var CALLABLE_SKILL_PRESS = [_on_new_skill_0_pressed, _on_new_skill_1_pressed, _on_new_skill_2_pressed]

@onready var menuSound = $Menu

func setMenu(id : int):
	if id == -2:
		START_MENU.set_visible(true)
		SKILL_MENU.set_visible(false)
		DEATH_MENU.set_visible(false)
		PAUSE_MENU.set_visible(false)
		
	elif id == -1:
		START_MENU.set_visible(false)
		SKILL_MENU.set_visible(false)
		DEATH_MENU.set_visible(true)
		PAUSE_MENU.set_visible(false)
		
		DEATH_MENU.get_child(0).text = "Distance Travelled . . . " + str(score.get_meta("score")) + "m"
		DEATH_MENU.get_child(1).text = "Previous Best . . . . . . " + str(score.get_meta("highscore")) + "m"
		DEATH_MENU.get_child(2).set_visible(score.get_meta("score") > score.get_meta("highscore"))
		score.set_meta("highscore", max(score.get_meta("score"), score.get_meta("highscore")))
	
	elif id == 0:
		START_MENU.set_visible(false)
		SKILL_MENU.set_visible(false)
		DEATH_MENU.set_visible(false)
		PAUSE_MENU.set_visible(true)
		
	else:
		START_MENU.set_visible(false)
		SKILL_MENU.set_visible(true)
		DEATH_MENU.set_visible(false)
		
		# Set skills text
		drawSkills()
		skillSelected = -1
		randSkills = []
		
		# From main menu
		for i in id:
			genRandomSkill(i)
		
	set_visible(true)
	get_tree().paused = true

func _on_play_pressed() -> void:
	menuSound.play()
	setMenu(3)

func _on_retry_pressed() -> void:
	menuSound.play()
	get_tree().reload_current_scene()

func genRandomSkill(i : int):
	var pathName = "res://Skills/Templates/"
	var files = DirAccess.get_files_at(pathName)

	var newSkillPreview = SKILL_PREVIEW.instantiate()
	newSkillPreview.skill = load(pathName + files[randi() % len(files)])
	newSkillPreview.connect("pressed", CALLABLE_SKILL_PRESS[i])
	randSkills.append(newSkillPreview.skill)
	skillContainer.add_child(newSkillPreview)
	
func drawSkills():
	for i in 4:
		if not stats.skills[i]:
			nameText[i].text = "None"
			cooldownText[i].text = ""
			skillButton[i].modulate = Color(0.25, 0.25, 0.25)
		elif stats.skills[i].cooldown > 0:
			nameText[i].text = stats.skills[i].name
			cooldownText[i].text = str(snapped(stats.skills[i].cooldown, 0.1)) + "s"
			skillButton[i].modulate = Color(0.25, 0.25, 0.25)
		else:
			nameText[i].text = stats.skills[i].name
			cooldownText[i].text = "Ready"
			skillButton[i].modulate = stats.skills[i].colour

func _on_skill_1_pressed() -> void:
	menuSound.play()
	replaceSkill(0)


func _on_skill_2_pressed() -> void:
	menuSound.play()
	replaceSkill(1)


func _on_skill_3_pressed() -> void:
	menuSound.play()
	replaceSkill(2)


func _on_skill_4_pressed() -> void:
	menuSound.play()
	replaceSkill(3)

func replaceSkill(id : int):
	if skillSelected != -1:
		stats.skills[id] = randSkills[skillSelected]
		overwriteText.set_visible(false)
		set_visible(false)
		get_tree().paused = false

func _on_skip_pressed() -> void:
	menuSound.play()
	set_visible(false)
	get_tree().paused = false

func _on_new_skill_0_pressed() -> void:
	menuSound.play()
	selectSkill(0)

func _on_new_skill_1_pressed() -> void:
	menuSound.play()
	selectSkill(1)

func _on_new_skill_2_pressed() -> void:
	menuSound.play()
	selectSkill(2)

func selectSkill(id : int):
	skillSelected = id
	overwriteText.set_visible(true)

func _on_back_pressed() -> void:
	menuSound.play()
	z_index = 0
	if fromTitle:
		get_tree().reload_current_scene()
	else:
		set_visible(false)
		get_tree().paused = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Skill 1"):
		menuSound.play()
		replaceSkill(0)
	elif event.is_action_pressed("Skill 2"):
		menuSound.play()
		replaceSkill(1)
	elif event.is_action_pressed("Skill 3"):
		menuSound.play()
		replaceSkill(2)
	elif event.is_action_pressed("Skill 4"):
		menuSound.play()
		replaceSkill(3)

func _on_how_to_pressed() -> void:
	menuSound.play()
	z_index = -1
	setMenu(0)
