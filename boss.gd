extends Area2D

@export var speed: float = 80.0
@export var health: int = 30
@export var bullet_scene: PackedScene
@export var shoot_interval: float = 0.8
@export var direction: int = 1

var screen_size: Vector2
var is_rapid_firing: bool = false

@onready var shoot_timer: Timer = $ShootTimer
@onready var rapid_fire_timer: Timer = $RapidFireTimer
@onready var rapid_fire_cooldown_timer: Timer = $RapidFireCooldownTimer

func _ready() -> void:
	screen_size = get_viewport_rect().size
	
	if shoot_timer:
		shoot_timer.wait_time = shoot_interval
		shoot_timer.timeout.connect(_on_shoot_timer_timeout)
		shoot_timer.start()
	
	if rapid_fire_timer:
		rapid_fire_timer.timeout.connect(_on_rapid_fire_end)
	
	if rapid_fire_cooldown_timer:
		rapid_fire_cooldown_timer.timeout.connect(_on_rapid_fire_ready)
	
	body_entered.connect(_on_body_entered)
	
	# Start first rapid fire after 3 seconds
	await get_tree().create_timer(3.0).timeout
	activate_rapid_fire()

func _physics_process(delta: float) -> void:
	position.x += speed * direction * delta
	
	if position.x <= 50:
		position.x = 50
		direction = 1
	elif position.x >= screen_size.x - 50:
		position.x = screen_size.x - 50
		direction = -1

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player_bullet"):
		body.queue_free()
		take_damage(1)
		flash_damage()

func take_damage(amount: int) -> void:
	health -= amount
	print("Boss health: ", health)
	
	# Speed up when damaged
	if health <= 15:
		speed = 120.0
		shoot_interval = 0.5
		if shoot_timer:
			shoot_timer.wait_time = shoot_interval
	
	if health <= 0:
		print("BOSS DEFEATED!")
		GameData.add_enemy_kill()  # Give player money
		queue_free()

func flash_damage() -> void:
	modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

func shoot() -> void:
	if not bullet_scene:
		return
	
	# Boss shoots 3 bullets (or 5 during rapid fire)
	var bullet_count = 3 if not is_rapid_firing else 5
	var spacing = 30
	var start_offset = -(bullet_count - 1) * spacing / 2
	
	for i in range(bullet_count):
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position + Vector2(start_offset + i * spacing, 20)

func activate_rapid_fire() -> void:
	print("BOSS RAPID FIRE!")
	is_rapid_firing = true
	
	if shoot_timer:
		shoot_timer.wait_time = 0.2
	
	if rapid_fire_timer:
		rapid_fire_timer.start()
	
	if rapid_fire_cooldown_timer:
		rapid_fire_cooldown_timer.start()

func _on_rapid_fire_end() -> void:
	is_rapid_firing = false
	if shoot_timer:
		shoot_timer.wait_time = shoot_interval

func _on_rapid_fire_ready() -> void:
	activate_rapid_fire()

func _on_shoot_timer_timeout() -> void:
	shoot()
