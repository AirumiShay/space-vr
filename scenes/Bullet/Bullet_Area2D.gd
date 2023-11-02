extends Area2D

var uid = 0
var race1 = 3

func _ready():
	uid = get_uid()
	race1 = get_parent().get_race()
func get_uid():
	get_parent().get_uid()
func reduce_hp(a,race):
	get_parent().reduce_hp(a,race)
