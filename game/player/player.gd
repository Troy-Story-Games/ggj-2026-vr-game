extends XROrigin3D
class_name Player

signal recenter()

var simulation: bool = false
var wearing_mask: Mask
var wearing_mask_camera_local_transform: Transform3D
var left_picked_up_object: Variant
var right_picked_up_object: Variant

@onready var xr_camera_3d: XRCamera3D = $XRCamera3D
@onready var simulator_component: SimulatorComponent = $SimulatorComponent
@onready var left_controller: XRControllerComponent = $LeftController
@onready var right_controller: XRControllerComponent = $RightController
@onready var function_pointer: XRToolsFunctionPointer = $RightController/FunctionPointer
@onready var player_body: XRToolsPlayerBody = $PlayerBody
@onready var color_rect: ColorRect = $CanvasLayer/Control/ColorRect
@onready var left_function_pickup: XRToolsFunctionPickup = $LeftController/FunctionPickup

func _ready() -> void:
    Events.game_started.connect(_on_events_game_started)
    Events.game_over.connect(_on_events_game_over)

func is_wearing_spectral_mask() -> bool:
    if wearing_mask and wearing_mask.hand_scene_name == "spectral_hand":
        return true
    return false

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

func _on_events_game_started(_ar_enabled: bool) -> void:
    function_pointer.enabled = false
    function_pointer.hide()

func _on_events_game_over() -> void:
    if wearing_mask:
        wearing_mask.queue_free()
        for child in left_controller.get_children():
            if child is PlayerHand:
                child.queue_free()
    left_function_pickup.enabled = true
    var lhand = left_controller.find_child("LeftHand")
    lhand.show()
    function_pointer.enabled = true
    function_pointer.show()

func _on_left_controller_recenter() -> void:
    recenter.emit()
    recenter_player()

func _on_right_controller_recenter() -> void:
    recenter.emit()
    recenter_player()

func set_mask_screen_shade(color: Color) -> void:
    color_rect.color = color

func put_on_mask(hand_scene_name: String):
    SoundFx.play("maskon", 1.0, -15.0)
    if hand_scene_name == "spectral_hand":
        Events.player_put_on_spectral_mask.emit()
    left_function_pickup.enabled = false
    var hand_scene: PackedScene = Utils.get_hand(hand_scene_name)
    var player_hand: PlayerHand = hand_scene.instantiate() as PlayerHand
    left_controller.add_child(player_hand)
    var lhand = left_controller.find_child("LeftHand")
    lhand.hide()

func take_off_mask(hand_scene_name: String):
    SoundFx.play("maskoff", 1.0, -15.0)
    if hand_scene_name == "spectral_hand":
        Events.player_took_off_spectral_mask.emit()
    left_function_pickup.enabled = true
    var lhand = left_controller.find_child("LeftHand")
    lhand.show()
    for child in left_controller.get_children():
        if child is PlayerHand:
            child.queue_free()

func _on_mask_detection_area_body_entered(body: Node3D) -> void:
    if wearing_mask:
        return

    if body is Mask:
        var mask = body as Mask
        wearing_mask = mask
        mask.reparent(xr_camera_3d)
        wearing_mask_camera_local_transform = wearing_mask.transform
        mask.hide()
        put_on_mask(mask.hand_scene_name)

func _on_function_pickup_left_controller_has_picked_up(what: Variant) -> void:
    left_controller.rumble_for(0.2)
    left_picked_up_object = what

func _on_function_pickup_right_controller_has_picked_up(what: Variant) -> void:
    right_controller.rumble_for(0.2)
    right_picked_up_object = what

func _on_function_pickup_left_has_dropped() -> void:
    right_controller.rumble_for(0.1)
    left_picked_up_object = null

func _on_function_pickup_right_has_dropped() -> void:
    right_controller.rumble_for(0.1)
    right_picked_up_object = null

func _on_mask_detection_area_area_entered(area: Area3D) -> void:
    if not wearing_mask:
        return
    var controller = area.get_parent() as XRControllerComponent
    if controller:
        controller.rumble_for(0.1)
    wearing_mask.transform = wearing_mask_camera_local_transform
    wearing_mask.show()

func _on_mask_detection_area_area_exited(area: Area3D) -> void:
    if not wearing_mask:
        return

    var controller = area.get_parent() as XRControllerComponent
    if controller == left_controller and left_picked_up_object is Mask:
        take_off_mask(left_picked_up_object.hand_scene_name)
        var game: Game = get_tree().current_scene as Game
        wearing_mask.reparent(game.current_scene)
        wearing_mask = null
        return
    elif controller == right_controller and right_picked_up_object is Mask:
        take_off_mask(right_picked_up_object.hand_scene_name)
        var game: Game = get_tree().current_scene as Game
        wearing_mask.reparent(game.current_scene)
        wearing_mask = null
        return

    wearing_mask.hide()
