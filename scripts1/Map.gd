extends YSort

onready var player = get_node("/root/Map/Player")	
var building_data = {}
var speed = 10
var Qurrent_Location
var Start_Location_0 = "res://scenes/Location/Start_Location_0.tscn"
var creatures = []		
var procent = 60
var number_mob = 0
var faction = 1 # фракция
var not_create_bullet = true
# Called when the node enters the scene tree for the first time.
func _ready():

	Global.player_id = self	
#	var Qurrent_Location = load(Start_Location_0).instance()	
	if not get_tree().is_network_server():
		$AudioStreamPlayer2D.play()
#		var Qurrent_Location = load(Start_Location_0).instance()			
		var Qurrent_Location = load(Start_Location_0).instance()
		get_node("Qurrent_Location").add_child(Qurrent_Location)		
#	else:
		Qurrent_Location = 1
		Network.load_location_from_server(0)
		print("Qurrent_Location")
		print(Qurrent_Location)
#		var location = Qurrent_Location.instance()	
		print ("start_location")
#		print (location)
	
#		create_base(faction)
#func _process(delta):
#	pass
	else:
		$Update_Build_Timer.start(5)
#		Global.player_id = self
		build_ready()
		not_create_bullet = false		
func build_ready():
	var b
	# заполняем словарь с данными о базах
	b = create_base(1,Vector2(100, 100),10000,2)	
	Global.building_data["building1"] = {"pos": Vector2(100, 100), "scene_id": b, "current_resources": 0, "max_resources": 1000,"faction":1, "health":1000}
	b = create_base(1,Vector2(500, 500),10000,2)	
	Global.building_data["building2"] = {"pos": Vector2(500, 500), "scene_id": b, "current_resources": 0, "max_resources": 3500,"faction":1, "health":1000}
	b = create_base(1,Vector2(1300, 100),10000,2)	
	Global.building_data["building3"] = {"pos": Vector2(1300, 100), "scene_id": b, "current_resources": 0, "max_resources": 10000,"faction":1, "health":1000}

	b = create_base(7,Vector2(100, -100),10000,2)	
	Global.building_data["building1"] = {"pos": Vector2(100, -100), "scene_id": b, "current_resources": 0, "max_resources": 1000,"faction":7, "health":1000}
	b = create_base(7,Vector2(500, -500),10000,2)	
	Global.building_data["building2"] = {"pos": Vector2(500, -500), "scene_id": b, "current_resources": 0, "max_resources": 3500,"faction":7, "health":1000}
	b = create_base(7,Vector2(1300, -100),10000,2)	
	Global.building_data["building3"] = {"pos": Vector2(1300, -100), "scene_id": b, "current_resources": 0, "max_resources": 10000,"faction":7, "health":1000}

	b = create_base(10,Vector2(-300, 100),1000,1)	
	Global.building_data["building1"] = {"pos": Vector2(-300, 100), "scene_id": b, "current_resources": 0, "max_resources": 1000,"faction":10, "health":1000}
	b = create_base(10,Vector2(-500, 500),1000,1)	
	Global.building_data["building2"] = {"pos": Vector2(-500, 500), "scene_id": b, "current_resources": 0, "max_resources": 3500,"faction":10, "health":1000}
	b = create_base(10,Vector2(-1500, 500),1000,1)	
	Global.building_data["building3"] = {"pos": Vector2(-1500, 100), "scene_id": b, "current_resources": 0, "max_resources": 10000,"faction":10, "health":1000}
	b = create_base(9,Vector2(-2500, -2500),100000,0)	
	Global.building_data["building3"] = {"pos": Vector2(-2500, -2500), "scene_id": b, "current_resources": 0, "max_resources": 10000,"faction":9, "health":1000000}

	var a = 10

	for i in range(0,9):
		randomize()
		var type = rand_range(0,6)
		var base_pos = Vector2(rand_range(-25000, 25000), rand_range(-25000, 25000))
		b = create_base(10,base_pos,type,1+(rand_range(0,100)))
		Global.building_data["building"+str(i+a)] = {"pos": base_pos, "scene_id": b, "current_resources": 0, "max_resources": 100000,"faction":10, "health":1000}

	Global.creature_data2["Bases_List"] = Global.building_data
#	Network.new_creatures_data()
#	Network.new_bases_data()
	_load_building_creatures_from_server()					
	# запускаем таймер для обновления данных о зданиях
	var timer = $Update_Build_Timer		
