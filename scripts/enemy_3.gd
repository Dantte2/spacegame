extends CharacterBody2D

# -----------------------------
# Nodes
# -----------------------------
@onready var exhaust: AnimatedSprite2D = $exhaust
@onready var bullet_spawn: Node2D = $BulletSpawn
@onready var sprite: Sprite2D = $Sprite2D

# -----------------------------
# Movement parameters
# -----------------------------
@export var max_speed: Vector2 = Vector2(250, 200)  # max horizontal and vertical speed
@export var acceleration: float = 1500.0
@export var horizontal_distance: float = 400.0     # preferred X distance from player
@export var horizontal_deadzone: float = 100.0
@export var vertical_deadzone: float = 15.0
@export var prediction_factor: float = 0.3          # how much to lead player

# -----------------------------
# Wandering parameters
# -----------------------------
@export var wander_strength: float = 0.3
@export var wander_speed: float = 1.5
var wander_offset_y := 0.0
var wander_direction := 1.0

# -----------------------------
# Shooting parameters
# -----------------------------
@export var fire_rate: float = 1.5
@export var burst_count: int = 3
@export var burst_delay: float = 0.1
@export var laser_scene: PackedScene

# -----------------------------
# Internal variables
# -----------------------------
var player: CharacterBody2D
var fire_timer := 0.0

func _ready():
    if exhaust:
        exhaust.play("boost")
        exhaust.visible = true

    wander_offset_y = randf_range(-1, 1)

    # pick first player
    var players = get_tree().get_nodes_in_group("player_body")
    if players.size() > 0:
        player = players[0]

func _physics_process(delta):
    if not player:
        return

    # --- Predictive target ---
    var target_pos = player.global_position
    if player.has_method("get_velocity"):
        target_pos += player.get_velocity() * prediction_factor

    # --- Add vertical wandering ---
    target_pos.y += wander_offset_y * 50

    # --- Horizontal distance logic ---
    var dx = global_position.x - target_pos.x
    var desired_x = 0.0
    if dx < horizontal_distance - horizontal_deadzone:
        desired_x = max_speed.x
    elif dx > horizontal_distance + horizontal_deadzone:
        desired_x = -max_speed.x
    else:
        desired_x = 0.0

    # --- Vertical movement ---
    var dy = target_pos.y - global_position.y
    var desired_y = 0.0
    if abs(dy) > vertical_deadzone:
        desired_y = clamp(dy, -max_speed.y, max_speed.y)

    # --- Smooth acceleration ---
    velocity.x = move_toward(velocity.x, desired_x, acceleration * delta)
    velocity.y = move_toward(velocity.y, desired_y, acceleration * delta)

    # --- Apply movement ---
    move_and_slide()

    # --- Clamp inside camera ---
    clamp_to_camera()

    # --- Update wandering ---
    wander_offset_y += wander_direction * wander_speed * delta
    if wander_offset_y > 1.0 or wander_offset_y < -1.0:
        wander_direction *= -1

    # --- Shooting ---
    fire_timer -= delta
    if fire_timer <= 0:
        fire_burst()
        fire_timer = fire_rate

# -----------------------------
# Fire burst
# -----------------------------
func fire_burst():
    if not laser_scene or not player:
        return
    for i in range(burst_count):
        shoot_one()
        await get_tree().create_timer(burst_delay).timeout

func shoot_one():
    var laser = laser_scene.instantiate()
    laser.global_position = bullet_spawn.global_position
    var dir = (player.global_position - bullet_spawn.global_position).normalized()
    laser.velocity = dir * 1300
    laser.rotation = dir.angle()
    get_tree().current_scene.add_child(laser)

# -----------------------------
# Keep enemy in camera view
# -----------------------------
func clamp_to_camera():
    var cam = get_viewport().get_camera_2d()
    if not cam:
        return
    var cam_size = cam.get_zoom() * get_viewport().get_visible_rect().size / 2
    var cam_rect = Rect2(cam.global_position - cam_size, cam_size * 2)

    # Stop velocity if going out of bounds
    if (global_position.y <= cam_rect.position.y + 50 and velocity.y < 0) or (global_position.y >= cam_rect.position.y + cam_rect.size.y - 50 and velocity.y > 0):
        velocity.y = 0
    if (global_position.x <= cam_rect.position.x + 50 and velocity.x < 0) or (global_position.x >= cam_rect.position.x + cam_rect.size.x - 50 and velocity.x > 0):
        velocity.x = 0

    # Clamp position
    global_position.x = clamp(global_position.x, cam_rect.position.x + 50, cam_rect.position.x + cam_rect.size.x - 50)
    global_position.y = clamp(global_position.y, cam_rect.position.y + 50, cam_rect.position.y + cam_rect.size.y - 50)
