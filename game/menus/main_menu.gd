extends CanvasLayer
class_name MainMenu

@onready var bg_floor: Node = $"../../../StaticBody3D/Setting_Floor"
func _ready() -> void:
	Music.play("main_menu")

func _on_play_button_pressed() -> void:
	Events.game_started.emit()

func _on_exit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

func _on_ar_on_pressed() -> void:
	bg_floor.hide()

func _on_ar_off_pressed() -> void:
	bg_floor.show()
