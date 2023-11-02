extends StaticBody2D
var Spawn1 = true # можно призывать роботов
var dir = 0
var shield = 10 #сколько урона получает база от воздействия
var health = 1000
var health_max = 1000
var race  = 10
var uid = 1
var speed = 2
var timer = 0
var faction = 10 # фракция
var parent_id = 0
var new_faction #фракция того игрока, который сейчас захватывает базу
var capture_count = 0 #таймер захвата базы
var capturing = false #идёт захват базы?
var resource = 0
var dead_now = false #программа остановлена - "мертва"
var playing_capture2 = false # играет звук захвата базы?
var playing_capture = 2 # играет звук захвата базы?
var uuid = 0 # уникальный номер объекта в игровом мире
func _ready():
	if not get_tree().is_network_server():	
		$SpawnTimer.start(10)
		if faction == Global.player_race1:
			$Sprite2.visible = false
			$Sprite.visible = true	
	parent_id = self
	Global.count_base_human += 1
	get_node("/root/Map/UI/UI/STATS/Bases").text = "SERVERS: " + str(Global.count_base_human)			
	
#Функция для создания сцены корабля расы Рой:
func get_uid():
	return parent_id
func reduce_hp(a,race1):
	if not get_tree().is_network_server():	
		return
	if race1 != race:
		if race1 == Global.swarm_race:
				print("swarm attack base human")
				health -= 0.05 * health_max
		health -= shield
#		$HP_bar.text = str(health)	
		$HP_bar.value = int(health)	
		if health < 0:
				Network._send_Creature_Dead(self.name,Global.type_update_base_human)
				dead_now = true
				$DieTimer.start(1)
				
		$HP_bar.value = int(health)
		Network._send_Creature_Update_HP(int(health),self.name,Global.type_update_base_human)	
	return
	if race1 != race:
		health -= shield
		$HP_bar.value = int(health)	
		if health < 0:

			Global.count_base_human -= 1
			get_node("/root/Map/UI/UI/STATS/Bases").text = "SERVERS: " + str(Global.count_base_human)			
			queue_free()
func create_roy_ship():
	var ship = load("res://scenes/Robot/Robot0.tscn").instance()
	# задаем случайные координаты для корабля
	ship.position = Vector2(rand_range(-500, 500), rand_range(-500, 500))
#	print("Create ship Rooy")
#	print (ship.position)
	# добавляем корабль на сцену
	get_node("/root/Main").add_child(ship)
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
#		print("Create bullet base")
#		print (bullet.position)
	# иначе база не стреляет
	else:
		return
#Функция для получения ближайшей базы:

func get_closest_base(faction):
	var bases = []
	# ищем все базы на сцене
	for node in get_tree().get_nodes_in_group("bases"):
		if node.faction == faction:
			bases.append(node)
	# сортируем базы по расстоянию до корабля-робота
#	bases.sort_custom(lambda x: robot.position.distance_to(x.position))
	# возвращаем ближайшую базу
	if bases.size() > 0:
		return bases[0]
	else:
		return null
#Функция для обновления состояния базы:

func _process2(delta):
	# база создает корабли и стреляет
	create_robot(self.faction,Vector2(0,0),"robot")
	shoot(self)
func get_closest_target(faction):
	var targets = []
	# ищем все базы и корабли-роботы на сцене
	for node in get_tree().get_nodes_in_group("bases"):
		if node.faction != faction:
			targets.append(node)
	for node in get_tree().get_nodes_in_group("robots"):
		if node.get_faction() != faction:
			targets.append(node)
	for node in get_tree().get_nodes_in_group("creatures"):
		if node.get_faction() != faction:
			targets.append(node)
	for node in get_tree().get_nodes_in_group("player"):
		if node.get_faction() != faction:
			targets.append(node)
	# сортируем цели по расстоянию до корабля расы Рой
#	targets.sort_custom(lambda x: ship.position.distance_to(x.position))
	# возвращаем ближайшую цель
	if targets.size() > 0:
		return targets[0]
	else:
		return null
func get_faction():
	return faction

#Функция для создания корабля-робота:

sync func create_robot(faction,pos,robot_name):
	if not get_tree().is_network_server():
		create_robot1(faction,pos,robot_name)
func create_robot1(faction,pos,robot_name):				
		# если на сцене уже есть достаточное количество кораблей-роботов, то база не создает новые
#		if get_tree().get_nodes_in_group("robots").size() >= 25:
		var count = get_tree().get_nodes_in_group("robots").size() 
#		print ("server robots:")
#		print(count)
		if count >= 70:	
			return
		var robot = load("res://scenes/Robot/Robot1.tscn").instance()
		robot.faction = 2 #faction
		robot.health = 100
		robot.energy = 100
		robot.speed = 230
		robot.state = "patrolling"
		robot.position = Vector2(rand_range(-1500, 1500), rand_range(-1500, 1500))
		robot.name = robot_name
#		print("1 server  pos")
#		print (pos)
	#	get_node("/root/Main").
		add_child(robot)
#		print("Create ship1 blue")
#		print (robot.position)
		Network.new_creatures_data()		
sync func create_special_robot(faction,pos,robot_name):
	if not get_tree().is_network_server():
		create_special_robot1(faction,pos,robot_name)
func create_special_robot1(faction,pos,robot_name):
#		if get_tree().get_nodes_in_group("creatures").size() >= 25:
		var count = get_tree().get_nodes_in_group("robots").size() 
