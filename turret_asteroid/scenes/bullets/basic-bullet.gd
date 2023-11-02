extends RigidBody2D

func Cleanup():
	Signals.emit_signal("BulletImpact", global_position)
	queue_free()
	
func _on_BasicBullet_body_entered(body):
	if body.is_in_group("Potato"):
		Cleanup()

func _on_CleanupTimer_timeout():
	Cleanup()
