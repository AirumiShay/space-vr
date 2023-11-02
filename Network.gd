extends Node

var username = ""
var players = {}
var main = "res://Main.tscn"
var map = "res://scenes/Map.tscn"
var player = "res://scenes/player/Player.tscn"
var chat = load("res://networking/Chat.tscn").instance()
var lobby = "res://Lobby.tscn"
var Qurrent_Location
var Start_Location_0 = "res://scenes/Location/Start_Location_0.tscn"
var location_scene = preload("res://scenes/Location/Start_Location_0.tscn") # загружаем сцену локации

var spawn = null

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")



func create_server(username_chosen):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(4242, 32)
	get_tree().set_network_peer(peer)
	var self_data = { "name":'', "position":Vector2(390, 280), "location": 0, "race": 0, "faction":0 , "current_resources":0 }
	self_data.name = username_chosen
	self_data.race = 0	
	players[1] = self_data
	AudioServer.set_bus_mute(0, true) # The server mutes the game
	username = username_chosen + " (host)"
	
	load_game()

func join_server(to_ip, username_chosen):
	if Global.player_live_status == true:
		var peer = NetworkedMultiplayerENet.new()
		peer.create_client(to_ip, 4242)
		get_tree().set_network_peer(peer)
		
	username = username_chosen
	
	# If a server is detected call _on_connected_to_server() to load the game

func load_game():
	get_tree().change_scene(map)
	
	yield(get_tree().create_timer(0.01), "timeout")
	
	get_spawn_location()
	
	if not get_tree().is_network_server():
		var player_unique_id = get_tree().get_network_unique_id()
		var self_data = { "name":'', "position":Vector2(390, 280), "location": 0, "race": 0, "faction":0 , "current_resources":0 }
		self_data.name = username		
		players[player_unique_id] = self_data
#		rpc_id(1,"add_new_player",player_unique_id)
		spawn_player(player_unique_id,self_data["race"])		

#		var player_unique_id = get_tree().get_network_unique_id()
#		self_data.name = username		
#		players[player_unique_id] = self_data
#		var race = self_data["race"]
#		rpc_id(1,"add_new_player",player_unique_id)
#		spawn_player(player_unique_id,race)
	
	get_tree().get_root().add_child(chat)

func get_spawn_location():
	var spawner = get_tree().get_root().find_node("Spawners", true, false)
	spawner.get_child( randi() % spawner.get_child_count() )
	randomize()
	spawn = spawner.get_child( randi() % spawner.get_child_count() )

func spawn_player(id,race):
	var player_instance = load(player).instance()
	player_instance.name = str(id)
	get_node("/root/Map").add_child(player_instance)
	player_instance.global_transform = spawn.global_transform
	
	player_instance.set_network_master(id)
	player_instance.race = race
	player_instance.faction = race

# Spawn the other players that connected exepted from the server:
func print_list_player():
	for id in players:
		print("Players info: ", id," ",players[id])
		
func _on_network_peer_connected(id):
	if id != 1: # If this is not the server spawn the player
#		print_list_player()		
		var race = int(rand_range(100,10000))
		var self_data = { "name":'', "position":Vector2(390, 280), "location": 0, "race": 0, "faction":0 , "current_resources":50,"status":"live" }
		self_data["race"] = race
		self_data["faction"] = race
		players[id] = self_data	
#		print("New Faction for Player:", race)
#		print_list_player()			
		spawn_player(id,race)
		#race1 = players[id]["faction"]
		rpc_id(id,"add_new_player2", race)		
# Spawn the other players that connected exepted from the server:
func _on_network_peer_connected1(id):
 # If this is not the server spawn the player
		var race = int(rand_range(10,10000))
		var self_data = { "name":'',"status":"live", "position":Vector2(390, 280), "location": 0, "race": 0, "faction":0 , "current_resources":50 }
		self_data["race"] = race
#		players[id] = { "name":'', "position":Vector2(-100000, -100000), "location": 0, "race": 0 }

		players[id] = self_data
		if id != 1:
			spawn_player1(id,race)
#			return
#			rpc_id(id,"add_new_player",id,race)
		return
		for pl in players:
			if  pl != 1 and pl != id:
				return
