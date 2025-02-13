extends Control

@onready var progress_bar = $TextureProgressBar
@export var golf_ball: RigidBody3D  # Assign GolfBall in Inspector

func _process(delta):
    if golf_ball and golf_ball.aiming:
        progress_bar.value = golf_ball.power
    else:
        progress_bar.value = 0  # Reset when not aiming
