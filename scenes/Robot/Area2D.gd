extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var faction = 10 # фракция
var race = 10
# Called when the node enters the scene tree for the first time.
func _ready():
	faction=get_parent().faction
	pass # Replace with function body.

func get_faction():
	return faction
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func reduce_hp(a,race1):
	if race1 != race:
		get_parent().reduce_hp(a,race1)