#				rpc_id(pl,"add_new_player",pl,race)
#эта функция вызывается на клиенте	
func add_new_player0(id,race):
		
			rpc_id(1,"add_new_player", id,race)
			print("global race")
			print(Global.player_race )	
#эта функция вызывается на сервере			
remote func add_new_player(player_unique_id,race1):
	if  player_unique_id == 1:
		return
	if player_unique_id in players:
		if players[player_unique_id]["status"] == "live":
#		var self_data = { "name":'', "position":Vector2(690, 380), "location": 0, "race": 0, "faction":0 , "current_resources":0 }
#		self_data["race"] = race1
#		self_data["faction"] = race1	
			players[player_unique_id]["status"] = "live" #self_data
		#	race1 = players[player_unique_id]["faction"]
			for id in players:
				if id !=0 or id !=player_unique_id:
					rpc_id(id,"spawn_player1", race1)
#на клиенте
remote func spawn_player1(id,race):
	var player_instance = load(player).instance()
	player_instance.name = str(id)
	player_instance.race = race	
	get_node("/root/Map").add_child(player_instance)
	player_instance.global_transform = spawn.global_transform
#	return
#	player_instance.set_network_master(id)

#эта функция вызывается на сервере			
remote func add_new_player1(player_unique_id,race1):
#		var player_unique_id = get_rpc_sender_id()
#	if player_unique_id in players:
#		return
#	Global.player_race = race1
#	spawn_player(player_unique_id,race1)		
#	players[player_unique_id] = self_data
#	var race = int(rand_range(10,10000))
#	players[player_unique_id]["race"] = race1
	race1 = players[player_unique_id]["faction"]
	rpc_id(player_unique_id,"add_new_player2", race1)

#эта функция вызывается на клиенте	
remote func add_new_player2(race1):
	if not get_tree().is_network_server():
#		if is_network_master():
			print("race1")
			print(race1)	
			Global.player_race1 = race1
			print("global race1")
			print(Global.player_race )				
			
func _on_network_peer_disconnected(id):
	if id != 1:
		players.erase(id)
		get_tree().get_root().find_node(str(id), true, false).queue_free()

func _on_connected_to_server():
	load_game()

func _on_server_disconnected():
	get_tree().change_scene(main)
	get_node("/root/Chat").queue_free()
	get_tree().set_network_peer(null)




#Загружаем стартовую локацию с сервера - эта функция выполняется на клиенте
func load_location_from_server(location):
	if not get_tree().is_network_server():
		var player_unique_id = get_tree().get_network_unique_id()
#		var server = get_node("/root/Map/Server_main")
#		var new_location = server.rpc("get_start_location") # удаленный вызов функции на сервере
		var new_location = rpc_id(1,"get_start_location",player_unique_id) # удаленный вызов функции на сервере
		print("New Location")
		print(new_location)
		return new_location
	else:
		print("failed")
		return null
func update_all_data():
	new_creatures_data()
	new_robot_human_data()
	new_robot_roy_data()
	new_bases_data()
	new_robots_data()			
#Эта функция выполнится на сервере
remote func get_start_location(player_unique_id):
	new_creatures_data()
	new_robot_human_data()
	new_robot_roy_data()
	new_bases_data()
	new_robots_data()		
	var cr = Global.creature_data2["Creature_List"]
	var rh = Global.creature_data2["RobotHuman_List"]
	var rr = Global.creature_data2["RobotRoy_List"]
	var bases = Global.creature_data2["Bases_List"]

	rpc_id(player_unique_id, "set_start_location",Global.building_data, cr,rh,rr,bases) #Global.creature_data2)
	return true
func new_bases_data():
		var creatures  = {}
		var i = 0
		var name
		var name2 = "creature"
	
#		var creature_nodes =  get_tree().get_nodes_in_group("bases")  #get_node("/root/Map/Qurrent_Location/Creatures").get_children()
		var creature_nodes = get_node("/root/Map/Qurrent_Location/BaseHuman").get_children()

		for node in creature_nodes:
