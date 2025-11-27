extends Area2D

@export var speed: float = 600.0
@export var damage_to_shield: int = 50
@export var damage_to_health: int = 10

func _ready():
    collision_layer = 2       # bullet
    collision_mask = 1        # can hit player
    monitoring = true
    monitorable = true

func _physics_process(delta):
    position += Vector2(-speed, 0) * delta

    # Check overlaps manually — this ALWAYS works in Godot 4
    var areas = get_overlapping_areas()
    for a in areas:
        _handle_hit(a)
        return

    var bodies = get_overlapping_bodies()
    for b in bodies:
        _handle_hit(b)
        return

func _handle_hit(target):
    # Find the player node (the one with the health/shield script)
    var player = target
    while player and not player.has_method("take_damage"):
        player = player.get_parent()

    if player == null:
        return  # Not the player

    # Shield logic
    if player.shield > 0:
        player.apply_shield_damage(damage_to_shield, global_position)
    else:
        player.take_damage(damage_to_health)

    queue_free()
