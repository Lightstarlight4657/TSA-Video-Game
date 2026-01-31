extends Sprite2D
#Author Mateen Alawi, Date December 7th 2025
#This is the code for the Character of Space Angels


#This is the speed constant, this controls the speed of the character
const SPEED: float = 100
#This is a container for the x and y values called a Vector2
var direction := Vector2(0,0)

#references to the collision
@onready var collision_rect: CollisionShape2D = $CollisionShape2D


#things added by Abigel
@export var base_health: int = 100
var current_health: int
var max_health: int
var screen_size: Vector2

@export var bullet_scene: PackedScene
@export var shoot_cooldown: float = 0.3
var can_shoot: bool = true

func _ready() -> void:
	screen_size = get_viewport_rect().size
	var hp_multiplier = GameData.get_hp_multiplier()
	max_health = int(base_health * hp_multiplier)
	current_health = max_health
	print("Player HP: ", current_health, "/", max_health)

#This function is a more efficient way to stor character movement
func _physics_process(delta: float) -> void:
	#Checks which input is being pressed then updates the corresponding value with the speed constant
	if(Input.is_action_pressed("move_left")):
		direction.x = -SPEED
	elif (Input.is_action_pressed("move_right")):
		direction.x = SPEED 
	elif(Input.is_action_pressed("move_up")):
		direction.y = -SPEED
	elif (Input.is_action_pressed("move_down")):
		direction.y = SPEED
	position+= direction*delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	
	
# Shooting
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func shoot() -> void:
	if not bullet_scene:
		print("No bullet scene assigned!")
		return
	
	can_shoot = false
	
	# Check for double shot ability
	if GameData.has_ability("extra_cannons"):
		spawn_bullet(Vector2(-15, 0))  # Left
		spawn_bullet(Vector2(15, 0))   # Right
		spawn_bullet(Vector2(0, 0))    # Center
	else:
		spawn_bullet(Vector2(0, 0))    # Single
	
	# Cooldown
	var cooldown = shoot_cooldown * GameData.get_fire_rate_multiplier()
	await get_tree().create_timer(cooldown).timeout
	can_shoot = true

func spawn_bullet(offset: Vector2) -> void:
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	
	# Get bullet spawn point position
	var spawn_point = get_node_or_null("BulletSpawnPoint")
	if spawn_point:
		bullet.global_position = spawn_point.global_position + offset
	else:
		bullet.global_position = global_position + Vector2(0, -30) + offset

func take_damage(amount: int) -> void:
	if GameData.has_ability("invincibility") and GameData.is_invincibility_available():
		return
	
	if GameData.has_ability("rechargeable_shield"):
		amount = int(GameData.apply_shield_damage(float(amount)))
	
	current_health -= amount
	print("Player health: ", current_health, "/", max_health)
	
	modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	
	if current_health <= 0:
		die()

func die() -> void:
	print("Player died!")
	GameData.award_death_bonus()
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/Shop.tscn")
