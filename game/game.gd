extends Node3D
class_name Game

var xr_interface: XRInterface
var current_scene: Node3D
var fade_tween: Tween

@onready var loading_screen = $LoadingScreen
@onready var player = $Player

func _ready():
    print_debug("********************** START **********************")

    xr_interface = XRServer.find_interface("OpenXR")
    if xr_interface and xr_interface.is_initialized():
        print_debug("OpenXR initialized successfully")

        # Turn off v-sync!
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

        # Change our main viewport to output to the HMD
        get_viewport().use_xr = true
    else:
        push_warning("OpenXR not initialised, please check if your headset is connected. If runnning simulator scene, ignore this.")
        player.activate_simulator()

    # Connect some global events
    Events.load_scene.connect(_on_load_scene)
    _on_load_scene("res://game/areas/world.tscn")

    # Per the docs, we don't want to call center_on_hmd until after a few frames
    await get_tree().create_timer(0.15).timeout

    # Recenter the scene around the player
    XRServer.center_on_hmd(XRServer.RESET_BUT_KEEP_TILT, true)


func _on_load_scene(path: String):
    print_debug("Changing scenes to ", path)
    $LoadingScreen.set_camera(player.get_xr_camera_3d())
    if current_scene:
        current_scene.queue_free()

    player.disable_player_body()
    loading_screen.get_node("ProgressBar").visible = false
    loading_screen.show()

    # Do the actual loading in a thread
    assert(ResourceLoader.load_threaded_request(path) == Error.OK, "Unable to start threaded load of path: " + path)
    while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
        await get_tree().create_timer(1).timeout

    var load_status = ResourceLoader.load_threaded_get_status(path)
    match load_status:
        ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
            push_error("FATAL: Invalid resource: ", path)
            get_tree().quit()
        ResourceLoader.THREAD_LOAD_FAILED:
            push_error("FATAL: Failed to load resource: ", path)
            get_tree().quit()

    var packed_scene = ResourceLoader.load_threaded_get(path) as PackedScene
    var scene = packed_scene.instantiate()
    add_child(scene)

    current_scene = scene
    _fade_to_visible()
    loading_screen.hide()
    player.enable_player_body()

func _fade_to_visible():
    # Fade to visible
    if fade_tween:
        fade_tween.kill()
    fade_tween = get_tree().create_tween()
    fade_tween.tween_method(_set_fade, 1.0, 0.0, 1.0)
    await fade_tween.finished

func _fade_to_black():
    # Fade to black
    if fade_tween:
        fade_tween.kill()
    fade_tween = get_tree().create_tween()
    fade_tween.tween_method(_set_fade, 0.0, 1.0, 1.0)
    await fade_tween.finished

func _set_fade(p_value : float):
    XRToolsFade.set_fade("staging", Color(0, 0, 0, p_value))
