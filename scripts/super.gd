extends Area2D

@export var speed: float = 2000.0        
@export var lifetime: float = 1.0        
@export var explosion_scene: PackedScene
@export var collision_delay: float = 0.2  # Delay before explosion after first collision

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var timer_started: bool = false

func _ready():
    if sprite:
        sprite.play()
    
    # Connect collision signal
    if has_node("CollisionShape2D"):
        connect("body_entered", Callable(self, "_on_body_entered"))

    # Auto-explode after lifetime if nothing is hit
    explode_after_delay(lifetime)

func _physics_process(delta):
    # Move forward
    position += Vector2(speed * delta, 0).rotated(rotation)

# Trigger explosion timer on first collision
func _on_body_entered(body):
    if timer_started:
        return

    if body.is_in_group("enemy"):
        timer_started = true
        # Start delayed explosion
        start_explosion_timer(collision_delay)

# Delayed explosion
func start_explosion_timer(delay: float) -> void:
    await get_tree().create_timer(delay).timeout
    spawn_explosion()
    queue_free()

# Explode automatically after lifetime if not already triggered
func explode_after_delay(time: float) -> void:
    await get_tree().create_timer(time).timeout
    if not timer_started:
        spawn_explosion()
        queue_free()

func spawn_explosion() -> void:
    if explosion_scene:
        var explosion = explosion_scene.instantiate()
        explosion.global_position = global_position
        get_tree().current_scene.add_child(explosion)
