extends Node2D

@export var enemy_scene: PackedScene
@export var boss_scene: PackedScene  # NEW!
@export var total_waves: int = 3
@export var enemies_per_wave: int = 5

var current_wave: int = 0
var enemies_spawned_in_wave: int = 0
var enemies_alive: int = 0
var screen_size: Vector2

func _ready() -> void:
	screen_size = get_viewport_rect().size
	GameData.set_area(1)
	start_next_wave()

func start_next_wave() -> void:
	current_wave += 1
	
	if current_wave > total_waves:
		print("Level 1 Complete!")
		return
	
	enemies_spawned_in_wave = 0
	enemies_alive = 0
	
	# Wave 3 = BOSS!
	if current_wave == 3:
		spawn_boss()
	else:
		spawn_enemies_for_wave()

func spawn_enemies_for_wave() -> void:
	if not enemy_scene:
		push_error("Enemy scene not set!")
		return
	
	for i in range(enemies_per_wave):
		var enemy = enemy_scene.instantiate()
		add_child(enemy)
		enemy.position = Vector2(
			randf_range(50, screen_size.x - 50),
			50 + (current_wave - 1) * 30
		)
		enemy.tree_exited.connect(_on_enemy_died)
		enemies_alive += 1
		enemies_spawned_in_wave += 1

func spawn_boss() -> void:
	if not boss_scene:
		push_error("Boss scene not set!")
		return
	
	print(" BOSS WAVE! ")
	var boss = boss_scene.instantiate()
	add_child(boss)
	boss.position = Vector2(screen_size.x / 2, 100)
	boss.tree_exited.connect(_on_enemy_died)
	enemies_alive = 1
	enemies_spawned_in_wave = 1

func _on_enemy_died() -> void:
	enemies_alive -= 1
	if enemies_alive <= 0:
		await get_tree().create_timer(2.0).timeout
		start_next_wave()
