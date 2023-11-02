extends Area2D

var uid = 0
var race1 = 0
func _ready():
	uid = get_parent().get_uid()
	race1 = get_parent().get_race()	
func get_uid():
	get_parent().get_uid()
func reduce_hp1(a, uid):
	if Global.HardMode == false and uid != race1:
		get_parent().reduce_hp(a)
func reduce_hp(a, uid):
	if get_tree().is_network_server():	
		if Global.HardMode == false and uid != race1:
			get_parent().reduce_hp(a,uid)
func rotate_to_target(target):
	look_at(target)
