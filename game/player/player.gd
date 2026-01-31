extends XROrigin3D
class_name Player

signal recenter()

var simulation: bool = false

@onready var xr_camera_3d: XRCamera3D = $XRCamera3D
@onready var simulator_component: SimulatorComponent = $SimulatorComponent
@onready var left_controller: XRControllerComponent = $LeftController
@onready var right_controller: XRControllerComponent = $RightController
@onready var player_body: XRToolsPlayerBody = $PlayerBody

func get_xr_camera_3d() -> XRCamera3D:
    return xr_camera_3d

func get_headset_global_position() -> Vector3:
    return xr_camera_3d.global_position

func recenter_player():
    # Adjust the origin to rotate it relative to the current camera rotation
    # Effectively forcing the camera to be facing "forward" (wherever the
    # origin was facing) - Mostly this is only useful after setting the
    # global_transform of the player.
    var difference = global_rotation.y - xr_camera_3d.global_rotation.y
    rotate(Vector3.UP, difference)

func enable_player_body():
    if simulation:
        return  # Player body must stay disabled during simulator
    player_body.enabled = true

func disable_player_body():
    player_body.enabled = false

func activate_simulator():
    simulation = true
    simulator_component.enabled = true
    player_body.enabled = false

func _on_left_controller_recenter() -> void:
    recenter.emit()

func _on_right_controller_recenter() -> void:
    recenter.emit()

func _on_mask_detection_area_body_entered(body: Node3D) -> void:
    # if body is Mask:
    # logic
    print("Body entered area: ", body)

func _on_function_pickup_left_controller_has_picked_up(_what: Variant) -> void:
    left_controller.rumble_for(0.2)

func _on_function_pickup_right_controller_has_picked_up(_what: Variant) -> void:
    right_controller.rumble_for(0.2)
