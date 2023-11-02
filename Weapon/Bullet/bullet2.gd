extends Node2D
var faction = 0 # фракция
var damaged = false
var damage = 10
var dir = 0
var bullet_speed = 10
var attack = 10
var parent_id = 0
var race = 3
var race1 = 3
func _process(delta):
	var move_dir = Vector2(1,0).rotated(dir)
	global_position += (move_dir * bullet_speed)
	pass


func _on_VisibilityNotifier2D_screen_exited():
	return
	self.remove_child($Area2D)
	queue_free()


func set_uid(race2,id):
	parent_id = id
	race = race2
func set_damage(dmg):
	damage = dmg
func get_race():
	return race


func _ready():
	$DieTimer.start(2)
#	set_damage(10)	
#	add_to_group(GlobalData.damage_group)													
	set_damage(attack)
#func _on_bullet2_area_entered(area):
func a_on_Area2D_area_entered(area):		
#func enemyHit(area: Area2D):
#	if not damaged and get_overlapping_bodies() != []:
#		for i in get_overlapping_bodies():
#			if i in get_tree().get_nodes_in_group(GlobalData.enemy_group):
#				i.reduce_hp(damage)
#		damaged = true
#	if area == parent_id:
#		return
	if area.has_method("reduce_hp"):

			area.reduce_hp(damage,race) #damage)
			return	 

	area.queue_free()
func reduce_hp(_val):
	return 0

func get_uid():
	return parent_id
func _on_DieTimer_timeout():
	self.remove_child($Area2D)
	queue_free()


func _on_Area2D_area_entered(area):
	a_on_Area2D_area_entered(area)
