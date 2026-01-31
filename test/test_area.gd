extends Node3D

@onready var enemy: Node3D = $Enemy

func _ready() -> void:
    var phys_bones = enemy.find_child("PhysicalBoneSimulator3D") as PhysicalBoneSimulator3D
    phys_bones.physical_bones_start_simulation()
