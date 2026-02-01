extends Marker3D
class_name EnemySpawner

@export var rand_min: float = 2.5
@export var rand_max: float = 8.0
@export var factor : float = 1.0
@export var target: Marker3D
@export var spawn_type: String = "construction_enemy"
@export var enabled: bool = true

var enemy_scene: PackedScene

@onready var timer: Timer = $Timer

func _ready() -> void:
	assert(target, "Target needs to be set")
	enemy_scene = Utils.get_enemy(spawn_type)

func start_spawning():
	spawn()
	timer.start(randf_range(rand_min, rand_max))

func spawn() -> void:
	if not enabled:
		return
	var enemy = Utils.instance_scene_on_main(enemy_scene, global_transform) as Enemy
	enemy.enemy_type = spawn_type
	enemy.set_target(target.global_transform)

func _on_timer_timeout() -> void:
	spawn()
	timer.start(randf_range(rand_min, rand_max))