func create_base(faction,base_pos,type,health):
	var base
	base = load("res://scenes/Base/Base_1.tscn").instance()	
	if type == 0:
		base = load("res://scenes/Base/Base_0.tscn").instance()
	if type == 1:
		base = load("res://scenes/Base/Base_1.tscn").instance()
	if type == 2:
		base = load("res://scenes/Mobs/Building.tscn").instance()
	if type == 3:
		base = load("res://scenes/Base/Base_Nest.tscn").instance()
	if type == 4:
		base = load("res://scenes/Asteroid/Asteroids.tscn").instance()
		base.global_position = base_pos	
	# добавляем базу на сцену
		$Qurrent_Location/Asteroids.add_child(base)
		return		base		
	if type == 5:
		base = load("res://scenes/Asteroid/Big_asteroid.tscn").instance()
		base.global_position = base_pos	
	# добавляем базу на сцену
		$Qurrent_Location/Asteroids.add_child(base)
		return	base
	base.global_position = base_pos	
	base.faction = faction
	base.health = health
		
	# задаем случайные координаты для базы

#	var base_pos = Vector2(rand_range(-500, 500), rand_range(-500, 500))
	base.global_position = base_pos	
	# добавляем базу на сцену
#	get_tree().get_node("/root/Main").
	$Qurrent_Location/BaseHuman.add_child(base)
	return 	base		
		
func a_new_list_creature():
	if get_tree().is_network_server():
		var creatures = []			
		var creature_nodes = get_node("/root/Map/Qurrent_Location/Creatures").get_children()
		for node in creature_nodes:
			if node.has_method("get_creature_data"):
				creatures.append(node)
		Global.creatures = creatures	
# добавляем выстрел-снаряд на сцену
func create_bullet_player1(faction,pos,rotation,type,uuid):
	var robot
	if type == 0:
		if not_create_bullet == true:
			return
		robot = load("res://Weapon/Bullet/bullet2.tscn").instance()
		robot.faction = faction
		robot.dir = rotation
		robot.rotation = rotation
		robot.global_position = pos
		add_child(robot)
		return		
	elif type == 1:
		if not_create_bullet == true:
			return
		robot = load("res://scenes/Bullet/Bullet.tscn").instance()
		robot.faction = faction
		robot.dir = rotation
		robot.rotation = rotation
		robot.global_position = pos
		add_child(robot)
		return
	elif type == 2:
		if Global.count_robot_human < 100:
			robot = load("res://scenes/Robot/Robot1.tscn").instance()
			robot.faction = faction
			robot.uuid = uuid			
			robot.global_position = pos
			$Qurrent_Location/RobotHuman.add_child(robot)
			Network.new_robot_human_data()	
			$UI/UI/STATS/Robots.text = "BOTS: " + str(Global.count_robot_human)
			return
		else:
			return
	elif type == 3:
		if Global.count_base_human < 75:
			robot = load("res://scenes/Base/Base_1.tscn").instance()
			robot.faction = faction
			robot.global_position = pos
			robot.uuid = uuid
#			var creatures  = {}
			$Qurrent_Location/BaseHuman.add_child(robot)
#			var node = robot
#			var item = {"name": node.name, "pos": node.global_position,"health": node.health, "faction":node.faction, "race": node.race,"scene_id": node, "current_resources": node.resource, "max_resources": 100000}
#			creatures[node.name] = item
#			Global.creature_data2["Bases_List"] = creatures
#			Network.new_bases_data()
#			$UI/UI/STATS/Bases.text = "SERVERS: " + str(Global.count_base_human)
		return									
	elif type == 4:
		if Global.count_robot_swarm < 125 : #Global.count_base_swarm*25:
			robot = load("res://scenes/Robot/Robot0.tscn").instance()
			robot.faction = faction
			robot.dir = rotation
			robot.uuid = uuid			
			robot.rotation = rotation
			robot.global_position = pos
			$Qurrent_Location/RobotRoy.add_child(robot)
			Network.new_robot_roy_data()
			return
		else:
			return		
	elif type == 5:
		if Global.count_robot_swarm < 75: #Global.count_base_swarm*50:
			robot = load("res://scenes/Robot/Robot_swarm.tscn").instance()
			robot.faction = faction
			robot.uuid = uuid
			robot.global_position = pos
			$Qurrent_Location/RobotRoy.add_child(robot)
			Network.new_robot_human_data()	
			$UI/UI/STATS/Swarm.text = "SWARM: " + str(Global.count_robot_swarm)
			return
		else:
			return		
	elif type == 6:
		if Global.count_base_swarm < 50:
			robot = load("res://scenes/Base/Base_Nest.tscn").instance()
			robot.faction = faction
			robot.global_position = pos
			robot.uuid = uuid
#			var creatures  = {}
			$Qurrent_Location/BaseSwarm.add_child(robot)
#			var node = robot
#			var item = {"name": node.name, "pos": node.global_position,"health": node.health, "faction":node.faction, "race": node.race}
#			creatures[node.name] = item
#			Global.creature_data2["Bases_List"] = creatures
#			Network.new_bases_data()
#			$UI/UI/STATS/BasesSwarm.text = "S-server: " + str(Global.count_base_swarm)	
# добавляем выстрел-снаряд на сцену
func create_bullet_player3(faction,pos,rotation):
		var robot = load("res://scenes/Bullet/Bullet.tscn").instance()
