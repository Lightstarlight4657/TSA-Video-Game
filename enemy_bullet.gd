extends Area2D

@export var speed := 180

var screen_size: Vector2

func _ready() -> void:
	screen_size = get_viewport_rect().size
	body_entered.connect(_on_body_entered)

func _process(delta):
	position.y += speed * delta
	if position.y > screen_size.y: # this is the bottom of the screen
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(1)  # Pass damage amount
		queue_free()
