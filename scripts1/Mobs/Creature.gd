extends KinematicBody2D
export var target_pos = Vector2(0,0)
var race  = 3
var uid = 3
var bullet
var state = "waiting"
var faction = 0 # фракция
var health = 100
var max_health = 100
var energy = 100
var speed = 12
var shield = 5 # сколько урона пропускает щит
var creatures = []
var parent_id = 0
var dead_now = false 
var uuid = 0 # уникальный номер объекта в игровом мире
func _ready():
	$LifeTimer.start(Global.Lifetime["Creature"])
	$MyName.text = self.name
	parent_id = self
	$Posit.text = str(int(position.x)) + " / " + str(int(position.y))
	Global.count_robot_creatures += 1
	var a = get_node("/root/Map/UI/UI/STATS/Creature")		
	a.text = "GUARD: " + str(Global.count_robot_creatures)		
#		$DieTimer.start(60 + (rand_range(0,20)))
	bullet = ResourceLoader.load("res://Weapon/Bullet/bullet2.tscn")
#	$FireTimer.start(15)
#	$HP_bar.text = str(health)		
	return
	if get_tree().is_network_server():
		var creature_nodes = get_node("/root/Map/Qurrent_Location/Creatures").get_children()
		for node in creature_nodes:
			if node.has_method("get_creature_data"):
				creatures.append(node)
		Global.creatures = creatures					
func rotate_to_target(target):
	$Area2D.look_at(target)
func get_rotate():
	return $Area2D.rotation		
func _process(delta):
	$Posit.text = str(int(position.x)) + " / " + str(int(position.y))
#	look_at(target_pos)		
func a_process(delta):
	if not get_tree().is_network_server():
		var pl = Global.player_id.position	
		var distance = position.distance_to(pl)
		if distance < 350 and distance > 16:
			var direction = (pl - position).normalized()
			var velocity = direction * speed * delta
			look_at(pl)
			position += velocity*4
#    else:
		# Остановить моба

func get_faction():
	return faction
			

func set_creature_data(data):
	var global = get_node("/root/Global")
	var creature_data = global.creature_data2
	creature_data[name] = data
#	global.creature_data = creature_data
	
func get_creature_data():
	var my_data = {"pos": self.position}
	return 	my_data


func _on_DieTimer_timeout():
	if get_tree().is_network_server():
		a_on_DieTimer_timeout()
func a_on_DieTimer_timeout():
		Global.count_robot_creatures -= 1
		var a = get_node("/root/Map/UI/UI/STATS/Creature")		
		a.text = "GUARD: " + str(Global.count_robot_creatures)		
		var Creatures_Node = get_node("/root/Map/Qurrent_Location/Creatures")
		Creatures_Node.Remove_Creatures(self)
		queue_free()
remote func Deaded():
		var Creatures_Node = get_node("/root/Map/Qurrent_Location/Creatures")
		Creatures_Node.Remove_Creatures1(self)
		queue_free()
func Spell_Action():
	var bull = bullet.instance()
#	var uid_bull = randi()
	bull.set_uid(race,uid)
	bull.dir = rotation
	bull.rotation = rotation
	bull.global_position = global_position
	get_parent().add_child(bull)

func _on_Area2D_area_entered(body):
	if get_tree().is_network_server() and dead_now == false:	
		if "Bullet" in body.name and body.race1 != race and health > 0:
			health -= shield
	#		$HP_bar.text = str(health)	
			if health < 0:
#				rpc("dead")
				Network._send_Creature_Dead(self.name,Global.type_update_creature)
				dead_now = true
				$DieTimer.start(1)
			$HP_bar2.value = int(health)
			Network._send_Creature_Update_HP(int(health),self.name,Global.type_update_creature)
func reduce_hp(a,race1):
	if get_tree().is_network_server() and dead_now == false:		
		if race1 != race:
			if race1 == Global.swarm_race:
				print("swarm attack creature")
				health -= 0.25*max_health
			health -= shield
#			$HP_bar.text = str(health)	
			if health < 0:
#				rpc("dead")
				Network._send_Creature_Dead(self.name,Global.type_update_creature)			
				dead_now = true
				$DieTimer.start(1)
		$HP_bar2.value = int(health)
#		rpc("update_hp", int(health))
		var my_name = self.name
		Network._send_Creature_Update_HP(int(health),my_name,Global.type_update_creature)

func update_hp(health_new):
#	print("new_health=======================================")
#	print(self.name)
#	print(health_new)	
	if not get_tree().is_network_server():
		health = health_new
		$HP_bar2.value = int(health_new)		
func dead():
#	print("creatures_dead=======================================")
#	print(self.name)		
	if not get_tree().is_network_server():
		Global.count_robot_creatures -= 1
		var a = get_node("/root/Map/UI/UI/STATS/Creature")		
		a.text = "GUARD: " + str(Global.count_robot_creatures)			
		var Creatures_Node = get_node("/root/Map/Qurrent_Location/Creatures")
		Creatures_Node.Remove_Creatures1(self)	
		queue_free()		
#		a_on_DieTimer_timeout()				
func get_uid():
	return parent_id
func get_race():
	return race
func _on_FireTimer_timeout():
	Network.create_bullet_player0(self.faction,global_position,$Area2D.rotation,0)	



func _on_LifeTimer_timeout():
	if get_tree().is_network_server() and dead_now == false:
				Network._send_Creature_Dead(self.name,Global.type_update_creature)			
				dead_now = true
				$DieTimer.start(1)
	elif not get_tree().is_network_server():
		a_on_DieTimer_timeout()		
