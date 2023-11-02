extends KinematicBody2D
var health = 1000
var energy = 1000
var direction = Vector2()
var bullet
var bullet0
var shield = 2 # сколько урона пропускает щит
var faction = 100 # фракция
var race  = 100
var uid = 2
var parent_id = 0
var FireEnable = true #можно стрелять вирусами, орудие заряжено.
var my_position = Vector2(0,0)
var my_uid
var Spell1 = true #гравитационная пушка заряжена
var Spawn1 = true # можно призывать роботов
var Spawn2 = true #можно создавать базу
var Healing = false #сейчас на базе восстанавливаемся/трансмутируем)))
var cooldown_new_base = 60
var uuid = 0 # уникальный номер объекта в игровом мире
func _ready():
	var Map_HP = get_node("/root/Map/UI/UI/HP")
	Map_HP.value = int(health)		
	var player_unique_id = get_tree().get_network_unique_id()	
	my_uid = player_unique_id
	Global.player_id = self
	Global.player_uid= player_unique_id
	$DisplayUsername.text = Network.username
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	
	# Wait one frame before checking if we are the master of this node
	# Otherwise it won't be defined yet
	yield(get_tree(), "idle_frame")
	
	set_physics_process(is_network_master())
	$Controlled.visible = is_network_master()
	
	_on_network_peer_connected("")
	bullet = ResourceLoader.load("res://Weapon/Bullet/bullet2.tscn")
	bullet0 = ResourceLoader.load("res://scenes/Bullet/Bullet.tscn")	
#	$HP_bar.text = str(health)

	if not get_tree().is_network_server():
		if is_network_master():
#			var player_unique_id = get_tree().get_network_unique_id()			
#			randomize()
#			race = int(rand_range(10,10000))					
#			Global.player_race = race
#			Network.add_new_player0(player_unique_id,race)
#			yield(get_tree().create_timer(0.5), "timeout")	
			race = 	Global.player_race1
			print("race3")
			print(race)				
			faction = race
			$HP_bar.text = str(faction)	
#			my_uid = player_unique_id			
			rpc("set_new_race",race)
#remote func set_new_race(race1):
#	if not get_tree().is_network_server():
#		if is_network_master():	
#			Global.player_race = race1
sync func set_new_race(race1):
	if not get_tree().is_network_server():
		if not is_network_master():
			race = race1			
func _on_network_peer_connected(id):
	if is_network_master():
		rpc("share_name", $DisplayUsername.text,race)

remotesync func share_name(data,race1):
	$DisplayUsername.text = data
	race = race1
remotesync func position(data):
	position = data
func get_faction():
	return faction

func _physics_process(delta):

	direction.x = -Input.get_action_strength("left") + Input.get_action_strength("right")
	direction.y = -Input.get_action_strength("up") + Input.get_action_strength("down")
	FireBullet()
	if is_network_master():	
		var player_unique_id = get_tree().get_network_unique_id()		
#		rpc_id(1,"set_new_position_player",player_unique_id,direction)
#		if get_tree().is_network_server():
		move_and_slide(direction * 1000)
		rpc_unreliable("position", position)
	#	my_position = global_position

remote func set_new_position_player(uid, direction):
		if get_tree().is_network_server():
			move_and_slide(direction * 1000)
			for pl in Network.players:
				if pl != 1:
					rpc_id(pl,"set_new_position_player_client", global_position)
#				rpc_unreliable("position", position)
remote func set_new_position_player_client(pos):
	if not get_tree().is_network_server():
		if is_network_master():
#			var player_unique_id = get_tree().get_network_unique_id()			
			var player = Global.player_id
			player.global_position = pos
#			rpc_unreliable("position", position)
func _process(delta):
	if not get_tree().is_network_server():
#	return
		if race !=	Global.player_race1:
			race = 	Global.player_race1
			faction = race
			$HP_bar.text = str(faction)		
	if Healing == true:
		if get_tree().is_network_server()  and health < Global.player_max_health: #and is_network_master()
			health += 300*delta
			if health > Global.player_max_health:
				health = Global.player_max_health
			$HP_bar2.value = int(health)
#			var uid = get_tree().get_network_unique_id()
			rpc("update_hp", int(health))
#			$HP_bar.text = str(Global.player_race) 			
func FireBullet():
	if Input.is_action_pressed("fire") and FireEnable == true:
		Spell_Action_server(0)
	if Input.is_action_pressed("fire2") and FireEnable == true:
		Spell1_Action_server(1)
	if Input.is_action_pressed("spawn") and FireEnable == true:
		Spawn_Action_server(2)
	if Input.is_action_pressed("spawn1") and FireEnable == true:
		Spawn1_Action_server(3)	
	if Input.is_action_pressed("spawn2") and FireEnable == true:
		Spawn2_Action_server(5)
	if Input.is_action_pressed("spawn3") and FireEnable == true:
		Spawn2_Action_server(4)	
	if Input.is_action_pressed("spawn4") and FireEnable == true:
		Spawn1_Action_server(6)		
	if Input.is_action_pressed("ui_cancel"):
		Global.player_live_status = false
		get_tree().change_scene("res://Main.tscn")		
