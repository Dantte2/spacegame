extends Area2D

@export var speed: float = 600.0
var velocity: Vector2 = Vector2(-600, 0)

func _ready():
    monitorable = true
    collision_layer = 2       # enemy bullet layer
    collision_mask = 1        # hit player/shield
    add_to_group("enemy_bullet")

func _physics_process(delta):
    position += velocity * delta

    if position.x < -100 or position.x > 2000:
        queue_free()

func _on_body_entered(body):
    if body.is_in_group("player"):
        # --- Apply shield damage correctly ---
        if body.has_method("apply_shield_damage"):
            body.apply_shield_damage(10, global_position)  
            #            damage ↑       hit position ↑
        queue_free()