#			if node.has_method("get_creature_data"):
				name = node.name #name2 + str(i)
				var item = {"name": node.name, "pos": node.global_position,"health": node.health, "faction":node.faction, "race": node.race,"scene_id": 0, "current_resources": node.resource, "max_resources": 100000}

				creatures[name] = item				
				i += 1
		Global.count_base_human  = i
		i = 0
		creature_nodes = get_node("/root/Map/Qurrent_Location/BaseSwarm").get_children()

		for node in creature_nodes:
#			if node.has_method("get_creature_data"):
				name = node.name #name2 + str(i)
				var item = {"name": node.name, "pos": node.global_position,"health": node.health, "faction":node.faction, "race": node.race,"scene_id": 0, "current_resources": node.resource, "max_resources": 100000}

				creatures[name] = item	
				i += 1
		Global.count_base_swarm  = i
		i = 0
		creature_nodes = get_node("/root/Map/Qurrent_Location/Building").get_children()

		for node in creature_nodes:
#			if node.has_method("get_creature_data"):
				name = node.name #name2 + str(i)
				var item = {"name": node.name, "pos": node.global_position,"health": node.health, "faction":node.faction, "race": node.race,"scene_id": 0, "current_resources": node.resource, "max_resources": 100000}

				creatures[name] = item	
				i += 1
		Global.count_base_creatures  = i
		i = 0
		creature_nodes = get_node("/root/Map/Qurrent_Location/BaseNeutral").get_children()

		for node in creature_nodes:
#			if node.has_method("get_creature_data"):
				name = node.name #name2 + str(i)
				var item = {"name": node.name, "pos": node.global_position,"health": node.health, "faction":node.faction, "race": node.race,"scene_id": 0, "current_resources": node.resource, "max_resources": 100000}

				creatures[name] = item	
				i += 1
		Global.count_base_neutral  = i									
		Global.creature_data2["Bases_List"] = creatures
		return creatures	
func new_creatures_data():
		var creatures  = {}
		var i = 0
		var name
		var name2 = "creature"
	
		var creature_nodes = get_node("/root/Map/Qurrent_Location/Creatures").get_children()
		for node in creature_nodes:
#			if node.has_method("get_creature_data"):
				name = node.name #name2 + str(i)
				var item = {"name": node.name, "pos": node.global_position,"health": node.health, "faction":node.faction, "race": node.race}

				creatures[name] = item				
				i += 1
		Global.count_robot_creatures  = i	
		Global.creature_data2["Creature_List"] = creatures
		return creatures	
func new_robot_human_data():
		var creatures  = {}
		var i = 0
		var name
		var name2 = "creature"
	
		var creature_nodes = get_node("/root/Map/Qurrent_Location/RobotHuman").get_children()
		for node in creature_nodes:
#			if node.has_method("get_creature_data"):
				name = node.name #name2 + str(i)
				var item = {"name": node.name, "pos": node.global_position,"health": node.health, "faction":node.faction, "race": node.race}

				creatures[name] = item				
				i += 1
		Global.count_robot_human  = i
		Global.creature_data2["RobotHuman_List"] = creatures
		return creatures	
func new_robot_roy_data():
		var creatures  = {}
		var i = 0
		var name
		var name2 = "creature"
	
		var creature_nodes = get_node("/root/Map/Qurrent_Location/RobotRoy").get_children()
		for node in creature_nodes:
#			if node.has_method("get_creature_data"):
				name = node.name #name2 + str(i)
				var item = {"name": node.name, "pos": node.global_position,"health": node.health, "faction":node.faction, "race": node.race}

				creatures[name] = item				
				i += 1
		Global.count_robot_swarm  = i
		Global.creature_data2["RobotRoy_List"] = creatures
		return creatures	
func new_robots_data():
		var creatures  = {}
		var i = 0
		var name
		var name2 = "creature"
	
		var creature_nodes = get_node("/root/Map/Qurrent_Location/Robots").get_children()
		for node in creature_nodes:
#			if node.has_method("get_creature_data"):
				name = node.name #name2 + str(i)
				var item = {"name": node.name, "pos": node.global_position,"health": node.health, "faction":node.faction, "race": node.race}

				creatures[name] = item				
				i += 1
		Global.count_robot_neutral  = i
		Global.creature_data2["Robots_List"] = creatures
		return creatures
