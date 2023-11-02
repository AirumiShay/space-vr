extends KinematicBody2D

var God_mode = true
var shield = 50
var timer = 0
var energy = 100
var state = "waiting" #"patrolling"
var wait_timer
var slow_timer
var restore_timer 
var wait_time
var health = 250
var max_health = 250
var faction = 1 # фракция
var dir = 0
var race = 1
var speed = 2
var creatures = []
var target_pos = Vector2(0,0)
var dead_now = false #программа остановлена - "мертва"
var uuid = 0 # уникальный номер объекта в игровом мире
func _ready():
	$HP_bar.text = str(faction)
	$GodTimer.start(2)
	Global.count_robot_human += 1
	get_node("/root/Map/UI/UI/STATS/Robots").text = "BOTS: " + str(Global.count_robot_human)			
		
	$Area2D.faction = faction	
	$Posit.text = str(int(position.x)) + " / " + str(int(position.y))
	return
	if get_tree().is_network_server():
		var creature_nodes = get_node("/root/Map/Qurrent_Location/Creatures").get_children()
		for node in creature_nodes:
			if node.has_method("get_creature_data"):
				creatures.append(node)
		Global.creatures = creatures
	else:
		if faction == 1 or faction == 0 or faction == 10 :
			$Sprite2.visible = false
			$Sprite.visible = true						
#		$DieTimer.start(60 + (rand_range(0,20)))
func _process0(delta):
	$Posit.text = str(int(position.x)) + " / " + str(int(position.y))		
	random_movement(delta,self)
func a_process(delta):
	if not get_tree().is_network_server():
		var pl = Global.player_id.position	
		var distance = position.distance_to(pl)
		if distance < 350 and distance > 16:
			var direction = (pl - position).normalized()
			var velocity = direction * speed * delta
			position += velocity*4
#    else:
		# Остановить моба

func get_faction():
	return faction
			

func set_creature_data(data):
	var global = get_node("/root/Global")
#	var creature_data = global.creature_data
#	creature_data[name] = data
#	global.creature_data = creature_data
	
func get_creature_data():
	var my_data = {"pos": self.position}
	return 	my_data
func rotate_to_target(target):
	$Area2D.look_at(target)
func get_rotate():
	return $Area2D.rotation	

func _on_DieTimer_timeout():
	Global.count_robot_human -= 1	
	if get_tree().is_network_server():	
		get_parent().remove_child(self)

#		var creature_nodes = get_node("/root/Map/Qurrent_Location/Creatures").get_children()
#		for node in creature_nodes:
#			if node.has_method("get_creature_data"):
#				creatures.append(node)
#		Global.creatures = creatures

		get_node("/root/Map/UI/UI/STATS/Robots").text = "BOTS: " + str(Global.count_robot_human)			
		queue_free()

#Функция для патрулирования кораблем-роботом:
func patrol(robot,delta):
	var bases = get_tree().get_nodes_in_group("bases")
	# сортируем базы по расстоянию до корабля-робота
	bases = sort_bases_by_distance(robot, bases)
	var target_base = null
	for base in bases:
		# если база принадлежит другой фракции, то корабль направляется к ней
		if base.faction != robot.faction:
			target_base = base
			break
	# если нет баз другой фракции, то корабль патрулирует вокруг своей базы
	if target_base == null:
		target_base = get_closest_base(robot.faction)
	if target_base != null:
		var direction = (target_base.position - robot.position).normalized()
		robot.position += direction * robot.speed * delta
#		robot.rotation = direction.angle()
func patrol2(robot,delta):
	var base = get_closest_base(robot.faction)
	# если база не найдена, то корабль остается на месте
	if base == null:
		return
	# вычисляем расстояние до базы
	var distance = robot.position.distance_to(base.position)
	# если расстояние больше 350, то корабль движется к базе
	if distance > 350*(rand_range(1, 5)):
		var direction = (base.position - robot.position).normalized()
		robot.position += direction * robot.speed * delta
	# иначе корабль патрулирует вокруг базы
	else:
		var angle = robot.position.angle_to(base.position)
		var patrol_radius = 500
		var patrol_center = base.position + Vector2(patrol_radius, 0)
