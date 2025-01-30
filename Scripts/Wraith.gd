extends CharacterBody2D

const ATTACK_DAMAGE = 10
const MAX_HP : float = 25
const SPEED = 150

const SIGHT_RANGE = 1000
const CHASE_RANGE = 2000

const SIGHT_SECONDS = 3
const ATTACK_SECONDS = 0.5

enum STATE {WANDER, CHASE, ATTACK, DEAD}
const stateToAnimSpeed = [4, 4, 4, 4]
var currState = STATE.WANDER
var isDead = false

var wanderTimer = 0
var wanderAngle = randf_range(0, 2 * PI)
var targetWanderAngle = randf_range(0, 2 * PI)
var wanderRot = PI/180

@onready var sightIcon = $SightIcon
@onready var attackIcon = $AttackIcon
@onready var hpBar = $HPBar

var target = null

@onready var sprite = $Sprite2D
var spriteTimer = 0

func _ready() -> void:
	var children = get_parent().get_children()
	for child in children:
		if child.is_in_group("Player"):
			target = child

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):

	changeState()
	performState(delta)
	
	animate()
	
	# Move or Attack
	move_and_slide()

func changeState():
	if isDead:
		currState = STATE.DEAD
		$CollisionShape2D.set_deferred("disabled", true)
		sightIcon.set_visible(false)
		attackIcon.set_visible(false)
	elif currState == STATE.WANDER:
		if sightIcon.value >= 100:
			sightIcon.value = 100
			currState = STATE.CHASE
	elif currState == STATE.CHASE:
		if position.distance_to(target.position) > CHASE_RANGE:
			sightIcon.value = 99.9
			wanderTimer = 200
			currState = STATE.WANDER
		elif position.distance_to(target.position) <= 200:
			sightIcon.set_visible(false)
			attackIcon.value = 0
			attackIcon.set_visible(true)
			currState = STATE.ATTACK
	elif currState == STATE.ATTACK:
		if position.distance_to(target.position) > 200:
			sightIcon.set_visible(true)
			attackIcon.value = 0
			attackIcon.set_visible(false)
			currState = STATE.CHASE

func performState(delta):
	if currState == STATE.WANDER:
		if position.distance_to(target.position) < SIGHT_RANGE:
			sightIcon.set_visible(true)
			sightIcon.value += delta * 100/SIGHT_SECONDS
		elif sightIcon.value > 0:
			sightIcon.value -= delta * 50/SIGHT_SECONDS
		else:
			sightIcon.value = 0
			sightIcon.set_visible(false)
			
			# Despawn if too far away
			if global_position.distance_to(target.global_position) > 6000:
				queue_free()
			
		wanderTimer -= 1
		if wanderTimer <= 0:
			wanderTimer = 180 + randi() % 420
			wanderRot = randf_range(0.001, 0.01) * ((randi()%2)*2-1)
			targetWanderAngle = position.angle_to(target.position) + randf_range(0, PI/2) * ((randi() % 2)*2-1)
			if targetWanderAngle < 0:
				targetWanderAngle += 2*PI
			elif targetWanderAngle > 2*PI:
				targetWanderAngle -= 2*PI
		
		if abs(targetWanderAngle - wanderAngle) > PI/180:
			wanderAngle += wanderRot
			if wanderAngle < 0:
				wanderAngle += 2*PI
			elif wanderAngle > 2*PI:
				wanderAngle -= 2*PI
				
		velocity = Vector2(100, 0).rotated(wanderAngle)
	elif currState == STATE.CHASE:
		velocity = (target.position - position).normalized() * SPEED
	elif currState == STATE.ATTACK:
		if(position.distance_to(target.position) > 20):
			velocity = (target.position - position).normalized() * SPEED
		else:
			velocity = Vector2.ZERO
		if attackIcon.value >= 100:
			attackIcon.value = 0
			target.damage(ATTACK_DAMAGE)
		attackIcon.value += delta * 100/ATTACK_SECONDS
	else:
		velocity *= 0.95

func animate():
	
	sprite.flip_h = velocity.x > 0
	
	spriteTimer += 1
	if spriteTimer >= stateToAnimSpeed[currState]:
		spriteTimer = 0
		
		if currState == STATE.DEAD:
			if sprite.frame == 4: # <?>
				die()
			else:
				sprite.frame += 1
		else:
			sprite.frame = (sprite.frame + 1) % 4

func damage(dmgTaken : float) -> void:
	hpBar.set_visible(true)
	hpBar.value -= dmgTaken * 100/MAX_HP 
	if hpBar.value <= 0.02:
		isDead = true

func knockback(_kbVec : Vector2, _fromPlayer : bool = false) -> void:
	pass

func die():
	modulate.a -= 0.1
	if modulate.a <= 0:
		target.gainExp(20)
		queue_free()
	
