extends Area2D

# --- Bullet properties ---
var velocity: Vector2 = Vector2.ZERO
@export var lifetime := 10.0
@export var damage: int = 1  # Add damage property

func _ready():
    # Play animation if you have one
    if has_node("AnimatedSprite2D"):
        $AnimatedSprite2D.play()

    # Connect collision signal if there is a CollisionShape2D
    if has_node("CollisionShape2D"):
        connect("body_entered", Callable(self, "_on_body_entered"))

    # Delete after a while
    await get_tree().create_timer(lifetime).timeout
    queue_free()

func _physics_process(delta):
    position += velocity * delta

# --- Handle collisions ---
func _on_body_entered(body):
    # Only hit enemies (by group)
    if body.is_in_group("enemy"):
        if body.has_method("take_damage"):
            body.take_damage(damage)
        queue_free()