#		print ("server special robots:")
#		print(count)
		if count >= 25:	
			return	
		var special_robot = load("res://scenes/Mobs/Creature.tscn").instance()
		special_robot.faction = faction
		special_robot.health = 100
		special_robot.energy = 100
		special_robot.speed = 200
		special_robot.state = "attacking"
		special_robot.name = robot_name
	#	get_node("/root/Main").
		special_robot.position = pos #Vector2(rand_range(-1500, 1500), rand_range(-1500, 1500))
#		print("1 server special pos")
#		print (pos)
		add_child(special_robot)
#		print("Create ship12 blue")
#		print (special_robot.position)
		Network.new_creatures_data()
#Функция для обновления состояния базы:

func a_process(delta):
	if get_tree().is_network_server():	
		random_movement(delta,self)

		# каждые 25 секунд база создает обычного и особого корабля-робота
		if timer < 5:
			timer += delta
#			random_movement(delta,self)
		else:
			timer = 0
			var robot_name = "Creature_" + str(int(rand_range(1000, 1000000)))
			var pos = Vector2(rand_range(-1500, 1500), rand_range(-1500, 1500))	
			create_special_robot1(self.faction,pos,robot_name)
#			print("server special pos")
#			print (pos)
			Network.create_special_robot(self.faction,pos,0,robot_name)
#			rpc("create_special_robot",self.faction,pos)
			# база создает корабли и стреляет
		# каждые 25 секунд база создает особого корабля-робота
			pos = Vector2(rand_range(-1500, 1500), rand_range(-1500, 1500))	
			robot_name = "Creature_" + str(int(rand_range(1000, 1000000)))						
#			create_robot1(self.faction,pos,robot_name)
#			print("server pos")
#			print (pos)			
#			Network.create_robot(self.faction,pos,0,robot_name)			
#			rpc("create_robot",self.faction,pos)			
	#		shoot(self)
#	else:
#		shoot(self)		
func random_movement(delta,robot):
	var target_position = robot.position + Vector2(rand_range(-750, 750), rand_range(-450, 450))
#	robot.
	move_to(delta,target_position)
func move_to(delta,pl):
#		var pl = self.position	
		var distance = position.distance_to(pl)
		if distance < 650 and distance > 64:
			var direction = (pl - position).normalized()
			var velocity = direction * speed * delta
			position += velocity


func _on_SpawnTimer_timeout():
	if playing_capture2 == true:
		playing_capture -= 1
		if playing_capture < 1:
			playing_capture2 = false
			playing_capture = 2
			$Play/Play2.stream_pause()
			var erase = $Play/Play2
			$Play.remove_child(erase)
	Spawn_Action_server(2)
	health += 10
	if health > health_max:
		health = health_max
	$HP_bar.value = int(health)	
	resource += 10
	$Resource2.text = str(resource)	
#Производим роботы-корабли
func Spawn_Action_server(a):
#	if Spawn1 == true and (health > 950):
	if not get_tree().is_network_server():		
#		Spawn1 = false
#		$SpawnTimer.start(3)
		Network.create_bullet_player(self.faction,global_position-Vector2(rand_range(-250, 250), rand_range(-250, 250)),0,a)	 # 1 - bullet	

func _on_CaptureTimer_timeout():
	start_capture()


func _on_Base_Human_area_entered(area):
	if "Player" in area.name: #.is_in_group("player"):
		var f = area.get_faction()
		if f == faction:
			return
		else:	
			capturing = true
			new_faction = f
#			$Resource.text = str(faction)
#			return
			create_timer_capture(new_faction)
func create_timer_capture(new_faction):
#	var timer = Timer.new()
#	timer.set_wait_time(1)
#	timer.set_one_shot(true)
#	timer.connect("timeout", self, "start_capture")
	$CaptureTimer.start(1)	
#	get_parent().add_child(timer)
func start_capture():
	if capturing == true and capture_count < 10:
		capture_count +=1
		$Resource.text = "Search Acess: " + str(capture_count)
		$Capture_bar.visible =true
		$Capture_bar.value = int(capture_count)
		
	else:
		capturing = false
		capture_count = 0		
		faction = new_faction # теперь база получает новую фракцию игрока, который захватил её
		$Capture_bar.visible = false
		$Capture_bar.value = 0				
		$Resource.text = str(faction)
		playing_capture2 = true
		playing_capture = 2	
		$Play/Play2.play(0.0)
		$Sprite2.visible = false
		$Sprite.visible = true	
func _on_Base_Human_area_exited(area):
	if "Player" in area.name:
		capturing = false
		capture_count = 0
		$Resource.text =  str(faction)
		$Capture_bar.visible = false
		$Capture_bar.value = 0
		if faction != Global.player_race1:			
			$Sprite2.visible = true
			$Sprite.visible = false	

func _on_DieTimer_timeout():
	Global.count_base_human -=1
	get_node("/root/Map/UI/UI/STATS/Bases").text = "SERVERS: " + str(Global.count_base_human)			
	if get_tree().is_network_server():
		var Creatures_Node = get_node("/root/Map/Qurrent_Location/Creatures")
		Creatures_Node.Remove_Creatures(self)
		queue_free()
func dead():
#	print("creatures_dead=======================================")
#	print(self.name)		
	if not get_tree().is_network_server():
		Global.count_base_human -= 1
		var a = get_node("/root/Map/UI/UI/STATS/Bases")		
		a.text = "SERVERS: " + str(Global.count_base_human)			
		var Creatures_Node = get_node("/root/Map/Qurrent_Location/Creatures")
		Creatures_Node.Remove_Creatures1(self)	
		queue_free()						
func update_hp(health_new):
#	print("new_health=======================================")
#	print(self.name)
#	print(health_new)	
	if not get_tree().is_network_server():
		health = health_new
		$HP_bar.value = int(health_new)	
