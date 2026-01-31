extends Node2D

func _ready() -> void:
	create_boundary_walls()

func create_boundary_walls() -> void:
	var screen_size = get_viewport_rect().size
	var wall_thickness = 10.0
	
	# Creates 4 walls: left, right, top, bottom
	var walls = [
		# Left wall
		{
			"position": Vector2(-wall_thickness / 2, screen_size.y / 2),
			"size": Vector2(wall_thickness, screen_size.y)
		},
		# Right wall
		{
			"position": Vector2(screen_size.x + wall_thickness / 2, screen_size.y / 2),
			"size": Vector2(wall_thickness, screen_size.y)
		},
		# Top wall
		{
			"position": Vector2(screen_size.x / 2, -wall_thickness / 2),
			"size": Vector2(screen_size.x, wall_thickness)
		},
		# Bottom wall
		{
			"position": Vector2(screen_size.x / 2, screen_size.y + wall_thickness / 2),
			"size": Vector2(screen_size.x, wall_thickness)
		}
	]
	
	for wall_data in walls:
		var wall = StaticBody2D.new()
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		
		shape.size = wall_data["size"]
		collision.shape = shape
		
		wall.add_child(collision)
		wall.position = wall_data["position"]
		
		add_child(wall)
