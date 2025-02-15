extends Node3D

@export var ball_scene: PackedScene  # Assign GolfBall.tscn in the Inspector
@export var hole_start_positions: Array[Node3D] # Assign Hole1Start and Hole2Start in Inspector

var current_hole: int = 0
var current_ball: Node3D # Use Node3D type for more flexibility

func _ready():
    # Check for errors with set up.
    if hole_start_positions.is_empty():
        print("❌ Error: No hole start positions assigned!")
        return  # Stop if no start positions

    spawn_ball()

func spawn_ball():
    # Remove the previous ball (if any)
    if current_ball:
        current_ball.queue_free()

    # Create a NEW ball instance from the PackedScene
    current_ball = ball_scene.instantiate()
    add_child(current_ball)

    # Position the ball at the current hole's start position
    current_ball.global_position = hole_start_positions[current_hole].global_position

    # Connect the 'hole_completed' signal.  This MUST be done AFTER
    # the ball is instantiated and added to the scene.
    current_ball.hole_completed.connect(_on_hole_completed)

func _on_hole_completed():
    # Go to the next hole
    current_hole += 1
    if current_hole < hole_start_positions.size():
        print("⛳ Moving to Hole", current_hole + 1)
        spawn_ball()  # Spawn ball at the new hole
    else:
        print("🎉 Game Over! All holes completed.") # end the game
        # Add game over logic here (restart, show score, etc.)