#Эта функция будет вызвана сервером и выполнится на клиенте:
remote func set_start_location(builds,creatures,rh,rr,bases): #Qurrent_Location):
	if not get_tree().is_network_server():
		Global.building_data = builds
		Global.creature_data2["Creature_List"] = creatures		
		Global.creature_data2["RobotHuman_List"] = rh		
		Global.creature_data2["RobotRoy_List"] = rr		
		Global.creature_data2["Bases_List"] = bases		

#		print("Qurrent_Location on client")
#		print(Qurrent_Location)#		var location = Qurrent_Location.unpack() #.instance()	
#		print ("start_location on client")
#
#		print("Qurrent_Location 1 on client")
		var Map = get_node("/root/Map")
		Map._load_building_creatures_from_server()	

func player_want_goto_location(location_id):
	var uid = get_tree().get_network_unique_id()
	rpc_id(1,"get_transfer_player_to_location",location_id,uid) # удаленный вызов функции на сервере	
func get_transfer_player_to_location(location_id,uid):
#	var who_player_id = get_rpc_sender_id()
	pass
#Эта функция выполнится на сервере	
func _send_Creature_Dead(name,type_update):
		for pl in players:
			var health = 0
			if pl != 1:
				if type_update == 0:
					rpc_id(pl,"change_or_remove_creature0",name, health, 1,type_update)
				if type_update == 1:
					rpc_id(pl,"change_or_remove_creature1",name, health, 1,type_update)
				if type_update == 2:
					rpc_id(pl,"change_or_remove_creature2",name, health, 1,type_update)
				if type_update == 3:
					rpc_id(pl,"change_or_remove_creature3",name, health, 1,type_update)
				if type_update == 4:
					rpc_id(pl,"change_or_remove_creature4",name, health, 1,type_update)
				if type_update == 5:
					rpc_id(pl,"change_or_remove_creature5",name, health, 1,type_update)
#				rpc_id(pl,"change_or_remove_creature",name,0, 1,type_update)
#Эта функция выполнится на сервере
func _send_Creature_Update_HP(health,name,type_update):
		for pl in players:
			if pl != 1:
				if type_update == 0:
					rpc_id(pl,"change_or_remove_creature0",name, health, 0,type_update)
				if type_update == 1:
					rpc_id(pl,"change_or_remove_creature1",name, health, 0,type_update)
				if type_update == 2:
					rpc_id(pl,"change_or_remove_creature2",name, health, 0,type_update)
				if type_update == 3:
					rpc_id(pl,"change_or_remove_creature3",name, health, 0,type_update)
				if type_update == 4:
					rpc_id(pl,"change_or_remove_creature4",name, health, 0,type_update)
				if type_update == 5:
					rpc_id(pl,"change_or_remove_creature5",name, health, 0,type_update)
#Эта функция будет вызвана сервером и выполнится на клиенте:
#remote func change_or_remove_creature(name,health,operation,type_update):
#	var creature_nodes
#	if type_update == 0:
#		creature_nodes = get_node("/root/Map/Qurrent_Location/Creatures").get_children()
#	if type_update == 1:
#		creature_nodes = get_node("/root/Map/Qurrent_Location/RobotHuman").get_children()
#	if type_update == 2:
#		creature_nodes = get_node("/root/Map/Qurrent_Location/RobotRoy").get_children()
#	if type_update == 3:
#		creature_nodes = get_node("/root/Map/Qurrent_Location/Building").get_children()
#	if type_update == 4:
#		creature_nodes = get_node("/root/Map/Qurrent_Location/BaseHuman").get_children()
#	if type_update == 5:
#Эта функция будет вызвана сервером и выполнится на клиенте:
remote func change_or_remove_creature0(name,health,operation,type_update):
		var creature_nodes = get_node("/root/Map/Qurrent_Location/Creatures").get_children()

		for node in creature_nodes:
			var name_cr = node.name 
			if name_cr == name: #node.has_method("get_creature_data") and 
				if operation == 0:
					node.update_hp(health)
				if operation == 1:
					node.dead()			
