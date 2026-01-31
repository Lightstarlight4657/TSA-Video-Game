extends Node

@export var enemy_scene: PackedScene
@export var boss_scene: PackedScene

var current_wave := 1
var enemies_left := 0
var screen_size: Vector2

func _ready() -> void:
	screen_size = get_viewport_rect().size
	# Small delay before first wave
	await get_tree().create_timer(0.5).timeout
	start_wave()

func start_wave() -> void:
	print("Starting Wave ", current_wave)
	
	match current_wave:
		1:
			spawn_enemy_rows(1, 8)   # 1 row, 8 enemies
		2:
			spawn_enemy_rows(2, 8)   # 2 rows, 8 per row
		3:
			spawn_boss()             # Boss fight
		_:
			print("LEVEL 1 COMPLETE!")
			# Add victory logic here (change scene, show message, etc.)
			return

func spawn_enemy_rows(rows: int, cols: int) -> void:
	if not enemy_scene:
		push_error("Enemy scene not assigned in Wave Manager!")
		return
	
	enemies_left = rows * cols
	
	# Calculate spacing to center enemies on screen
	var spacing_x = (screen_size.x * 0.8) / (cols + 1)
	var spacing_y = 60
	var start_x = screen_size.x * 0.1  # 10% margin from left
	var start_y = 80
	
	for r in range(rows):
		for c in range(cols):
			var enemy = enemy_scene.instantiate()
			enemy.position = Vector2(
				start_x + (c + 1) * spacing_x,
				start_y + r * spacing_y
			)
			
			# Connect to tree_exited signal (when enemy dies)
			enemy.tree_exited.connect(_on_enemy_destroyed)
			
			add_child(enemy)

func spawn_boss() -> void:
	if not boss_scene:
		push_error("Boss scene not assigned in Wave Manager!")
		return
	
	enemies_left = 1
	
	var boss = boss_scene.instantiate()
	boss.position = Vector2(screen_size.x / 2, 120)  # Center of screen
	
	# Connect to tree_exited signal
	boss.tree_exited.connect(_on_enemy_destroyed)
	
	add_child(boss)

func _on_enemy_destroyed() -> void:
	enemies_left -= 1
	print("Enemy destroyed! Remaining: ", enemies_left)
	
	if enemies_left <= 0:
		next_wave()

func next_wave() -> void:
	current_wave += 1
	
	if current_wave > 3:
		print("Level 1 Complete!")
		# No automatic shop visit - player dies to boss, then goes to shop
		return
	else:
		# Small delay before next wave
		await get_tree().create_timer(2.0).timeout
		start_wave()
