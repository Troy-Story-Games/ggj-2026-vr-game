extends XRController3D
class_name XRControllerComponent

signal recenter()

var controller_velocity := Vector3.ZERO
var prior_controller_position := Vector3.ZERO
var prior_controller_velocities := []

func _ready():
    button_pressed.connect(_on_button_pressed)
    button_released.connect(_on_button_released)

func _physics_process(delta):
    _update_velocity(delta)

func _on_button_pressed(button_name: String):
    if button_name == "primary_click":
        recenter.emit()

func _on_button_released(_button_name: String):
    pass

func rumble_for(duration : float, intensity : float = 0.5, frequency: float = 1.0, delay_sec: float = 0.0):
    trigger_haptic_pulse("haptic", frequency, intensity, duration, delay_sec)

func _update_velocity(delta):
    # Reset the controller velocity
    controller_velocity = Vector3.ZERO

    if prior_controller_velocities.size() > 0:
        for vel in prior_controller_velocities:
            controller_velocity += vel

        # Get the average velocity, instead of just adding them together.
        controller_velocity = controller_velocity / prior_controller_velocities.size()

    # Add the most recent controller velocity to the list of proper controller velocities
    prior_controller_velocities.append((global_transform.origin - prior_controller_position) / delta)

    # Calculate the velocity using the controller's prior position.
    controller_velocity += (global_transform.origin - prior_controller_position) / delta
    prior_controller_position = global_transform.origin

    # If we have more than a third of a seconds worth of velocities, then we
    # should remove the oldest
    if prior_controller_velocities.size() > 30:
        prior_controller_velocities.remove_at(0)