#Функция для атаки корабля-робота или базы:

func attack(ship,delta):
	var target = get_closest_target(ship)
	# если цель не найдена, то корабль летит в случайную сторону
	if target == null:
		var direction = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized()
		ship.position += direction * ship.speed * delta
		return
	# вычисляем расстояние до цели
	var distance = ship.position.distance_to(target.position)
	# если расстояние меньше 100, то корабль атакует цель
	if distance < 100:
		target.health -= ship.damage
		# если цель уничтожена, то удаляем ее со сцены
		if target.health <= 0:
			target.queue_free()
	# иначе корабль летит к цели
	else:
		var direction = (target.position - ship.position).normalized()
		ship.position += direction * ship.speed * delta


#Функция для получения ближайшей базы или корабля-робота:

func get_closest_target(faction):
	var targets = []
	# ищем все базы и корабли-роботы на сцене
	for node in get_tree().get_nodes_in_group("bases"):
		if node.faction != faction:
			targets.append(node)
	for node in get_tree().get_nodes_in_group("robots"):
		if node.faction != faction:
			targets.append(node)
	# сортируем цели по расстоянию до корабля расы Рой
#	targets.sort_custom(lambda x: ship.position.distance_to(x.position))
	# возвращаем ближайшую цель
	if targets.size() > 0:
		return targets[0]
	else:
		return null
		
func sort_bases_by_distance(robot, bases):
	var distances = []
	for base in bases:
		distances.append(robot.position.distance_to(base.position))
	var sorted_bases = []
	for i in range(bases.size()):
		var min_distance = float("inf")
		var min_index = -1
		for j in range(bases.size()):
			if not j in sorted_bases:
				var distance = distances[j]
				if distance < min_distance:
					min_distance = distance
					min_index = j
		sorted_bases.append(min_index)
	var sorted_bases_list = []
	for i in sorted_bases:
		sorted_bases_list.append(bases[i])
	return sorted_bases_list
		
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

#Функция для стрельбы корабля-робота:

func shoot(robot):
	var target = get_closest_target(robot.faction)
	# если цель не найдена, то корабль не стреляет
	if target == null:
		return
	# вычисляем расстояние до цели
	var distance = robot.position.distance_to(target.position)
	# если расстояние меньше 300, то корабль стреляет
	if distance < 300:
		var bullet = load("res://scenes/bullet.tscn").instance()
		bullet.position = robot.position
		bullet.rotation = robot.position.angle_to(target.position)
		get_node("/root/Main").add_child(bullet)
	# иначе корабль не стреляет
	else:
		return
# Функция для обработки уничтожения корабля-робота или базы:

func _on_destroyed():
	# удаляем объект со сцены
	queue_free()


#Функция для обновления состояния корабля-робота или базы:

func _process2(delta):
	# если объект является кораблем-роботом, то он патрулирует и стреляет
	if is_in_group("robots"):
		patrol(self,delta)
		shoot(self)
	# если объект является базой, то она создает корабли и стреляет
	elif is_in_group("bases"):
		create_robot(self.faction)
		shoot(self)
func create_robot(faction):
	# если на сцене уже есть достаточное количество кораблей-роботов, то база не создает новые
	if get_tree().get_nodes_in_group("robots").size() >= 10:
		return
	var robot = load("res://scenes/robot.tscn").instance()
	robot.faction = faction
	robot.health = 100
	robot.energy = 100
	robot.speed = 100
	robot.state = "patrolling"
	get_node("/root/Main").add_child(robot)	
#Функция для возвращения корабля-робота на базу:

