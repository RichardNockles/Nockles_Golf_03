extends Node3D

@export var ball_scene: PackedScene
@export var hole_start_positions: Array[Node3D]

var current_hole: int = 0
var current_ball: RigidBody3D

func _ready():
    print("=== Main.gd _ready() START ===")
    if hole_start_positions.is_empty():
        print("❌ ERROR: No hole start positions assigned!")
        return  # Stop if no start positions

    print("Hole Start Positions Count:", hole_start_positions.size())
    for i in range(hole_start_positions.size()):
        print("  Hole ", i, ": ", hole_start_positions[i]) #verify the hole positions.

    print("ball_scene:", ball_scene)  # Check if ball_scene is null
    spawn_ball()
    print("=== Main.gd _ready() END ===")


func spawn_ball():
    print("--- spawn_ball() called ---")

    if ball_scene == null:
        print("❌❌❌ ERROR: ball_scene is null!  Cannot instantiate.")
        return # exit to prevent crashes

    if current_ball:
        current_ball.queue_free()

    current_ball = ball_scene.instantiate()
    add_child(current_ball)
    current_ball.global_position = hole_start_positions[current_hole].global_position
    current_ball.hole_completed.connect(_on_hole_completed)

func _on_hole_completed():
    current_hole += 1
    if current_hole < hole_start_positions.size():
        print("⛳ Moving to Hole", current_hole + 1)
        spawn_ball()
    else:
        print("🎉 Game Over! All holes completed.")