#		robot.position = pos
		robot.faction = faction
		robot.dir = rotation
		robot.rotation = rotation
		robot.global_position = pos
		add_child(robot)
		print("bullet3")	


#Функция для обновления состояния базы:

func _process(delta):
	if  get_tree().is_network_server():
			procent -=1
			if procent <0:
				procent = 2				
				update_mobs_position_and_stat(delta)

#				new_list_creature()
#				rpc("update_mobs_stats",Global.creatures)
	if Input.is_action_pressed("ui_cancel"):
		if not get_tree().is_network_server():
			if Global.player_live_status == false:
#		if is_network_master():
				Global.player_live_status == true
				var player_unique_id = get_tree().get_network_unique_id()			
	#			randomize()
	#			race = int(rand_range(10,10000))					
	#			Global.player_race = race
				#создаём повторно сцены персонажа игрока
				Network.add_new_player0(player_unique_id,Global.player_race1)
				yield(get_tree().create_timer(0.75), "timeout")
				Network.spawn_player(player_unique_id,Global.player_race1)
			else:
				return
		else:
			Global.player_live_status = false	
			get_tree().change_scene("res://Main.tscn")
func b_process(delta):
	if get_tree().is_network_server():
			
#		random_movement(delta,self)

		# каждые 25 секунд база создает обычного и особого корабля-робота

			var robot_name = "Creature_" + str(int(rand_range(1000, 1000000)))
			var pos = Vector2(rand_range(-1500, 1500), rand_range(-1500, 1500))	
			create_special_robot1(3,pos,0,robot_name)
#			print("server special pos")
#			print (pos)
			Network.create_special_robot(3,pos,0,robot_name)
#			rpc("create_special_robot",self.faction,pos)
			# база создает корабли и стреляет
		# каждые 25 секунд база создает особого корабля-робота
			pos = Vector2(rand_range(-1500, 1500), rand_range(-1500, 1500))	
			robot_name = "RobotHuman_" + str(int(rand_range(1000, 1000000)))						
			create_robot1(self.faction,pos,0,robot_name)
#			print("server pos")
#			print (pos)			
			Network.create_robot(self.faction,pos,0,robot_name)			
#			rpc("create_robot",self.faction,pos)			
	#		shoot(self)
#	else:
#		shoot(self)
#Функция для создания корабля-робота:

sync func create_robot(faction,pos,type,robot_name):
	if not get_tree().is_network_server():
		create_robot1(faction,pos,type,robot_name)
func create_robot1(faction,pos,type,robot_name):				
		# если на сцене уже есть достаточное количество кораблей-роботов, то база не создает новые
#		if get_tree().get_nodes_in_group("robots").size() >= 25:
		var count = get_tree().get_nodes_in_group("robots").size() 
#		print ("server robots:")
#		print(count)
		if count >= 125:	
			return
		var robot = load("res://scenes/Robot/Robot1.tscn").instance()
		robot.faction = faction
		robot.health = 100
		robot.energy = 100
		robot.speed = 230
		robot.state = "patrolling"
		robot.position = Vector2(rand_range(-1500, 1500), rand_range(-1500, 1500))
		robot.name = robot_name
#		print("1 server  pos")
#		print (pos)
	#	get_node("/root/Main").
#		add_child(robot)
		$Qurrent_Location/RobotHuman.add_child(robot)
#		print("Create ship1 blue")
#		print (robot.position)
		Network.new_creatures_data()		
sync func create_special_robot(faction,pos,type,robot_name):
	if not get_tree().is_network_server():
		create_special_robot1(faction,pos,type,robot_name)
func create_special_robot1(faction,pos,type,robot_name):
#		if get_tree().get_nodes_in_group("creatures").size() >= 25:
		var count = get_tree().get_nodes_in_group("creatures").size() 
#		print ("server special robots:")
#		print(count)
		if count >= 125:	
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
		$Qurrent_Location/Creatures.add_child(special_robot)
#		add_child(special_robot)
#		print("Create ship12 blue")
#		print (special_robot.position)
		Network.new_creatures_data()
func get_target_position(pos,faction,who):
	var player_nodes	
	if Global.player_stealth_off and who == 0 or who == 2:
		player_nodes = get_tree().get_nodes_in_group("player") #get_node("/root/Map").get_children()
		for pl in player_nodes:


				var faction_target = pl.faction
				var pl1 = pl.global_position
				var distance = pos.distance_to(pl1)

				if distance < 600:
			
					return [pl1,faction_target]
	if who == 0:
		player_nodes = get_tree().get_nodes_in_group("robot_human") #get_node("/root/Map").get_children()
	elif who == 1:
		player_nodes = get_tree().get_nodes_in_group("creatures") #get_node("/root/Map").get_children()
	elif who == 2:
		player_nodes = get_tree().get_nodes_in_group("robots") #get_node("/root/Map").get_children()

	else:
		return null	
	for pl in player_nodes:


				var faction_target = pl.faction
				var pl1 = pl.global_position
				var distance = pos.distance_to(pl1)

				if distance < 600:
			
					return  [pl1,faction_target]
	if who == 2:
		player_nodes = get_tree().get_nodes_in_group("robots") #get_node("/root/Map").get_children()
	else:
		return null	
	for pl in player_nodes:


				var faction_target = pl.faction
				var pl1 = pl.global_position
				var distance = pos.distance_to(pl1)

				if distance < 600:
			
					return  [pl1,faction_target]										
	return null						
