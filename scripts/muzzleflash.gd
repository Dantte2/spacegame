extends Node2D

@export var duration := 0.1   # how long flash exists

func _ready():
    # Increase brightness before playing animation
    if has_node("AnimatedSprite2D"):
        $AnimatedSprite2D.modulate = Color(1.5, 1.5, 1.5, 1)  # brighten flash
        $AnimatedSprite2D.play("flash")   # play your animation

    # remove after short time
    await get_tree().create_timer(duration).timeout
    queue_free()
