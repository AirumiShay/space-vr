extends Area2D

var uid = 0
var race1 = 0
func _ready():
	uid = get_uid()
	
func get_uid():
	get_parent().get_uid()
func reduce_hp(a,race1):
	get_parent().reduce_hp(a)