func update_mobs_position_and_stat(delta):
#	create_list_all_unit(delta)	
#	return
	update_mobs_position_and_stat2(delta) # Мобы Creature преследуют игроков
	var creature_nodes = get_node("/root/Map/Qurrent_Location/Creatures").get_children()
	update_mobs_position_and_stat1(delta,creature_nodes,2)  # Мобы Creature преследуют мобов RobotHuman
#	creature_nodes = get_node("/root/Map/Qurrent_Location/Creatures").get_children()
#	update_mobs_position_and_stat1(delta,creature_nodes,0)  # Мобы Creature преследуют мобов RobotHuman

	creature_nodes = get_node("/root/Map/Qurrent_Location/RobotHuman").get_children()
	update_mobs_position_and_stat1(delta,creature_nodes,1)	# Мобы RobotHuman преследуют мобов Creature
func update_mobs_position_and_stat1(delta,creature_nodes,who):			
# Получить список всех мобов на сцене

#	var creature_nodes = get_node("/root/Map/Qurrent_Location/Creatures").get_children()

	# Обновить координаты и скорость каждого моба
	for creature in creature_nodes: #Global.creatures:
			var creature_data = creature.get_creature_data()
			var pos = creature_data["pos"]
			var faction1 = creature.faction
#		if Global.player_id != Vector2(0, 0):
			var result = get_target_position(pos,faction1,who)#Global.player_id.position

			if result != null:
				var pl = result[0]
				var faction_target = result[1]				

				var distance = pos.distance_to(pl)
				if distance < 600 and distance > 300:
					var direction = (pl - pos).normalized()
					var velocity = direction * creature.speed * delta
					pos += velocity
					creature.global_position += velocity
					creature_data["pos"] = pos
					creature.set_creature_data(creature_data)
		#			procent -=1
		#			if procent <0:
		#				procent = 2		
					rpc("update_mobs_stats_one_mob", creature.uuid, pos, velocity,pl)
				else:
					# Остановить моба и отправить rpc-вызов для обновления его скорости на клиентах
					creature_data["vel"] = Vector2.ZERO
					creature.set_creature_data(creature_data)
					rpc("update_mobs_stats_one_mob", creature.uuid, pos, Vector2.ZERO,pl)
#					var distance = pos.distance_to(pl)
#					print ("my faction")
#					print (faction1)
#					print ("target faction")
#					print (faction_target)
					if faction1 == faction_target:
						return
					if distance != 0:					
	#				if distance <= 300 and distance !=0 and faction != faction_target:
							creature.rotate_to_target(pl)
							var rotation1 = creature.get_rotate()
							var who1
							if who == 0:
								who1 = 0
							elif who == 1:
								who1 = 1
							_creature_shoot_to_target(creature.faction,creature.global_position,rotation1,who1)				
			else:
				# Остановить моба и отправить rpc-вызов для обновления его скорости на клиентах
				creature_data["vel"] = Vector2.ZERO
				creature.set_creature_data(creature_data)
				rpc("update_mobs_stats_one_mob", creature.uuid, pos, Vector2.ZERO, Vector2.ZERO) #pl)
func update_mobs_position_and_stat2(delta):				
# Получить список всех мобов  типа  Creatures на сцене

	var creature_nodes = get_node("/root/Map/Qurrent_Location/Creatures").get_children()

	# Обновить координаты и скорость каждого моба
	for creature in creature_nodes: #Global.creatures:
			var creature_data = creature.get_creature_data()
			var pos = creature_data["pos"]
#		if Global.player_id != Vector2(0, 0):
			var pl = Network.get_players_position(pos)#Global.player_id.position
			if pl != null:
#				pl = pl.position
				var distance = pos.distance_to(pl)
				if distance < 600 and distance > 300:
					var direction = (pl - pos).normalized()
					var velocity = direction * creature.speed * delta
					pos += velocity
					creature.position += velocity
					creature_data["pos"] = pos
					creature.set_creature_data(creature_data)

					rpc("update_mobs_stats_one_mob", creature.uuid, pos, velocity,pl)
				else:
					# Остановить моба и отправить rpc-вызов для обновления его скорости на клиентах
					creature_data["vel"] = Vector2.ZERO
					creature.set_creature_data(creature_data)
					rpc("update_mobs_stats_one_mob", creature.uuid, pos, Vector2.ZERO,pl)
