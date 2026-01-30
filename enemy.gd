extends Area2D

@export var speed: float = 60.0
@export var health: int = 1
@export var bullet_scene: PackedScene
@export var shoot_interval: float = 2.0
@export var direction: int = 1  # 1 = right, -1 = left
@export var move_down_amount: float = 20.0  # How far to move down when hitting edge

var screen_size: Vector2

@onready var shoot_timer: Timer = $ShootTimer

func _ready() -> void:
	screen_size = get_viewport_rect().size
	
	# Setup shooting behavior
	if shoot_timer:
		shoot_timer.wait_time = shoot_interval
		shoot_timer.timeout.connect(_on_shoot_timer_timeout)  # Fixed: connect signal
		shoot_timer.start()
	
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# Move horizontally
	position.x += speed * direction * delta
	
	# Check screen boundaries and reverse direction (Space Invaders style)
	if position.x <= 0:
		position.x = 0
		direction = 1
		position.y += move_down_amount  # Move down when hitting edge
	elif position.x >= screen_size.x:
		position.x = screen_size.x
		direction = -1
		position.y += move_down_amount  # Move down when hitting edge
	
	# Game over if enemy reaches bottom
	if position.y >= screen_size.y - 50:
		get_tree().reload_current_scene() 

func _on_body_entered(body: Node) -> void:
	
	# Detect hits from player bullets
	if body.is_in_group("player_bullet"):
		body.queue_free()
		take_damage(1)

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()

func shoot() -> void:
	if not bullet_scene:
		return
	
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position + Vector2(0, 10)

func _on_shoot_timer_timeout() -> void:  
	shoot()
