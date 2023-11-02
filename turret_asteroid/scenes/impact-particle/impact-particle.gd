extends Node2D

func _ready():
	$Particles2D.emitting = true
	
func Cleanup():
	queue_free()

func _on_CleanupTimer_timeout():
	Cleanup()