#					var distance = pos.distance_to(pl)
					if distance <= 300:
						creature.rotate_to_target(pl)
						var rotation1 = creature.get_rotate()
#						print("Creature Path:")
#						print(creature.get_path())						
						_creature_shoot_to_target(creature.faction,creature.global_position,rotation1,0)				
			else:
				# Остановить моба и отправить rpc-вызов для обновления его скорости на клиентах
				creature_data["vel"] = Vector2.ZERO
				creature.set_creature_data(creature_data)
				rpc("update_mobs_stats_one_mob", creature.uuid, pos, Vector2.ZERO,pl)
#				print("Creature Path:")
#				print(creature.get_path())	
func _creature_shoot_to_target(faction,pos,rotation,type):
	Network.create_bullet_player0(faction,pos,rotation,type)
func create_list_all_unit(delta):
	var creature_nodes = get_node("/root/Map/Qurrent_Location/RobotHuman").get_children()
	var units = []
	var i = 0
	var pos = Vector2(0,0)
	var faction1 = 1
	var res
	for creature in creature_nodes: #Global.creatures:
		pos = creature.global_position
		faction1 = creature.faction
		res = [pos,faction1,creature,1]
#		print("res")
#		print(res)
#		print("faction creature")
#		print(faction1)		
#		units.append(res)
		i += 1
	creature_nodes = get_node("/root/Map/Qurrent_Location/Creatures").get_children()
	for creature in creature_nodes: #Global.creatures:
		pos = creature.global_position
		faction1 = creature.faction
		res = [pos,faction1,creature,0]
#		print("faction 2")
#		print(faction1)				
		units.append(res)	
	new_task_for_all_unit(units,delta)
func new_task_for_all_unit(units,delta):	
# Создаем список координат юнитов
#units = [(1, 2), (3, 4), ...]  # Замените ... на остальные координаты

# Создаем пустой список для хранения расстояний
	var distances = []
	var unit_x
	var unit_y
	var other_unit_x
	var other_unit_y
	var distance
	var a
	var b
	var who #тип вируса 0 или 1
# Перебираем каждый юнит
	for i in range(len(units)):
		var unit_distances = []  # Создаем список для хранения расстояний для текущего юнита
		a = units[i]
#		b = a[0]
		unit_x = a[0][0] # Получаем координаты текущего юнита
		unit_y = a[0][1] # Получаем координаты текущего юнита
#		print("unit x y")
#		print(unit_x, " ", unit_y)	
#		print("faction")
#		print(a[1])	
		who = a[3]
		
		# Перебираем остальные юниты
		for j in range(0, len(units)):
			b = units[j]
#			b = a[0]
#			other_unit_x, other_unit_y = units[j]  # Получаем координаты другого юнита
			other_unit_x = b[0][0] # Получаем координаты текущего юнита
			other_unit_y = b[0][1] # Получаем координаты текущего юнита	
#			print("other unit x y")
#			print(other_unit_x,  " ",other_unit_y)
#			print("faction 3")
#			print(b[1])	
#			if a[1]	== b[1]:
#				continue
			# Вычисляем расстояние между текущим юнитом и другим юнитом
			distance = sqrt(pow(unit_x - other_unit_x, 2) + pow(unit_y - other_unit_y, 2))
			if distance < 600:
				move_unit_to_target_and_attack(who,distance,Vector2(b[0][0],b[0][1]), Vector2(a[0][0],a[0][1]), a[2],delta,a[1],b[1])
				continue
			else:
				stop_this_unit(a[2],Vector2(a[0][0],a[0][1])) # id юнита и его координаты
			unit_distances.append(int(distance)) # Добавляем расстояние в список расстояний для текущего юнита
		
		distances.append(unit_distances)  # Добавляем список расстояний для текущего юнита в общий список

	# Выводим результат
#	for i in range(len(distances)):
#		print("Расстояния для юнита", i + 1, ":", distances[i])
	return distances
func move_unit_to_target_and_attack(who,distance,pl,pos,creature,delta,faction1,faction_target):
				var creature_data = creature.get_creature_data()
				var uuid = creature.uuid
				if distance < 600 and distance > 300:
					var direction = (pl - pos).normalized()
					var velocity = direction * creature.speed * delta
					pos += velocity
					creature.global_position += velocity
					creature_data = creature.get_creature_data()
					creature_data["pos"] = pos
					creature.set_creature_data(creature_data)
#					rpc("update_mobs_stats_one_mob", creature.get_path(), pos, velocity,pl)

					rpc("update_mobs_stats_one_mob", uuid, pos, velocity,pl)
				else:
					# Остановить моба и отправить rpc-вызов для обновления его скорости на клиентах
					creature_data["vel"] = Vector2.ZERO
					creature.set_creature_data(creature_data)
					rpc("update_mobs_stats_one_mob", creature.uuid, pos, Vector2.ZERO,pl)
