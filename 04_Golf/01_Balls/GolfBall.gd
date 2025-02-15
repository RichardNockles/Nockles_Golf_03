extends RigidBody3D

@export var power_multiplier: float = 20.0
@export var mouse_sensitivity: float = 0.2
@export var camera_distance: float = 4.0  # Adjust in Inspector
@export var camera_height: float = 1.5    # Adjust in Inspector
@export var charge_speed: float = 0.3  # Adjust in Inspector
@export var stop_threshold: float = 0.1  # Adjust in Inspector

@onready var ball_camera = $BallCamera # Get a reference to the camera.

var is_aiming: bool = true
var is_moving: bool = false
var shot_power: float = 0.0

signal hole_completed # Custom signal

func _ready():
    print("🏌️ Golf Ball Ready!")
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # Capture mouse for aiming
    freeze = false # make sure the body is not frozen.

func _unhandled_input(event):
    if is_aiming:
        if event is InputEventMouseMotion:
            # Rotate the ball for aiming
            rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))

        if event.is_action_pressed("swing"):
            shot_power = 0.1 # start the shot
        if event.is_action_released("swing"):
            _hit_ball() # hit ball

func _process(delta):
    # Charge up the shot power while holding the "swing" button
    if is_aiming and Input.is_action_pressed("swing"):
        shot_power = min(1.0, shot_power + delta * charge_speed)

func _physics_process(_delta): # delta is not used
    if is_moving:
        # Check if the ball has stopped
        if linear_velocity.length() < stop_threshold:
            linear_velocity = Vector3.ZERO
            angular_velocity = Vector3.ZERO
            is_moving = false
            is_aiming = true
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # recapture the mouse

        # Position the camera behind and above the ball
        ball_camera.global_transform.origin = global_transform.origin + Vector3(0, camera_height, -camera_distance)
        ball_camera.look_at(global_transform.origin, Vector3.UP)

func _hit_ball():
    if is_aiming:
        print("🏌️ Hitting Ball! Power:", shot_power)
        is_aiming = false
        is_moving = true
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE # release the mouse

        # Calculate the hit direction (forward vector of the ball)
        var direction = -transform.basis.z
        apply_impulse(direction * shot_power * power_multiplier)

        shot_power = 0.0  # Reset power after hitting
        freeze = false

func _on_HoleTrigger_body_entered(body):
    # Check if the body that entered the trigger is the golf ball itself
    if body == self:
        print("🏆 Ball in the hole!")
        hole_completed.emit()  # Emit the signal!
        set_deferred("sleeping", true) # stop the ball.
