extends CharacterBody2D

const ATTACK_DAMAGE = 75
const MAX_HP : float = 100
const SPEED = 350

const SIGHT_RANGE = 1000
const CHASE_RANGE = 1500

const SIGHT_SECONDS = 3
const CHARGE_SECONDS = 1
const ATTACK_SECONDS = 1
const RECHARGE_SECONDS = 3

const KNOCKBACK_MOD = 1000

@onready var navigationAgent = $NavigationAgent2D
var direction = Vector2(0, 0)
var knockbackVector = Vector2.ZERO

enum STATE {WANDER, CHASE, CHARGE, ATTACK, RECHARGE, DEAD}
const stateToAnimSpeed = [6, 6, 6, 6, 6, 6]
var currState = STATE.WANDER
var isDead = false

var wanderTimer = 0

@onready var sightIcon = $SightIcon

@onready var attackIcon = $AttackIcon
var attackDirection

@onready var hpBar = $HPBar

var target = null

@onready var sprite = $Sprite2D
var spriteTimer = 0

var hurtSound
var seeSound
var attackSound
var deathSound

func _ready() -> void:
	var children = get_parent().get_children()
	for child in children:
		if child.is_in_group("Player"):
			target = child
		elif child.is_in_group("MimicSee"):
			seeSound = child
		elif child.is_in_group("MimicHurt"):
			hurtSound = child
		elif child.is_in_group("MimicDie"):
			deathSound = child
		elif child.is_in_group("MimicAttack"):
			attackSound = child
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	print("SA")
	
	if position.distance_to(target.position) > 6000:
		# Despawn if too far down
		if global_position.y - target.global_position.y > 6000:
			print("SFREE")
			queue_free()

		# Otherwise we will just not do anything until we are close enough to matter
		return

	print("SB")

	changeState()
	performState(delta)
	
	print("SC")
	
	animate()
	
	# Take Knockback
	if knockbackVector.length() > 0.01:
		velocity = knockbackVector
		knockbackVector *= 0.75
	
	# Move or Attack
	if not currState == STATE.ATTACK:
		move_and_slide()
	else:
		var collision = move_and_collide(velocity * delta)
		
		if collision:
			var collider = collision.get_collider()
			
			knockback(velocity * -3 / KNOCKBACK_MOD)
			attackIcon.value = 0
			sightIcon.value = 100
			attackIcon.set_visible(false)
			
			if collider.is_in_group("Player"):
				collider.damage(ATTACK_DAMAGE)
				collider.knockback(velocity / 1000)
				currState = STATE.CHASE
				sightIcon.set_visible(true)
			elif collider.is_in_group("Slime"):
				collider.knockback(velocity / 1000)
				currState = STATE.CHASE
				sightIcon.set_visible(true)
			else:
				attackIcon.set_visible(false)
				currState = STATE.RECHARGE
	print("SD")

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
			seeSound.play()
	elif currState == STATE.CHASE:
		if position.distance_to(target.position) > CHASE_RANGE:
			sightIcon.value = 99.9
			currState = STATE.WANDER
		elif navigationAgent.is_navigation_finished():
			sightIcon.set_visible(false)
			attackIcon.value = 0
			attackIcon.set_visible(true)
			attackDirection = (target.position - position).normalized()
			currState = STATE.CHARGE
	elif currState == STATE.CHARGE:
		if attackIcon.value >= 100:
			currState = STATE.ATTACK
			attackSound.play()
	elif currState == STATE.ATTACK:
		if attackIcon.value <= 0:
			attackIcon.value = 0
			attackIcon.set_visible(false)
			currState = STATE.RECHARGE
	elif currState == STATE.RECHARGE:
		if attackIcon.value >= 100:
			attackIcon.value = 0
			sightIcon.set_visible(true)
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
			
		velocity = Vector2.ZERO
	elif currState == STATE.CHASE:
		navigationAgent.target_position = target.position
		velocity = global_position.direction_to(navigationAgent.get_next_path_position()) * SPEED
	elif currState == STATE.CHARGE:
		velocity = Vector2.ZERO
		attackIcon.value += delta * 100/CHARGE_SECONDS
	elif currState == STATE.ATTACK:
		velocity = attackDirection * SPEED * 5
		attackIcon.value -= delta * 100/ATTACK_SECONDS
	elif currState == STATE.RECHARGE:
		velocity = Vector2.ZERO
		attackIcon.value += delta * 100/RECHARGE_SECONDS
	else:
		velocity *= 0.95

func animate():
	spriteTimer += 1
	if spriteTimer >= stateToAnimSpeed[currState]:
		spriteTimer = 0
		
		if currState == STATE.DEAD:
			if sprite.frame == 0:
				die()
			else:
				sprite.frame = (sprite.frame + 1) % 6
		else:
			sprite.frame = (sprite.frame + 1) % 6

func damage(dmgTaken : float) -> void:
	hurtSound.play()
	hpBar.set_visible(true)
	hpBar.value -= dmgTaken * 100/MAX_HP 
	if hpBar.value <= 0.02:
		isDead = true

func knockback(kbVec : Vector2, fromPlayer : bool = false) -> void:
	knockbackVector = kbVec * KNOCKBACK_MOD
	
	if fromPlayer:
		currState = STATE.CHASE
		sightIcon.set_visible(true)
		attackIcon.set_visible(false)
		attackIcon.value = 0
		sightIcon.value = 100

func die():
	deathSound.play()
	modulate.a -= 0.1
	if modulate.a <= 0:
		target.gainExp(75)
		queue_free()
	
