extends StaticBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var level = int(rand_range(0,5))
	update_level(level)
func update_level(level):
	if not get_tree().is_network_server():
		if level == 1:
			$Sprite.visible = false
			$Sprite2.visible = true
		if level == 2:
			$Sprite.visible = false
			$Sprite3.visible = true
		if level == 3:
			$Sprite.visible = false
			$Sprite4.visible = true
		if level == 4:
			$Sprite.visible = false
			$Sprite10.visible = true	
