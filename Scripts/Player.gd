extends CharacterBody2D

# State Variables
enum STATE {ADVANCE, INTERACT, FIGHT, PANIC}
var currState = STATE.PANIC

# Movement Variables
var targetQueue = []
const SPEED = 750
@onready var navigationAgent = $NavigationAgent2D
var navLine = null
var knockbackVector = Vector2.ZERO

const INTERACT_SECS = 3
@onready var interactIcon = $TextureProgressBar

# Stats
var stats: PlayerStats = preload("res://playerStats.tres")

@onready var DEBUGTEXT = $Sprite2D.get_child(0)
var STATETEXT = ["ADVANCE", "INTERACT", "FIGHT", "PANIC"]

@onready var sprite = $Sprite2D
@onready var swordSprite = $Sprite2D/Sword
var spriteTimer = 0
var swordPosWalk = [Vector2(222, -80), Vector2(264, -84), Vector2(254, -70), Vector2(248, -76), Vector2(256, -80), Vector2(206, 34), Vector2(52, -12), Vector2(104, 68), Vector2(294, 0), Vector2(342, -78), Vector2(206, 34)]
var swordRotWalk = [15, 12, 19, 14, 19, 32, -28, -15, 70, 46, 32]

var loadedSkill = null
var loadedNum = -1
var attackTimer = 0

@onready var pauseMenu = $Camera2D/UI/CanvasLayer/Pause

func _ready() -> void:
	var children = get_parent().get_children()
	for child in children:
		if child.is_in_group("NavLine"):
			navLine = child
			
	
	# Reset stats
	stats.confidence = 50
	stats.experience = 0
	stats.hp = 100
	stats.panic = 0
	stats.skills = [null, null, null, null]
	stats.selectedSkill = -1
	
	# Start Menu
	pauseMenu.setMenu(-2)

func _physics_process(delta):
	
	# Update necessary stats
	if not stats.panic:
		stats.confidence += delta/5
	if stats.confidence > 100:
		stats.confidence = 100
	
	debugInit()
	debug(targetQueue)
	
	changeState()
	performState(delta)
	
	useSkills()
	
	animate()
	drawPath()
	
	if knockbackVector.length() > 0.01:
		velocity = knockbackVector
		knockbackVector *= 0.75
	
	move_and_slide()
	

func changeState():
	if stats.confidence <= 0:
		currState = STATE.PANIC
	if currState == STATE.ADVANCE:
		if navigationAgent.is_navigation_finished():
			if targetQueue.back() is Vector2:
				targetQueue.pop_back()
			else:
				interactIcon.set_visible(true)
				interactIcon.value = 0
				currState = STATE.INTERACT
			
	elif currState == STATE.INTERACT:
		if interactIcon.value >= 100:
			interactIcon.set_visible(false)
			
			var returnVal = targetQueue.pop_back().interact()
			if returnVal is Vector2:
				targetQueue.push_front(returnVal)
			
			currState = STATE.ADVANCE
	elif currState == STATE.PANIC:
		if stats.panic == 0:
			stats.confidence = 25
			currState = STATE.ADVANCE

func performState(delta):
	if currState == STATE.ADVANCE:
		if targetQueue:
			if targetQueue.back() is Vector2:
				navigationAgent.target_position = targetQueue.back()
			else:
				navigationAgent.target_position = targetQueue.back().global_position
		else:
			navigationAgent.target_position = Vector2(global_position.x + 1, -9000)
		velocity = global_position.direction_to(navigationAgent.get_next_path_position()) * SPEED
	elif currState == STATE.INTERACT:
		interactIcon.value += delta * 100/INTERACT_SECS
		velocity = Vector2.ZERO
	elif currState == STATE.PANIC:
		velocity = Vector2.ZERO

func useSkills():
	# Override state-based logic if attacking
	if attackTimer:
		velocity = Vector2.ZERO
		
	if stats.selectedSkill >= 0:
		if loadedNum != stats.selectedSkill:
			if loadedSkill:
				loadedSkill.queue_free()
			loadedNum = stats.selectedSkill
			loadedSkill = stats.skills[stats.selectedSkill].template.instantiate()
			add_child(loadedSkill)
		var mouseVector = get_global_mouse_position() - global_position
		loadedSkill.rotation = mouseVector.angle()
		
		if Input.is_action_just_pressed("Click") and mouseVector.length() < 2000:
			loadedSkill.use()
			loadedSkill = null
			loadedNum = -1
			stats.skills[stats.selectedSkill].cooldown = stats.skills[stats.selectedSkill].max_cooldown
			
			sprite.scale = Vector2(0.5 if velocity.x > 0.5 else -0.5, 0.5)
			stats.selectedSkill = -1
			attackTimer = 6
			spriteTimer = 0
			
			interactIcon.value = max(0, interactIcon.value - 25)
			
	elif loadedSkill:
		loadedSkill.queue_free()
		loadedNum = -1

func animate():
	if attackTimer > 0:
		spriteTimer += 1
		if spriteTimer >= 5:
			spriteTimer = 0
			sprite.frame = (11 - attackTimer)
			attackTimer -= 1
		
	elif not velocity == Vector2.ZERO:
		sprite.hframes = 5
		sprite.scale = Vector2(0.5 if velocity.x > 0.5 else -0.5, 0.5)
		
		spriteTimer += 1
		if spriteTimer >= 6:
			sprite.frame = (sprite.frame + 1) % 5
			spriteTimer = 0
	else:
		sprite.frame = 5
		
	swordSprite.position = swordPosWalk[sprite.frame]
	swordSprite.rotation_degrees = swordRotWalk[sprite.frame]

func drawPath():
	var points = navigationAgent.get_current_navigation_path()
	points.reverse()
	navLine.points = points

func debugInit():
	DEBUGTEXT.text = ""

func debug(string):
	DEBUGTEXT.text += str(string) + "\n"

#func isEnemyNear() -> bool:
	#for enemy in enemiesNear:
		#if position.distance_to(enemy.position) <= ENEMY_NEAR_THRESHOLD:
			#return true
	#return false

func _on_sight_body_entered(body: Node2D) -> void:
	pass
	#if(body.is_in_group("Enemy")):
		#enemiesNear.append(body)

func _on_sight_body_exited(body: Node2D) -> void:
	pass
	#if(body.is_in_group("Enemy")):
		#enemiesNear.erase(body)

func _on_sight_area_entered(area: Area2D) -> void:
	if(area.is_in_group("Interactable")):
		area.get_child(0).queue_free()
		navigationAgent.target_position = area.global_position
		if navigationAgent.is_target_reachable():
			targetQueue.push_front(area)

func damage(dmgTaken : float) -> void:
	stats.confidence -= dmgTaken / 5
	stats.hp -= dmgTaken / 2.5
	if stats.hp <= 0:
		die()
		
func knockback(kbVec):
	knockbackVector += kbVec * 1000
	
func gainExp(expAmt : float) -> void:
	var deltaExp = stats.experience + expAmt
	if deltaExp > 100:
		stats.experience = 100
		print("Level Up") # <?>
		stats.experience = deltaExp - 100
	else:
		stats.experience = deltaExp

func die():
	pauseMenu.setMenu(-1)