#					var distance = pos.distance_to(pl)
#					print ("my faction")
#					print (faction1)
#					print ("target faction")
#					print (faction_target)
					if faction1 == faction_target:
						return
					if distance != 0:					
	#				if distance <= 300 and distance !=0 and faction != faction_target:
							creature.rotate_to_target(pl)
							var rotation1 = creature.get_rotate()
							var who1
							if who == 0:
								who1 = 0
							elif who == 1:
								who1 = 1
							_creature_shoot_to_target(creature.faction,creature.global_position,rotation1,who1)				
func stop_this_unit(creature,pos):
				var creature_data = creature.get_creature_data()
				var uuid = creature.uuid
				# Остановить моба и отправить rpc-вызов для обновления его скорости на клиентах
				creature_data["vel"] = Vector2.ZERO
				creature.set_creature_data(creature_data)
#				rpc("update_mobs_stats_one_mob", creature.get_path(), pos, Vector2.ZERO, Vector2.ZERO) #pl)
				rpc("update_mobs_stats_one_mob", uuid, pos, Vector2.ZERO, Vector2.ZERO) #pl)
		
# Функция, которая обновляет координаты и скорость моба на клиенте
remote func update_mobs_stats(creatures):
		Global.creatures = creatures
		for creature in creatures:
			update_mobs_stats_one_mob(creature.uuid, creature["pos"], creature["vel"], Global.player_id.position)			
remote func update_mobs_stats_one_mob(uuid, pos, vel, pl):
		var creature_nodes = get_node("/root/Map/Qurrent_Location/Creatures").get_children()
		for cn in creature_nodes:
			if cn.uuid == uuid:
				update_mobs_stats_one_mob1(cn, pos, vel, pl)		
func update_mobs_stats_one_mob1(node, pos, vel, pl):
		
#	print("Creature Path:")
#	print(path)		
#	var node = get_node(path)
#	print("Node ID:")	
#	print(node)
	if node != null and node.has_method("set_creature_data"):
		var data = node.get_creature_data()
		data["pos"] = pos
		data["vel"] = vel
		node.set_creature_data(data)
		if vel == Vector2.ZERO:
			return
#			print("mob idle")
#			print(pos)
			# Остановить моба
#			node.animation_state.travel("idle")
		else:
			node.global_position = pos + vel
			node.target_pos = pl
#			print("mob move")
#			print(pos)
			# Запустить анимацию движения моба
#			node.animation_state.travel("move")			

func build_ready1():
	# заполняем словарь с данными о зданиях
	Global.building_data["building1"] = {"pos": Vector2(100, 100), "scene_id": 1, "current_resources": 0, "max_resources": 100}
	Global.building_data["building2"] = {"pos": Vector2(500, 500), "scene_id": 2, "current_resources": 0, "max_resources": 350}
	Global.building_data["building3"] = {"pos": Vector2(1300, 100), "scene_id": 3, "current_resources": 0, "max_resources": 1000}
#	var Map = get_node("/root/Map")
#	Map.

	var pos_base_1 = create_base0(1)
	Global.building_data["building4"] = {"pos": pos_base_1, "scene_id": 4, "current_resources": 0, "max_resources": 1000}
	var pos_base_2 = create_base0(2)
	Global.building_data["building5"] = {"pos": pos_base_2, "scene_id": 4, "current_resources": 0, "max_resources": 1000}
	var pos_base_3 = create_base0(3)
	Global.building_data["building6"] = {"pos": pos_base_3, "scene_id": 4, "current_resources": 0, "max_resources": 1000}
	var pos_base_4 = create_base0(4)
	Global.building_data["building7"] = {"pos": pos_base_4, "scene_id": 4, "current_resources": 0, "max_resources": 1000}

	_load_building_creatures_from_server()
	Network.new_creatures_data()				
	# запускаем таймер для обновления данных о зданиях
	var timer = $Update_Build_Timer  #.new()
#	timer.set_wait_time(60) # обновляем данные каждую секунду
#	timer.set_one_shot(false)
#	timer.connect("timeout", self, "_on_timer_timeout")
#	add_child(timer)
#	timer.start()
# Функция для создания сцены базы:

func create_base0(faction):
	var base = load("res://scenes/Base/Base_1.tscn").instance()
	base.faction = faction
	# задаем случайные координаты для базы

	var base_pos = Vector2(rand_range(-500, 500), rand_range(-500, 500))
	base.position = base_pos	
	# добавляем базу на сцену
#	get_tree().get_node("/root/Main").
	add_child(base)
	return 	base_pos

func _on_timer_timeout():
	# обновляем данные о зданиях
	for building_name in building_data.keys():
		var building = get_node(building_data[building_name]["scene_id"])
		building.update_resources(building_data[building_name]["current_resources"], building_data[building_name]["max_resources"])

	# увеличиваем количество ресурсов в зданиях
	for building_name in building_data.keys():
		building_data[building_name]["current_resources"] += 1
		if building_data[building_name]["current_resources"] > building_data[building_name]["max_resources"]:
			building_data[building_name]["current_resources"] = building_data[building_name]["max_resources"]
