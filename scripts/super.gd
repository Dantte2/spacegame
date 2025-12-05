extends CharacterBody2D

# --- Projectile Properties ---
@export var speed: float = 2000.0
@export var lifetime: float = 10.0
@export var explosion_scene: PackedScene
@export var collision_delay: float = 0.0
@export var turn_speed: float = 5.0
@export var homing_radius: float = 2000.0
@export var damage: int = 50

# --- References ---
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# --- Internal State ---
var timer_started: bool = false
var target: Node2D = null

func _ready():
    if sprite:
        sprite.play()
    # Auto-destroy after lifetime
    destroy_after_lifetime()

# Auto-destroy after lifetime
func destroy_after_lifetime():
    await get_tree().create_timer(lifetime).timeout
    if not timer_started:
        explode()

func _physics_process(delta):
    # Acquire target if none
    if not target:
        target = get_closest_enemy()
    
    # Homing logic
    if target and target.is_inside_tree():
        var to_target_angle = (target.global_position - global_position).angle()
        rotation = lerp_angle(rotation, to_target_angle, turn_speed * delta)
    
    # Move forward
    var velocity = Vector2(speed, 0).rotated(rotation)
    var collision = move_and_collide(velocity * delta)
    if collision:
        var body = collision.get_collider()
        if body and body.is_in_group("enemy"):
            timer_started = true
            await get_tree().create_timer(collision_delay).timeout
            explode()
            if body.has_method("take_damage"):
                body.take_damage(damage)

# Find closest enemy within homing radius
func get_closest_enemy() -> Node2D:
    var enemies = get_tree().get_nodes_in_group("enemy")
    var closest: Node2D = null
    var min_dist = homing_radius
    for e in enemies:
        var dist = global_position.distance_to(e.global_position)
        if dist < min_dist:
            min_dist = dist
            closest = e
    return closest

# Spawn explosion and free projectile
func explode():
    if explosion_scene:
        var e = explosion_scene.instantiate()
        e.global_position = global_position
        # Always add directly to the main scene so it's not affected by camera
        get_tree().current_scene.add_child(e)
    queue_free()
