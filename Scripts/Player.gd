extends CharacterBody2D

# State Variables
enum STATE {ADVANCE, INTERACT, FIGHT, PANIC}
var currState = STATE.PANIC

# Movement Variables
var targetStack = [Vector2(0, 0)]
const SPEED = 750
@onready var navigationAgent = $NavigationAgent2D
var navLine = null
var knockbackVector = Vector2.ZERO

var enemiesNear = []
const ENEMY_NEAR_THRESHOLD = 750
var itemsNear = []
const ITEM_NEAR_THRESHOLD = 3000

# Stats
var stats: PlayerStats = preload("res://playerStats.tres")

# Skill Variables
var facingDir = 0

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

func _ready() -> void:
	var children = get_parent().get_children()
	for child in children:
		if child.is_in_group("NavLine"):
			navLine = child
			

func _physics_process(delta):
	
	# Update necessary stats
	if not stats.panic:
		stats.confidence += delta/5
	if stats.confidence > 100:
		stats.confidence = 100
	
	if(Input.is_action_just_pressed("Click") and loadedNum == -1):
		targetStack.push_back(get_global_mouse_position())
	
	debugInit()
	debug(STATETEXT[currState])
	debug(enemiesNear)
	
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
		if isEnemyNear():
			currState = STATE.FIGHT
		elif navigationAgent.is_navigation_finished():
			targetStack.pop_back()
			currState = STATE.INTERACT
	elif currState == STATE.INTERACT:
		if not Input.is_key_pressed(KEY_I): # Interaction Completed!
			if len(targetStack) > 0:
				currState = STATE.ADVANCE
	elif currState == STATE.FIGHT:
		if not isEnemyNear():
			currState = STATE.ADVANCE
	elif currState == STATE.PANIC:
		if stats.panic == 0:
			stats.confidence = 25
			currState = STATE.ADVANCE
		elif isEnemyNear():
			stats.panic = 100
			currState = STATE.FIGHT

func performState(delta):
	if currState == STATE.ADVANCE:
		navigationAgent.target_position = targetStack.back()
		velocity = global_position.direction_to(navigationAgent.get_next_path_position()) * SPEED
	elif currState == STATE.INTERACT:
		velocity = Vector2.ZERO
	elif currState == STATE.FIGHT:
		navigationAgent.target_position = targetStack.back()
		velocity = global_position.direction_to(navigationAgent.get_next_path_position()) * SPEED
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

func isEnemyNear() -> bool:
	for enemy in enemiesNear:
		if position.distance_to(enemy.position) <= ENEMY_NEAR_THRESHOLD:
			return true
	return false

func _on_sight_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Enemy")):
		enemiesNear.append(body)

func _on_sight_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Enemy")):
		enemiesNear.erase(body)
		
func damage(dmgTaken : float) -> void:
	stats.confidence -= dmgTaken / 5
	stats.bond -= dmgTaken / 2.5
		
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
