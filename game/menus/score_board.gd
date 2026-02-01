extends CanvasLayer
class_name ScoreBoard

var current_score: int = 0 : set = _set_current_score

@onready var score: Label = $Control2/Control/VBoxContainer/Score

func _ready() -> void:
	Events.enemy_died.connect(_on_enemy_died)
	current_score = 0

func _on_enemy_died():
	current_score += 10

func _set_current_score(value: int) -> void:
	current_score = value
	score.text = str(current_score)
