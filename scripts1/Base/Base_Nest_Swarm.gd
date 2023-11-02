extends StaticBody2D
var shield = 10
var health = 100
var health_max = 100
var race  = 1
var uid = 1
var speed = 2
var timer = 0
var faction = 9 # фракция
var parent_id = 0
var Spawn1 = true # можно призывать роботов
var level = 0
var resource = 0
var dead_now = false #программа остановлена - "мертва"
var uuid = 0 # уникальный номер объекта в игровом мире
func _ready():
	if get_tree().is_network_server():
#		Spawn_Action_server(4)	
		$SpawnTimer.start(200)	
	parent_id = self
#	set_process(false)
	set_process_input(false)
	set_process(false)
	set_physics_process(false)
	$LevelTimer.start(5)
	$HP_bar.text = str(health)
	$HP_bar2.value = int(health)	
	Global.count_base_swarm += 1	
	var a = get_node("/root/Map/UI/UI/STATS/BasesSwarm")		
	a.text = "S-server: " + str(Global.count_base_swarm)					
#Функция для создания сцены корабля расы Рой:
func get_uid():
	return parent_id
func reduce_hp(a,race1):
	if not get_tree().is_network_server():	
		return
	if race1 != race:
		health -= shield
		$HP_bar.text = str(health)	
		$HP_bar2.value = int(health)	
		if health < 0:
				Network._send_Creature_Dead(self.name,Global.type_update_base_swarm)
				dead_now = true
				$DieTimer.start(1)
				
		$HP_bar.text = str(health)
		Network._send_Creature_Update_HP(int(health),self.name,Global.type_update_base_swarm)	
	return		
	if race1 != race:
		health -= shield
		$HP_bar.text = str(health)
			
		if health < 0:

	
			queue_free()
func dead():
#	print("creatures_dead=======================================")
#	print(self.name)		
	if not get_tree().is_network_server():
		Global.count_base_swarm -= 1
		var a = get_node("/root/Map/UI/UI/STATS/BasesSwarm")		
		a.text = "S-server: " + str(Global.count_base_swarm)			
		var Creatures_Node = get_node("/root/Map/Qurrent_Location/Creatures")
		Creatures_Node.Remove_Creatures1(self)	
		queue_free()			
func update_hp(health_new):
#	print("new_health=======================================")
#	print(self.name)
#	print(health_new)	
	if not get_tree().is_network_server():
		health = health_new
		$HP_bar.text = str(health_new)
		$HP_bar2.value = int(health)		
#Функция для стрельбы базы:

func shoot(base):
	var target = get_closest_target(base.faction)
	# если цель не найдена, то база не стреляет
	if target == null:
		return
	# вычисляем расстояние до цели
	var distance = base.position.distance_to(target.position)
	# если расстояние меньше 500, то база стреляет
	if distance < 500:
		var bullet = load("res://scenes/Bullet/Bullet.tscn").instance()
		bullet.position = base.position
		bullet.rotation = base.position.angle_to(target.position)
#		get_node("/root/Main").
		add_child(bullet)
		print("Create bullet base")
		print (bullet.position)
	# иначе база не стреляет
	else:
		return
#Функция для получения ближайшей базы:

func get_closest_base(faction):
	var bases = []
	# ищем всех  на сцене
	for node in get_tree().get_nodes_in_group("bases"):
		if node.faction != faction:
			bases.append(node)
	# сортируем базы по расстоянию до корабля-робота
#	bases.sort_custom(lambda x: robot.position.distance_to(x.position))
	# возвращаем ближайшего 
	if bases.size() > 0:
		return bases[0]
	else:
		return null
#Функция для обновления состояния базы:

func _process2(delta):
	# база создает корабли и стреляет
	create_robot(self.faction)
	shoot(self)
func get_closest_target(faction):
	var targets = []
	# ищем все базы и корабли-роботы на сцене
	for node in get_tree().get_nodes_in_group("player"):
		if node.faction != faction:
			targets.append(node)
	for node in get_tree().get_nodes_in_group("robot_human"):
		if node.get_faction() != faction:
			targets.append(node)
	for node in get_tree().get_nodes_in_group("creatures"):
		if node.get_faction() != faction:
			targets.append(node)			
	# сортируем цели по расстоянию до корабля расы Рой