func return_to_base(robot,delta):
	var base = get_closest_base(robot.faction)
	# если база не найдена, то корабль не возвращается на базу
	if base == null:
		return
	# вычисляем расстояние до базы
	var distance = robot.position.distance_to(base.position)
	# если расстояние больше 50, то корабль движется к базе
	if distance > 50:
		var direction = (base.position - robot.position).normalized()
		robot.position += direction * robot.speed * delta
	# иначе корабль останавливается на базе
	else:
		robot.position = base.position
		# если здоровье или энергия меньше 25%, то корабль ожидает ремонта или зарядки
		if robot.health < 25 or robot.energy < 25:
			robot.state = "waiting"
			robot.wait_time = 10 if robot.energy < 25 else 20
			robot.wait_timer = 0
		# иначе корабль продолжает патрулировать
		else:
			robot.state = "patrolling"
#Функция для обновления состояния корабля-робота:

func _process3(delta):
	# если объект является кораблем-роботом, то он патрулирует, стреляет и возвращается на базу при необходимости
	if is_in_group("robots"):
		if state == "patrolling":
			patrol(self,delta)
			shoot(self)
			# если энергия меньше 25%, то корабль возвращается на базу
			if energy < 25:
				state = "returning"
			elif state == "returning":
				return_to_base(self,delta)
			# если корабль на базе и нуждается в ремонте или зарядке, то он ожидает
			if wait_timer < wait_time:
				wait_timer += delta
			# иначе корабль продолжает патрулировать
			else:
				energy = 100
				health = 100
				state = "patrolling"
		elif state == "waiting":
			# если корабль на базе и нуждается в ремонте или зарядке, то он ожидает
			if wait_timer < wait_time:
				wait_timer += delta
			# иначе корабль продолжает патрулировать
			else:
				energy = 100
				health = 100
				state = "patrolling"
		# уменьшаем энергию при стрельбе
		if state == "patrolling" or state == "returning":
			energy -= 1
	# если объект является базой, то она создает корабли и стреляет
	elif is_in_group("bases"):
		create_robot(self.faction)
		shoot(self)
#реализации логики захвата базы 

func capture_base(special_robot):
	var target_base = get_closest_base(special_robot.faction)
	# если база не найдена, то корабль не захватывает базу
	if target_base == null:
		return
	# вычисляем расстояние до базы
	var distance = special_robot.position.distance_to(target_base.position)
	# если расстояние меньше 50, то корабль захватывает базу
	if distance < 50 and special_robot.energy > 10:
		target_base.faction = special_robot.faction
		target_base.color = special_robot.color
		target_base.health = 100
		target_base.energy = 100
		target_base.speed = 0
		target_base.state = "captured"
		special_robot.energy -= 10
	# иначе корабль продолжает атаковать
	else:
		special_robot.state = "attack"
#Функция для обновления состояния особого корабля-робота:

func _process(delta):
	if dead_now == true:
		return
	if timer < 0.10:
		timer += delta
	else:
		timer = 0
		if state == "waiting":
			state = "patroling"
			random_movement(delta,self)			
		else:
			state = "waiting"
			patrol(self,delta)
	return
	# если объект является особым кораблем-роботом, то он атакует и захватывает базы
	if is_in_group("special_robots"):
		if state == "attacking":
			var target = get_closest_target(faction)
			if target != null:
				var direction = (target.position - position).normalized()
				position += direction * speed * delta
				rotation = direction.angle()
				shoot(self)
				# если энергия или здоровье меньше 25%, то корабль замедляется
				if energy < 25 or health < 25:
					speed = 100
					state = "slowing_down"
					slow_timer = 0
		elif state == "slowing_down":
			# корабль замедляется на 25 секунд
			if slow_timer < 25:
				slow_timer += delta
				energy += 1
				health += 1
			# после замедления корабль останавливается и восстанавливает параметры
			else:
				speed = 0
				state = "restoring"
				restore_timer = 0
		elif state == "restoring":
			# корабль восстанавливает параметры на 4% в секунду до 100%
			if restore_timer < 25:
				restore_timer += delta
				energy += 4
				health += 4
			# после восстановления корабль продолжает атаковать
			else:
				speed = 200
				state = "attacking"
		elif state == "capturing":
			capture_base(self)
		# уменьшаем энергию при стрельбе
		if state == "attacking" or state == "slowing_down" or state == "capturing":
			energy -= 1
	# если объект является базой, то она создает корабли и стреляет
	elif is_in_group("bases"):
		create_robot(self.faction)
