extends RigidBody2D


var faction = 6 # фракция
var uid = 6
var race1 = 6
var damage =  500
#func _ready():
#	uid = get_uid()
#	race1 = get_parent().get_race()
func get_uid():
	return uid
#	get_parent().get_uid()
func reduce_hp(a,race):
	return 0
#	get_parent().reduce_hp(a,race)


func _on_Area2D_area_entered(body):
	if body.has_method("reduce_hp"):
			body.reduce_hp(damage,race1)