#	targets.sort_custom(lambda x: ship.position.distance_to(x.position))
	# возвращаем ближайшую цель
	if targets.size() > 0:
		return targets[0]
	else:
		return null


#Функция для создания корабля-робота:

func create_robot(faction):
	# если на сцене уже есть достаточное количество кораблей-роботов, то база не создает новые
	if get_tree().get_nodes_in_group("robots").size() >= 10:
		return
	var robot = load("res://scenes/Robot/Robot0.tscn").instance()
	robot.faction = 2 #faction
	robot.health = 100
	robot.energy = 100
	robot.speed = 230
	robot.state = "patrolling"
	robot.position = Vector2(rand_range(-1500, 1500), rand_range(-1500, 1500))
#	get_node("/root/Main").
	add_child(robot)
#	print("Create ship1 blue")
#	print (robot.position)		
func create_special_robot(faction):
	var special_robot = load("res://scenes/Mobs/Creature.tscn").instance()
	special_robot.faction = faction
	special_robot.health = 100
	special_robot.energy = 100
	special_robot.speed = 200
	special_robot.state = "attacking"
#	get_node("/root/Main").
	special_robot.position = Vector2(rand_range(-1500, 1500), rand_range(-1500, 1500))
	add_child(special_robot)
#	print("Create ship12 blue")
#	print (special_robot.position)
#Функция для обновления состояния базы:

func _process(delta):
	random_movement(delta,self)
	# каждые 20 секунд база создает особого корабля-робота
	if timer < 1:
		timer += delta*5
		random_movement(delta,self)
	else:
		timer = 0
#		create_special_robot(self.faction)

		# база создает корабли и стреляет
#		create_robot(self.faction)
		shoot(self)		
func random_movement(delta,robot):
	var target_position = robot.position + Vector2(rand_range(-750, 750), rand_range(-450, 450))
#	robot.
	move_to(delta,target_position)
func move_to(delta,pl):
#		var pl = self.position	
		var distance = position.distance_to(pl)
		if distance < 650 and distance > 16:
			var direction = (pl - position).normalized()
			var velocity = direction * speed * delta * 10
			position += velocity
func Spawn_Action_server(a):
	if health > 0.35 * health_max:
		if get_tree().is_network_server():		

			Network.create_bullet_player0(self.faction,global_position-Vector2(rand_range(-250, 250), rand_range(-250, 250)),0,a)	 # 4 - robot-roy	


func _on_SpawnTimer_timeout():
	Spawn_Action_server(5)
	health += 0.05 * health_max
	if health > health_max:
		health = health_max
	$HP_bar.text = str(health)	
	resource += 100
	$Resource.text = str(resource)		
func update_level():
	if not get_tree().is_network_server() and level < 10:
		level +=1
		$SpawnTimer.start(90/level)
		health_max *= 3			
		health = health_max
		$HP_bar.text = str(health)	
		if level == 2:
			$Sprite.visible = false
			$Sprite2.visible = true
			health = 1000
			health_max = 1000
		if level == 4:
			$Sprite2.visible = false
			$Sprite3.visible = true
			health = 10000
			health_max = 10000			
		if level == 6:
			$Sprite3.visible = false
			$Sprite4.visible = true
			health = 100000
			health_max = 100000
			$LevelTimer.start(300)			
		if level == 8:
			$Sprite4.visible = false
			$Sprite10.visible = true
			health = 1000000
			health_max = 1000000
			$LevelTimer.start(600)	
	$HP_bar2.max_value = int(health_max)	
	$HP_bar2.value = int(health)							
	return level


func _on_LevelTimer_timeout():
	update_level()


func _on_DieTimer_timeout():
	Global.count_base_swarm +=1
	get_node("/root/Map/UI/UI/STATS/BasesSwarm").text = "S-server: " + str(Global.count_base_swarm)			
	if get_tree().is_network_server():
		var Creatures_Node = get_node("/root/Map/Qurrent_Location/Creatures")
		Creatures_Node.Remove_Creatures(self)
		queue_free()			
