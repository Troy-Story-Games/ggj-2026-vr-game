extends XROrigin3D
class_name Player

signal recenter()

var simulation: bool = false

@onready var xr_camera_3d: XRCamera3D = $XRCamera3D
@onready var simulator_component: SimulatorComponent = $SimulatorComponent
@onready var left_controller: XRController3D = $LeftController
@onready var right_controller: XRController3D = $RightController
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
