extends CanvasLayer

# Assign your Enemy scene here in the editor
@export var enemy_scene: PackedScene

# Top-left spawn position of the column
@export var spawn_position: Vector2 = Vector2(400, 300)

# Vertical spacing (gap) between enemies
@export var vertical_spacing: float = 80.0  # adjust this to make gap bigger/smaller

# Number of enemies per button press
@export var enemies_per_press: int = 4

# Called when the "RespawnButton" is pressed
func _on_respawnbutton_pressed():
    if not enemy_scene:
        print("No enemy scene assigned!")
        return

    for i in range(enemies_per_press):
        var enemy = enemy_scene.instantiate()

        # Add vertical spacing for each enemy
        enemy.global_position = spawn_position + Vector2(0, i * vertical_spacing)

        get_tree().current_scene.add_child(enemy)

    print(enemies_per_press, " enemies spawned with spacing of ", vertical_spacing)