func _on_Area2D_area_entered(area):
	bullet_on_Area2D_area_entered(area)
	if area.is_in_group("enter_location_1"):
		var location_id = 1	
		Network.player_want_goto_location(location_id)
func Spell_Action_server(a):
	if health > 50:	
		Network.create_bullet_player(self.faction,global_position,$Player.rotation,a)
func Spell1_Action_server(a):
	if Spell1 == true and (health > 150):
		Spell1 = false
		$SpellTimer.start(0.05)
		Network.create_bullet_player(self.faction,global_position,$Player.rotation,a)			 # 1 - bullet	
func Spawn2_Action_server(a):
	if Spawn1 == true and (health > 150):
#		reduce_hp(100,-10)		
		Spawn1 = false
		$SpawnTimer.start(3)
		var faction1 = Global.swarm_race
		Network.create_bullet_player(faction1,global_position-Vector2(100,100),0,a)	 # 1 - bullet	
func Spawn_Action_server(a):
	if Spawn1 == true and (health > 150):
#		reduce_hp(100,-10)		
		Spawn1 = false
		$SpawnTimer.start(3)
		var faction1 = self.faction
		Network.create_bullet_player(faction1,global_position-Vector2(100,100),0,a)	 # 2 - robot_human/swarm	

func Spawn1_Action_server(a):
	if Spawn2 == true and (health > 665):
#		rpc_id(1,"reduce_hp",650,-10)
		Spawn2 = false
		$SpawnTimer2.start(60)
		cooldown_new_base = 0
		update_cooldown()		
		$SecondTimer.start(2)
		Network.create_bullet_player(self.faction,global_position+Vector2(150,150),0,a)	 # 3 - base_human/swarm	

func Spell_Action():
		FireEnable = false
		$FireTimer.start(0.25)		
		var bull = bullet0.instance()
	#	var uid_bull = randi()
		bull.set_uid(race,self)
		bull.dir = rotation
		bull.rotation = rotation
		bull.global_position = global_position
		get_parent().add_child(bull)

func bullet_on_Area2D_area_entered(body):

	if "Base_Human" in body.name:
		Healing = true
		if not get_tree().is_network_server():
			return		
		$HP_bar2.value = int(health)
		var Map_HP = get_node("/root/Map/UI/UI/HP")
		Map_HP.value = int(health)	
		rpc("update_hp", int(health))
	
		return
	#на сервере
	if "Bullet" in body.name and body.race != race and health > 0: 
		health -= shield


		if health < 0:

#			rpc_id(1,"dead")
			rpc("dead")						
			dead_on_server()
			
		$HP_bar2.value = int(health)
#		var Map_HP = get_node("/root/Map/UI/UI/HP")
#		Map_HP.value = int(health)	
		rpc("update_hp", int(health))
		
func reduce_hp(a,race1):
	if get_tree().is_network_server():		
		if race1 != race:
			if race1 == Global.swarm_race:
				print("swarm attack player")
				health -= 0.25*health
			health -= shield
			$HP_bar.text = str(Global.player_race) #health)	
			if health < 0:
#				rpc_id(1,"dead")				
				rpc("dead")

				dead_on_server()
		$HP_bar2.value = int(health)
#		var Map_HP = get_node("/root/Map/UI/UI/HP")
#		Map_HP.value = int(health)		
		rpc("update_hp", int(health))	
remote func update_hp(health_new):
	if not get_tree().is_network_server(): # and Global.player_id == uid:
		health = health_new
		$HP_bar2.value = int(health_new)
#		print ("health_uid")
#		print(uid)
		if is_network_master():		
			var Map_HP = get_node("/root/Map/UI/UI/HP")
			Map_HP.value = int(health_new)
remote func dead():
	if not get_tree().is_network_server():
		Global.player_live_status = false		
		get_parent().delete_player(self)		
		queue_free()	
func dead_on_server():
	if get_tree().is_network_server():	
		Global.player_live_status = false
		get_parent().delete_player(self)		
		queue_free()	
func get_uid():
	return parent_id
func get_race():
	return race

func _on_FireTimer_timeout():
	FireEnable = true


func _on_SpellTimer_timeout():
	Spell1 = true # Replace with function body.


func _on_SpawnTimer_timeout():
	Spawn1 = true
#	if Spawn1 == true:
#		Spawn1 = false 
#		Network.create_bullet_player(self.faction,global_position+Vector2(-150,150),$Player.rotation,2)	 # 2 - create robot human	
	

func _on_SpawnTimer2_timeout():
	Spawn2 = true 
	cooldown_new_base = 60
	update_cooldown()



func _on_Area2D_area_exited(area):
	if "Base_Human" in area.name:
		Healing = false


func _on_SecondTimer_timeout():
	if Spawn2 == false:
		if cooldown_new_base < 60:
			cooldown_new_base += 2
		else:
			cooldown_new_base = 60
		update_cooldown()
func update_cooldown():
		var cooldown = get_node("/root/Map/UI/UI/CoolDown")
		cooldown.value = int(cooldown_new_base)
	
