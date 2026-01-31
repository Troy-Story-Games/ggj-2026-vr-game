extends PlayerHand
class_name HammerHand

func _on_area_3d_body_entered(body: Node3D) -> void:
    if body is Enemy:
        print("Hit enemy. RAGDOLL!")
        var enemy = body as Enemy
        enemy.ragdoll = true
        enemy.freeze = false
