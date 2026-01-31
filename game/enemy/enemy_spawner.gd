extends Marker3D
class_name EnemySpawner

const EnemyScene = preload("res://game/enemy/enemy.tscn")

@export var target: Marker3D

func _ready() -> void:
    assert(target, "Target needs to be set")
    spawn()

func spawn() -> void:
    var enemy = Utils.instance_scene_on_main(EnemyScene, global_transform) as Enemy
    enemy.set_target(target.global_transform)

func _on_timer_timeout() -> void:
    spawn()