#Эта функция будет вызвана сервером и выполнится на клиенте:
remote func change_or_remove_creature1(name,health,operation,type_update):
		var creature_nodes = get_node("/root/Map/Qurrent_Location/RobotHuman").get_children()

		for node in creature_nodes:
			var name_cr = node.name 
			if name_cr == name: #node.has_method("get_creature_data") and 
				if operation == 0:
					node.update_hp(health)
				if operation == 1:
					node.dead()	
#Эта функция будет вызвана сервером и выполнится на клиенте:
remote func change_or_remove_creature2(name,health,operation,type_update):
		var creature_nodes = get_node("/root/Map/Qurrent_Location/RobotRoy").get_children()

		for node in creature_nodes:
			var name_cr = node.name 
			if name_cr == name: #node.has_method("get_creature_data") and 
				if operation == 0:
					node.update_hp(health)
				if operation == 1:
					node.dead()	
#Эта функция будет вызвана сервером и выполнится на клиенте:
remote func change_or_remove_creature3(name,health,operation,type_update):
		var creature_nodes = get_node("/root/Map/Qurrent_Location/Building").get_children()

		for node in creature_nodes:
			var name_cr = node.name 
			if name_cr == name: #node.has_method("get_creature_data") and 
				if operation == 0:
					node.update_hp(health)
				if operation == 1:
					node.dead()	
#Эта функция будет вызвана сервером и выполнится на клиенте:
remote func change_or_remove_creature4(name,health,operation,type_update):
		var creature_nodes = get_node("/root/Map/Qurrent_Location/BaseHuman").get_children()

		for node in creature_nodes:
			var name_cr = node.name 
			if name_cr == name: #node.has_method("get_creature_data") and 
				if operation == 0:
					node.update_hp(health)
				if operation == 1:
					node.dead()	
#Эта функция будет вызвана сервером и выполнится на клиенте:
remote func change_or_remove_creature5(name,health,operation,type_update):
		var creature_nodes = get_node("/root/Map/Qurrent_Location/BaseSwarm").get_children()

		for node in creature_nodes:
			var name_cr = node.name 
			if name_cr == name: #node.has_method("get_creature_data") and 
				if operation == 0:
					node.update_hp(health)
				if operation == 1:
					node.dead()						
func create_robot(faction,pos,type,robot_name):
		rpc("create_robot0",faction,pos,type,robot_name)	
func create_special_robot(faction,pos,type,robot_name):
		rpc("create_special_robot0",faction,pos,type,robot_name)
		
#Эта функция будет вызвана сервером и выполнится на клиенте:
remote func create_special_robot0(faction,pos,type,robot_name):
	if not get_tree().is_network_server():
		var Map = get_node("/root/Map")
		Map.create_special_robot1(faction,pos,type,robot_name)
#Эта функция будет вызвана сервером и выполнится на клиенте:
remote func create_robot0(faction,pos,type,robot_name):
	if not get_tree().is_network_server():
		var Map = get_node("/root/Map")
		Map.create_robot1(faction,pos,type,robot_name)
#Эта функция выполнится на клиенте		
func create_bullet_player(faction,pos,rotation,type):
		rpc_id(1,"create_bullet_player0",faction,pos,rotation,type)	
#Эта функция выполнится на сервере		
remote func create_bullet_player0(faction1,pos,rotation,type1):
	if type1 == 2:
#		print("faction")
#		print(faction1)
		if faction1 > 100:#and Global.player_resource < 5:
			var res = decrease_resource_player(faction1,10)
			if !res:
				return
	if type1 == 3:
		print("faction")
		print(faction1)		
		if faction1 > 100:#and Global.player_resource < 100:
			var res = decrease_resource_player(faction1,40)
			if !res:
				return
	if type1 == 4:
#		print("faction")
#		print(faction1)
		if faction1 > 100:#and Global.player_resource < 5:
			var res = decrease_resource_player(faction1,150)
			if !res:
				return
	if type1 == 5:
#		print("faction")
#		print(faction1)
		if faction1 > 100:#and Global.player_resource < 5:
			var res = decrease_resource_player(faction1,450)
			if !res:
				return
	if type1 == 6:
		print("faction")
		print(faction1)		
		if faction1 > 100:#and Global.player_resource < 100:
			var res = decrease_resource_player(faction1,500)
			if !res:
				return								
