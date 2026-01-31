extends XRToolsPickable
class_name Enemy

const PoofParticles = preload("res://game/fx/poof_particles.tscn")

@export var health: float = 100.0
@export var speed: float = 1.0
@export var arrival_safe_distance: float = 0.1

var direction: Vector3 = Vector3.ZERO
var ragdoll: bool = false
var target_pos: Vector3 = Vector3.ZERO
var target_set: bool = false
var velocity: Vector3
var physical_bone_simulator_3d: PhysicalBoneSimulator3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var enemy: Node3D = $Enemy
@onready var construction_enemy: Node3D = $ConstructionEnemy

func _ready():
    freeze = true
    physical_bone_simulator_3d = construction_enemy.find_child("PhysicalBoneSimulator3D") as PhysicalBoneSimulator3D

func set_target(target_transform: Transform3D):
    target_pos = target_transform.origin
    target_set = true

func _process(_delta):
    if ragdoll or not target_set:
        return
    if not animation_player.is_playing():
        animation_player.play("walk")

func _physics_process(delta):
    if ragdoll or not target_set:
        return  # Don't need to move if we're ragdoll or we don't have a target
    if global_transform.origin.distance_to(target_pos) <= arrival_safe_distance:
        return  # We have arrived (TODO: Attack? Build?)

    direction = global_transform.origin.direction_to(target_pos).normalized()
    direction.y = 0  # Only need the x,z direction
    velocity = (direction * speed) * delta
    look_at(global_transform.origin - direction, Vector3.UP)
    move_and_collide(velocity, false)

func _on_grabbed(_pickable: Variant, _by: Variant) -> void:
    ragdoll = true

func _on_dropped(_pickable: Variant) -> void:
    print("Dropped")
