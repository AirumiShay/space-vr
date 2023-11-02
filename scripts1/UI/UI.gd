extends Node2D
signal Menu_pressed
signal Restart_pressed
signal BaseBuild_pressed


func _on_Menu_pressed():
	emit_signal("Menu_pressed")

func _on_Restart_pressed():
	emit_signal("Restart_pressed")

func _on_Base_Build_pressed():
	emit_signal("BaseBuild_pressed")
