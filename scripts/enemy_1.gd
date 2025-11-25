extends CharacterBody2D  

@export var health: int = 10
@export var death_animation_scene: PackedScene  
@export var laser_scene: PackedScene
@export var fire_rate: float = 1.0  # seconds between shots

# --- References ---
@onready var bullet_spawn: Node2D = $BulletSpawn

# --- Firing control ---
var can_shoot: bool = true

func _ready():
    add_to_group("enemy")
    start_firing()

func start_firing():
    if can_shoot:
        shoot_laser()
        can_shoot = false
        # Wait fire_rate seconds before next shot
        await get_tree().create_timer(fire_rate).timeout
        can_shoot = true
        start_firing()  # repeat firing

func shoot_laser():
    if not laser_scene:
        return

    # Instantiate laser
    var laser = laser_scene.instantiate()
    
    # Spawn at BulletSpawn global position
    laser.global_position = bullet_spawn.global_position
    
    # Set forward velocity
    if "velocity" in laser:
        laser.velocity = Vector2(-600, 0)  # adjust speed/direction

    # Add deferred to avoid "Parent node busy" error
    get_tree().current_scene.call_deferred("add_child", laser)

func take_damage(amount: int) -> void:
    health -= amount
    if health <= 0:
        die()

func die() -> void:
    if death_animation_scene:
        var anim = death_animation_scene.instantiate()
        anim.global_position = global_position
        get_tree().current_scene.add_child(anim)
    queue_free()