#	else:
	var uuid = int(randi())
	var Map = get_node("/root/Map")
	Map.create_bullet_player1(faction1, pos, rotation, type1,uuid)	
	rpc("create_bullet_player2", faction1, pos, rotation, type1,uuid)
func decrease_resource_player(faction1,res):
	var result = false
	for pl in players:

		print("need faction ",faction1)
		print("player recources ",players[pl]["current_resources"])
		print("player faction ",players[pl]["faction"])
		if players[pl]["faction"] == faction1:
			print("player faction1 ",players[pl]["faction"])			
			if players[pl]["current_resources"] >= res:
				print("player recources ",players[pl]["current_resources"])
				players[pl]["current_resources"] -= res
				print("player recources ",players[pl]["current_resources"])
				return true


	return result
#Эта функция будет вызвана сервером и выполнится на клиенте:
remote func create_bullet_player2(faction,pos,rotation,type,uuid):
	if not get_tree().is_network_server():
		var Map = get_node("/root/Map")
		Map.create_bullet_player1(faction,pos,rotation,type,uuid)
func get_players_position(pos):
		var player_nodes = get_tree().get_nodes_in_group("player") #get_node("/root/Map").get_children()
		for pl in player_nodes:

#		for pl in players:
#			if pl != 1:
				var pl1 = pl.position
				var distance = pos.distance_to(pl1)

				if distance < 600:
#					print("distance")
#					print(distance)				
					return pl1
		return null		

#Эта функция выполнится на сервере	
func update_resource(res):
	if get_tree().is_network_server():
		update_all_data()
		var i = 0
		for player_unique_id in players:
			if player_unique_id != 1:
				var resource = 	players[player_unique_id]["current_resources"] 
#				print("Player1 id, res")
#				print (player_unique_id," ", resource)
#				print("Player N:")
#				print(i)
#				print ("player faction & resource")
#				print(players[player_unique_id]["faction"])
#				print (Network.players[player_unique_id]["current_resources"])				
				var result = [resource,Global.count_robot_human,Global.count_base_human,Global.count_robot_swarm,Global.count_base_swarm,Global.count_robot_creatures,Global.count_base_creatures]
				rpc_id(player_unique_id,"update_resource_client", result)
				i +=1	
#Эта функция будет вызвана сервером и выполнится на клиенте:		
remote func update_resource_client(result):
	if not get_tree().is_network_server():
		var Map = get_node("/root/Map")
		Map.update_resources(result)								

#Эта функция выполнится на сервере
func _send_position_robot_swarm(pos,uuid):
	if get_tree().is_network_server():
		for pl in players:
			var health = 0
			if pl != 1:
				rpc_id(pl,"set_new_position_robot_swarm",pos,uuid)
remote func set_new_position_robot_swarm(pos,uuid):
	if not get_tree().is_network_server():
		var creature_nodes = get_node("/root/Map/Qurrent_Location/RobotRoy").get_children()
		for node in creature_nodes:
			if node.has_method("set_new_position_robot_swarm") and node.uuid == uuid:
				node.set_new_position_robot_swarm(pos)
				return
#Функции ниже сейчвс не используются
func get_IP():
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168."):
			return ip
func get_target_position2(pos,faction):
	var player_nodes	
	if Global.player_stealth_off:
		player_nodes = get_tree().get_nodes_in_group("player") #get_node("/root/Map").get_children()
		for pl in player_nodes:

#		for pl in players:
#			if pl != 1:
				var faction_target = pl.faction
				var pl1 = pl.global_position
				var distance = pos.distance_to(pl1)

				if distance < 600:
#					print("distance")
#					print(distance)				
					return [pl1,faction_target]
	player_nodes = get_tree().get_nodes_in_group("robot_human") #get_node("/root/Map").get_children()
	for pl in player_nodes:

#		for pl in players:
#			if pl != 1:
				var faction_target = pl.faction
				var pl1 = pl.global_position
				var distance = pos.distance_to(pl1)

				if distance < 600:
#					print("distance")
#					print(distance)				
					return  [pl1,faction_target]				
	return null #Vector2(-100000,-100000)#Global.player_id.position
