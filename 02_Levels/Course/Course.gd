extends Node3D

# ✅ Signal to notify Main.gd when the ball enters a hole
signal ball_entered_hole  

func _ready():
    print("⛳ Course Loaded!")

    # ✅ Connect signals for all hole triggers
    var hole_triggers = get_tree().get_nodes_in_group("holes")
    for hole_trigger in hole_triggers:
        if hole_trigger.has_signal("body_entered"):
            hole_trigger.connect("body_entered", Callable(self, "_on_HoleTrigger_body_entered"))

func _on_HoleTrigger_body_entered(body):
    if body.name == "GolfBall":
        print("🏆 Ball entered a hole!")
        ball_entered_hole.emit()  # ✅ Emit signal to notify Main.gd