func a_get_base(f):
	var i = 0
	var creature_nodes = get_node("/root/Map/Qurrent_Location/BaseHuman").get_children()

	for node in creature_nodes:
#		print("Base Name: faction")
#		print(node.name," ",node.faction)
		if node.faction == f:
			i +=1
#			print("Base Name: faction")
#			print(node.name," ",node.faction)
	return i	
func increase_resource_for_players():
#		print ("==============================================================")	
		for pl in Network.players:
			var f = Network.players[pl]["faction"]
			var res =  a_get_base(f)

			if pl != -1:
#				print("Player id, bases")
#				print (pl," ", res)

#				print ("player faction resource")
#				print (Network.players[pl]["current_resources"])
				Network.players[pl]["current_resources"] += res * 5
#				print("Player resources")
#				print(Network.players[pl]["current_resources"])	
#		Network.print_list_player()
#		print ("==============================================================")
func _on_Update_Build_Timer_timeout():
	_on_timer_timeout()
#	increase_resource_in_building()
	increase_resource_for_players()	
	Global.player_resource += 5
	$UI/UI/STATS/Resources.text = "RESOURCES: " + str(Global.player_resource)
	Network.update_resource(int(Global.player_resource))
#	
	b_process(10)

#Функция начальной генерации мобов и зданий
func _load_building_creatures_from_server():
	if Global.creature_data2 == null:
		return	
#	for building in	Global.building_data:
#		add_new_build("name", Global.building_data[building]["pos"])
	var base_lst = Global.creature_data2["Bases_List"]		
	for base in	base_lst:
		add_new_build1(base,base_lst[base]["pos"],base_lst[base]["health"],base_lst[base]["faction"],base_lst[base]["current_resources"]) 		
	base_lst = Global.building_data #creature_data2["Bases_List"]		
	for base in	base_lst:
		add_new_build1(base,base_lst[base]["pos"],base_lst[base]["health"],base_lst[base]["faction"],base_lst[base]["current_resources"]) 		

	var cr_lst = Global.creature_data2["RobotHuman_List"]		
	for creature in	cr_lst:
		var creature_name = "Creature"
		var faction1 = cr_lst[creature]["faction"]
		var n = cr_lst[creature]["name"]
		if "RobotHuman" in n:
			creature_name = "RobotHuman"
		add_creature2(faction1,creature_name,creature,cr_lst[creature]["pos"],cr_lst[creature]["health"])	
	cr_lst = Global.creature_data2["Creature_List"]	
	for creature in	cr_lst:
		var creature_name
		var faction1 = cr_lst[creature]["faction"]
		var n = cr_lst[creature]["name"]
		if "Creature" in n:
			creature_name = "Creature"
		add_creature2(faction1,creature_name,creature,cr_lst[creature]["pos"],cr_lst[creature]["health"])	
	cr_lst = Global.creature_data2["RobotRoy_List"]	
	for creature in	cr_lst:
		var creature_name = "Creature" 
		var faction1 = cr_lst[creature]["faction"]
		var n = cr_lst[creature]["name"]
		if "Robot_Roy" in n:
			creature_name = "Robot_Roy"			
		add_creature2(faction1,creature_name,creature,cr_lst[creature]["pos"],cr_lst[creature]["health"])	
	cr_lst = Global.creature_data2["RobotRoy_List"]	
	for creature in	cr_lst:
		var creature_name = "Creature" 
		var faction1 = cr_lst[creature]["faction"]
		var n = cr_lst[creature]["name"]
		if "Robot_Swarm" in n:
			creature_name = "Robot_Swarm"			
		add_creature2(faction1,creature_name,creature,cr_lst[creature]["pos"],cr_lst[creature]["health"])	
	not_create_bullet = false
# Функция, которая вызывает создание моба на сервере и rpc-вызывает создание моба на всех клиентах
func add_creature2(faction1,type,name,position,health):
#	rpc_unreliable("spawn_creature", name, position)
	spawn_creature(faction1,type,name, position,health)		
# Rpc-функция, которая создает сцену моба на всех клиентах и присваивает ей имя, полученное от сервера
remote func spawn_creature(faction1,type,name, position,health):
	var creature1 = "res://scenes/Mobs/Creature.tscn"
	var creature_path = "/root/Map/Qurrent_Location/Creatures"	 
	if 	type == "RobotHuman":
		creature1 = "res://scenes/Robot/Robot1.tscn"
		creature_path = "/root/Map/Qurrent_Location/RobotHuman"
	if 	type == "Robot_Swarm":
		creature1 ="res://scenes/Robot/Robot_swarm.tscn"
		creature_path = "/root/Map/Qurrent_Location/RobotRoy"
	if 	type == "Robot_Roy":
		creature1 ="res://scenes/Robot/Robot0.tscn"
		creature_path = "/root/Map/Qurrent_Location/RobotRoy"
	var creature = load(creature1).instance()			
