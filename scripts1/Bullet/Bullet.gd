extends KinematicBody2D

var dir = 0
var bullet_speed = 15
var attack = 10
var damage = 10
var parent_id = 0 # id  родителя, который создал этот снаряд
var race = 2
var faction = 0 # фракция
func _process(delta):
	var move_dir = Vector2(1,0).rotated(dir)
	global_position += (move_dir * bullet_speed)
func _ready():
#	faction = race
	damage = attack
	$DieTimer.start(10) #время жизни снаряда
	$DebufTimer.start(1) #уменьшаем урон каждую секунду
func reduce_hp(_val):
	return 0
func get_race():
	return race

func get_uid():
	return parent_id
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
# Функция для обработки столкновений пуль с кораблями и базами:
func set_uid(race1,uid):
	parent_id = uid
	race = race1
func a_on_bullet_body_entered(body):
	# если пуля столкнулась с кораблем-роботом или базой
#	if body.is_in_group("robots") or body.is_in_group("bases"):
	if body.has_method("reduce_hp"):
#		if area != GlobalData.main_player_id:
			body.reduce_hp(damage,race) #damage)
#			return			
#		body.health -= 10
		# если корабль или база уничтожены, то удаляем их со сцены
#		if body.health <= 0:
#			body.queue_free()
	# удаляем пулю со сцены
#	queue_free()


func _on_DieTimer_timeout():
	queue_free()


func _on_DebufTimer_timeout():
	if damage > 1:
		damage -=1
#		$Play.stream_pause()
	else:
		queue_free()		


func _on_Area2D_area_entered(area):
	a_on_bullet_body_entered(area)
