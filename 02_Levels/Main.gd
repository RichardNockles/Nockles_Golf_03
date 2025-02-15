extends Node3D

@export var ball_scene: PackedScene
@export var hole_start_positions: Array[Node3D]

var current_hole: int = 0
var current_ball

func _ready():
    print("Main _ready() called") # Debugging print
    if hole_start_positions.is_empty():
        print("❌ Error: No hole start positions assigned!")
        return

    print("hole_start_positions size:", hole_start_positions.size())
    spawn_ball()

func spawn_ball():
    print("spawn_ball() called") # Debugging print
    print("ball_scene:", ball_scene)
    if current_ball:
        current_ball.queue_free()

    if ball_scene == null:
      print("ERROR: Ball Scene is Null")
      return # exit to prevent crashes

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