#	creature.name = name
	creature.position = position
	creature.health = health
	creature.faction = faction1
	get_node(creature_path).add_child(creature)
		
func add_new_build1(name, position,health1,faction1,resources):
	var build_path = "/root/Map/Qurrent_Location/Building"
	var build_type = "res://scenes/Mobs/Building.tscn"
	var name1 = "Building"
	if faction1 == 10:
		build_path = "/root/Map/Qurrent_Location/BaseHuman"
		build_type = "res://scenes/Base/Base_1.tscn"
		name1 = "BaseHuman"
	if faction1 == 9:
		build_path = "/root/Map/Qurrent_Location/BaseSwarm"
		build_type = "res://scenes/Base/Base_0.tscn"
		name1 = "BaseSwarm"
	if faction1 == 7:
		build_path = "/root/Map/Qurrent_Location/BaseSwarm"
		build_type = "res://scenes/Base/Base_Nest.tscn"
		name1 = "BaseNestSwarm"				
	var building = load(build_type).instance()
	building.name = name1
	building.global_position = position
	building.faction = faction1
	building.health = health1
	building.resource = resources

	get_node(build_path).add_child(building)	

func save_data():
	var file = File.new()
	file.open("user://list_builds.save", File.WRITE)
	file.store_var(Global.building_data)
	file.close()
	
	file.open("user://list_creatures.save", File.WRITE)
	file.store_var(Global.creature_data)
	file.close()

# Функция для загрузки данных из файлов и создания словарей зданий и мобов
func load_data():
	var file = File.new()
	if file.file_exists("user://list_builds.save"):
		file.open("user://list_builds.save", File.READ)
		Global.building_data = file.get_var()
		file.close()
	else:
		Global.building_data = {}
	
	if file.file_exists("user://list_creatures.save"):
		file.open("user://list_creatures.save", File.READ)
		Global.creature_data = file.get_var()
		file.close()
	else:
		Global.creature_data = {}
# Функция для добавления моба в словарь и на сцену
func aadd_creature(name, position):
#	var id = generate_id()
#	Global.creature_data[id] = {"name": name, "position": position}
	var creature = load("res://scenes/Mobs/Creature.tscn").instance()
#	creature.name = name
	creature.position = position
	get_node("/root/Map/Qurrent_Location/Creatures").add_child(creature)
	print(position)
	print("position")

func delete_player(id):
	remove_child(id)
	id.queue_free()
func update_resources(res):
	if not get_tree().is_network_server():
		Global.player_resource = res[0]
		$UI/UI/STATS/Resources.text = "RESOURCES: " + str(Global.player_resource)
		$UI/UI/STATS/Race.text = "RACE: " + str(Global.player_race1)
		Global.count_robot_human  = res[1]
		$UI/UI/STATS/Robots.text = "BOTS: " + str(res[1])		
		Global.count_base_human  = res[2]
		$UI/UI/STATS/Bases.text = "SERVERS: " + str(res[2])
		Global.count_robot_swarm  = res[3]
		$UI/UI/STATS/Swarm.text = "SWARM: " + str(res[3])		
		Global.count_base_swarm  = res[4]
		$UI/UI/STATS/BasesSwarm.text = "S-server: " + str(res[4])
		Global.count_robot_creatures =  res[5]
		$UI/UI/STATS/Creature.text = "GUARD: " + str(res[5])		
		Global.count_base_creatures = res[6]
		$UI/UI/STATS/BasesCreature.text = "Gserver: " + str(res[6])
#=============================================================================
# сейчас не используются эти функции
func a_process1(delta):
	if get_tree().is_network_server():	
		var distance = position.distance_to(player.position)
		if distance < 300:
			var direction = (player.position - position).normalized()
			var velocity = direction * speed * delta
#			position += velocity
#    else:
		# Остановить моба
# Функция для добавления моба в словарь и на сцену		
	
func acreate_creature(position):
	var creature = load("res://scenes/Mobs/Creature.tscn").instance()
	# Генерируем уникальное имя узла
	var creature_name = "Creature_" + str(get_tree().get_network_unique_id())
	creature.name = creature_name
	creature.position = position
	get_node("/root/Map/Qurrent_Location/Creatures").add_child(creature)
	# Возвращаем имя узла
	return creature_name


# Функция для генерации уникального идентификатора для моба
func generate_id():
	var id = randi()
	while Global.creature_data.has(id):
		id = randi()
	return id

# Функция для удаления моба из словаря и сцены
func remove_creature(id):
	if Global.creature_data.has(id):
		Global.creature_data.erase(id)
		var creature = get_node("/root/Map/Qurrent_Location/Creatures").get_node(str(id))
		if creature != null:
			creature.queue_free()

remote func create_build(new_building_data):
	building_data = new_building_data


		
