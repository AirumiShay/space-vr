extends Node2D

func Play():
	$Particles2D.restart()

func Cleanup():
	queue_free()
	
func _on_CleanupTimer_timeout():
	Cleanup()
