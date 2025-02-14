extends Node3D

@export var ball_scene: PackedScene
@export var hole_start_positions: Array[Node3D]

var current_hole: int = 0
var current_ball

func _ready():
    spawn_ball()

func spawn_ball():
    if current_ball:
        current_ball.queue_free()

    current_ball = ball_scene.instantiate()
    add_child(current_ball)
    current_ball.global_position = hole_start_positions[current_hole].global_position
    current_ball.hole_completed.connect(_on_hole_completed)  # Connect AFTER instantiation

func _on_hole_completed():
    current_hole += 1
    if current_hole < hole_start_positions.size():
        spawn_ball()  # Spawn at next hole
    else:
        print("Game Over!")  # All holes completed
        # Add game over logic here (e.g., display a message, restart)
