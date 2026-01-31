extends XRToolsPickable
class_name Enemy

const PoofParticles = preload("res://game/fx/poof_particles.tscn")

@export var health: float = 100.0
@export var speed: float = 1.0

var direction: Vector3 = Vector3.ZERO
var ragdoll: bool = false
var target_pos: Vector3 = Vector3.ZERO
var target_set: bool = false
var velocity: Vector3

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var enemy_model: Node3D = $EnemyModel

func _ready():
    freeze = true

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

    direction = global_transform.origin.direction_to(target_pos).normalized()
    direction.y = 0  # Only need the x,z direction
    velocity = (direction * speed) * delta
    look_at(global_transform.origin - direction, Vector3.UP)
    move_and_collide(velocity, false)

func _on_grabbed(pickable: Variant, by: Variant) -> void:
    print("Grabbed by ", by)
    ragdoll = true
    var skel = enemy_model.find_child("Skeleton3D") as Skeleton3D
    skel.physical_bones_start_simulation()

func _on_dropped(pickable: Variant) -> void:
    print("Dropped")
    #set_deferred("freeze", false)
    #apply_central_impulse(Vector3.UP * 0.1)
