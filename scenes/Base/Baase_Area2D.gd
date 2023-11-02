extends Area2D


var faction = 1 # фракция
var race = 4
# Called when the node enters the scene tree for the first time.
func _ready():
	faction=get_parent().faction
	pass # Replace with function body.

func get_faction():
	return faction

func reduce_hp(a,race1):
	if race1 != race:
		get_parent().reduce_hp(a,race1)
