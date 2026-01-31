extends Area2D

@export var speed: float = 400.0
var screen_size: Vector2

func _ready() -> void:
	screen_size = get_viewport_rect().size
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position.y -= speed * delta
	
	if position.y < -10:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy") or body.is_in_group("boss"):
		queue_free()
