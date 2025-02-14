extends Node3D

@export var ball_scene: PackedScene  # Assign `GolfBall.tscn`
@export var hole_start_positions: Array[Node3D]  # Assign `BallStartPos_X` from Course.tscn

var current_hole: int = 0
var current_ball

func _ready():
    if hole_start_positions.is_empty():
        print("❌ Error: No hole start positions assigned!")
        return

    spawn_ball()

func spawn_ball():
    if current_ball:
        current_ball.queue_free()  # Remove old ball

    # Spawn new golf ball
    current_ball = ball_scene.instantiate()
    add_child(current_ball)
    current_ball.global_position = hole_start_positions[current_hole].global_position

    # 🔹 Connect the signal AFTER the ball is instantiated
    current_ball.hole_completed.connect(_on_hole_completed)

func _on_hole_completed():
    current_hole += 1
    if current_hole < hole_start_positions.size():
        print("⛳ Moving to Hole", current_hole + 1)
        spawn_ball()  # Spawn at next hole
    else:
        print("🎉 Game Over! All holes completed.")