func mining(robot, objects):
	var has_enemies = false
	for obj in objects:
		if obj.type == "ship" and obj.team != robot.team:
			has_enemies = true
			break
		elif obj.type == "base" and obj.team != robot.team:
			has_enemies = true
			break
	if not has_enemies:
		for obj in objects:
			if obj.type == "asteroid":
				var distance = robot.position.distance_to(obj.position)
				if distance <= robot.mining_range:
					robot.move_to(obj.position)
					yield(get_tree().create_timer(10.0), "timeout")
					robot.move_to(robot.base.position)
					break
func random_movement(delta,robot):
	var target_position = robot.position + Vector2(rand_range(-750, 750), rand_range(-450, 450))
#	robot.
	move_to(delta,target_position)
func move_to(delta,pl):
#		var pl = self.position	
		var distance = position.distance_to(pl)
		if distance < 350 and distance > 16:
			var direction = (pl - position).normalized()
			var velocity = direction * speed * delta * 10
			position += velocity


func _on_Area2D_area_entered(body):
	if get_tree().is_network_server() and dead_now == false:	
		if "Bullet" in body.name and body.race1 != race and health > 0:
			health -= shield
	#		$HP_bar.text = str(health)	
			if health < 0:
#				rpc("dead")
				Network._send_Creature_Dead(self.name,Global.type_update_robot_human)
				dead_now = true
				$DieTimer.start(1)
			$HP_bar2.value = int(health)
			Network._send_Creature_Update_HP(int(health),self.name,Global.type_update_robot_human)
	return

	if "Bullet" in body.name and God_mode == false:
		health -= shield
		if health < 0:

			Global.count_robot_human -= 1
			get_node("/root/Map/UI/UI/STATS/Robots").text = "BOTS: " + str(Global.count_robot_human)			
	
			queue_free()
	elif "Asteroid" in body.name:
#			health = 1
#			if health < 0:

				Network._send_Creature_Dead(self.name,Global.type_update_robot_human)
				dead_now = true
				$DieTimer.start(1)
				queue_free()			
func reduce_hp(a,race1):
	if God_mode == true:
		return
	if get_tree().is_network_server() and dead_now == false:		
		if race1 != race:
			if race1 == Global.swarm_race:
				print("swarm attack robot")
				health -= 0.33 * max_health
			health -= shield
#			$HP_bar.text = str(health)	
			if health < 0:
#				rpc("dead")
				Network._send_Creature_Dead(self.name,Global.type_update_robot_human)			
				dead_now = true
				$DieTimer.start(1)
		$HP_bar2.value = int(health)
#		rpc("update_hp", int(health))
		var my_name = self.name
		Network._send_Creature_Update_HP(int(health),my_name,Global.type_update_robot_human)
		
		health -= shield
		$HP_bar.text = str(faction) #health)	
		$HP_bar2.value = int(health)	
		if health < 0:

#			Global.count_robot_human -= 1
			get_node("/root/Map/UI/UI/STATS/Robots").text = "BOTS: " + str(Global.count_robot_human)			
	
			queue_free()

func dead():
#	print("creatures_dead=======================================")
#	print(self.name)		
	if not get_tree().is_network_server():
		$Play.playing
		Global.count_robot_human -= 1
		var a = get_node("/root/Map/UI/UI/STATS/Robots")		
		a.text = "BOTS: " + str(Global.count_robot_human)			
		var Creatures_Node = get_node("/root/Map/Qurrent_Location/Creatures")
		Creatures_Node.Remove_Creatures1(self)	
		queue_free()
func update_hp(health_new):
#	print("new_health=======================================")
#	print(self.name)
#	print(health_new)	
	if not get_tree().is_network_server():
		health = health_new
		$HP_bar2.value = int(health_new)
func _on_GodTimer_timeout():
	God_mode = false
