extends Node
class_name SimulatorComponent
# Runs the game in the desktop window with no VR headset. Handles WASD, and mouse navigation

@export var player: XROrigin3D
@export var right_controller: XRController3D
@export var left_controller: XRController3D
@export var camera: XRCamera3D
@export var enabled: bool = false
@export var mouse_sensitivity: float = 0.1
@export var rotate_speed: float = 1.5
@export var speed: float = 1.5
@export var sprint_speed: float = 5.0
@export var left_controller_position: Vector3 = Vector3(-0.25, -0.3, -0.6)
@export var right_controller_position: Vector3 = Vector3(0.25, -0.3, -0.6)

var activated: bool = false
var velocity = Vector3.ZERO

func _process(delta):
    if not enabled:
        return

    if not activated:
        _activate()

    var adj_speed = speed * delta
    if Input.is_action_pressed("simulator_sprint"):
        adj_speed = sprint_speed * delta

    var climb = Input.get_axis("simulator_descend", "simulator_climb")
    var rot = Input.get_axis("simulator_rotate_right", "simulator_rotate_left")
    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    var direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
        velocity.x = direction.x * adj_speed
        velocity.z = direction.z * adj_speed
    else:
        velocity.x = move_toward(velocity.x, 0, adj_speed)
        velocity.z = move_toward(velocity.z, 0, adj_speed)

    velocity.y = climb * adj_speed

    if Input.is_action_just_pressed("ui_cancel"):
        if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        else:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

    if Input.is_action_just_pressed("simulator_reset"):
        player.global_position = Vector3(0, 1, 0)
        camera.rotation_degrees = Vector3.ZERO

    camera.rotate_z(deg_to_rad(rot * rotate_speed))
    player.global_position += velocity

func _input(event):
    if not enabled:
        return

    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        camera.rotate_x(deg_to_rad(event.relative.y * mouse_sensitivity * -1))
        player.rotate_y(deg_to_rad(event.relative.x * mouse_sensitivity * -1))

        var camera_rot : Vector3 = camera.rotation_degrees
        camera_rot.x = clamp(camera_rot.x, -70, 70)
        camera.rotation_degrees = camera_rot

    if event is InputEventMouseButton:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _activate():
    activated = true

    # Change to show all the time
    left_controller.show_when_tracked = false
    right_controller.show_when_tracked = false

    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    var left_remote_transform : RemoteTransform3D = RemoteTransform3D.new()
    camera.add_child(left_remote_transform)

    # Position the left controller
    left_remote_transform.position = left_controller_position
    left_remote_transform.remote_path = left_controller.get_path()

    var right_remote_transform : RemoteTransform3D = RemoteTransform3D.new()
    camera.add_child(right_remote_transform)

    # Position the right controller
    right_remote_transform.position = right_controller_position
    right_remote_transform.remote_path = right_controller.get_path()
