extends Node3D

@export var golf_ball: RigidBody3D  # Assign GolfBall.tscn in Inspector
@export var ball_start_positions: Array[Node3D]  # Assign BallStartPos_X nodes
@export var course: Node3D  # Assign Course.tscn

var current_hole = 0  # Track the hole number

func _ready():
    print("🎮 Main Scene Loaded")
    if golf_ball and ball_start_positions.size() > 0:
        move_ball_to_start(0)  # Start at hole 1

    # Connect hole triggers to function
    var hole_triggers = course.get_tree().get_nodes_in_group("holes")
    for hole in hole_triggers:
        hole.connect("body_entered", Callable(self, "_on_HoleTrigger_body_entered"))

func _on_HoleTrigger_body_entered(body):
    if body == golf_ball:
        print("⛳ Ball entered hole", current_hole + 1, "- Moving to next hole")
        move_to_next_hole()

func move_to_next_hole():
    move_ball_to_start(current_hole + 1)

func move_ball_to_start(hole_index):
    if hole_index < ball_start_positions.size():
        current_hole = hole_index
        golf_ball.global_transform.origin = ball_start_positions[hole_index].global_transform.origin
        golf_ball.freeze = true  # Stop the ball until the next shot
        print("🎯 Ball moved to start position for hole", hole_index + 1)
    else:
        print("🎉 Game Over - All holes completed!")
