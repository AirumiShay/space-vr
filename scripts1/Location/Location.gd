extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var players = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Список игроков на общей сцене игры
class PlayersOnGameScene:
	var players = []

	func add_player(player):
		players.append(player)

	func remove_player(player):
		players.erase(players.find(player))

	func get_players():
		return players

# Список игроков на сцене локации данжа
class PlayersOnDungeonScene  extends Node:
	var players = []

	func add_player(player):
		players.append(player)

	func remove_player(player):
		players.erase(players.find(player))

	func get_players():
		return players
#	func sync_player_position(player_scene):
#		for player in players:
#			if player != player_scene:
#				player_scene.rpc_id(player.get_network_master(),"update_player_position", player_scene.get_network_master().get_peer_id(), player_scene.get_translation())

	# Синхронизация позиции игрока на сцене локации данжа
	func sync_player_position(player_scene):
		for player in players:
			if player != player_scene:

				rpc_id(player.get_network_master(), "update_player_position", player_scene.get_network_master().get_peer_id(), player_scene.get_translation())
# Сцена локации данжа
class DungeonScene:
	var players_on_dungeon_scene = PlayersOnDungeonScene.new()

	# Добавление игрока на сцену локации данжа
	func add_player(player_scene):
		players_on_dungeon_scene.add_player(player_scene)

	# Удаление игрока со сцены локации данжа
	func remove_player(player_scene):
		players_on_dungeon_scene.remove_player(player_scene)
# Общая сцена игры
class GameScene  extends Node:
	var players_on_game_scene = PlayersOnGameScene.new()
	var dungeon_scenes = []

	# Добавление ...сцены локации данжа в список
	func add_dungeon_scene(dungeon_scene):
		dungeon_scenes.append(dungeon_scene)

	# Удаление сцены локации данжа из списка
	func remove_dungeon_scene(dungeon_scene):
		dungeon_scenes.erase(dungeon_scenes.find(dungeon_scene))

	# Добавление игрока на общую сцену игры
	func add_player(player_scene):
		players_on_game_scene.add_player(player_scene)

	# Удаление игрока с общей сцены игры
	func remove_player(player_scene):
		players_on_game_scene.remove_player(player_scene)

		# Удаление игрока со всех сцен локаций данжей
		for dungeon_scene in dungeon_scenes:
			dungeon_scene.remove_player(player_scene)

	# Синхронизация игрока на общей сцене игры
	func sync_player_on_game_scene(player_scene):
		for player in players_on_game_scene.get_players():
			if player != player_scene:
				rpc_id(player.get_network_master(), "update_player_on_game_scene", player_scene.get_network_master().get_peer_id(), player_scene.get_translation())

	# Синхронизация игрока на сцене локации данжа
	func sync_player_on_dungeon_scene(player_scene):
		for dungeon_scene in dungeon_scenes:
			if player_scene in dungeon_scene.players_on_dungeon_scene.get_players():
				dungeon_scene.players_on_dungeon_scene.sync_player_position(player_scene)

# Игрок на сцене локации данжа
class PlayerOnDungeonScene  extends Node:
	func _ready():
		# Добавление игрока на сцену локации данжа при загрузке сцены
		get_node("/root/GameScene").dungeon_scenes[0].add_player(self)

	func _on_PlayerOnDungeonScene_destroyed():
		# Удаление игрока со сцены локации данжа при уничтожении игрока
		get_node("/root/GameScene").remove_player(self)

		# Удаление игрока со сцены локации данжа при уничтожении игрока
		get_node("/root/GameScene").remove_player(self)


		# Удаление игрока со сцены локации данжа при уничтожении игрока
		get_node("/root/GameScene").dungeon_scenes[0].remove_player(self)

	# Синхронизация позиции игрока на сцене локации данжа
	func sync_position_on_dungeon_scene():
		get_node("/root/GameScene").sync_player_on_dungeon_scene(self)

# Игрок на общей сцене игры
class PlayerOnGameScene  extends Node:
	func _ready():
		# Добавление игрока на общую сцену игры при загрузке сцены
		get_node("/root/GameScene").add_player(self)

	func _on_PlayerOnGameScene_destroyed():
		# Удаление игрока с общей сцены игры при уничтожении игрока
		get_node("/root/GameScene").remove_player(self)

	# Синхронизация позиции игрока на общей сцене игры
	func sync_position_on_game_scene():
		get_node("/root/GameScene").sync_player_on_game_scene(self)


var mini_game_1_scene
var mini_game_2_scene
var mini_game_3_scene
# Список игроков на общей сцене
var players_on_game_scene = []

# Список игроков на каждой сцене локаций данжей
var players_on_dungeon_1_scene = []
var players_on_dungeon_2_scene = []
var players_on_dungeon_3_scene = []
	# Синхронизация позиции игрока на сцене локации данжа
func sync_player_position(player_scene):
		for player in players:
			if player != player_scene:

				rpc_id(player.get_network_master(), "update_player_position", player_scene.get_network_master().get_peer_id(), player_scene.get_translation())

# Добавление игрока на общую сцену
func add_player_on_game_scene_list(player_scene):
	players_on_game_scene.append(player_scene)

# Удаление игрока с общей сцены
func remove_player_on_game_scene_list(player_scene):
	players_on_game_scene.remove(player_scene)

# Добавление игрока на сцену локации данжа
func add_player_on_dungeon_scene_list(player_scene, dungeon_scene):
	if dungeon_scene == mini_game_1_scene:
		players_on_dungeon_1_scene.append(player_scene)
	elif dungeon_scene == mini_game_2_scene:
		players_on_dungeon_2_scene.append(player_scene)
	elif dungeon_scene == mini_game_3_scene:
		players_on_dungeon_3_scene.append(player_scene)

# Удаление игрока с сцены локации данжа
func remove_player_on_dungeon_scene_list(player_scene, dungeon_scene):
	if dungeon_scene == mini_game_1_scene:
		players_on_dungeon_1_scene.remove(player_scene)
	elif dungeon_scene == mini_game_2_scene:
		players_on_dungeon_2_scene.remove(player_scene)
	elif dungeon_scene == mini_game_3_scene:
		players_on_dungeon_3_scene.remove(player_scene)

# Перемещение игрока на сцену локации данжа
func goto_dungeon(dungeon_scene0):
	# Получаем текущую сцену игрока
	var player_scene = get_node("PlayerScene")
	# Получаем сцену данжа
	var dungeon_scene = load(dungeon_scene0).instance()
	
	# Удаляем игрока из списка игроков на общей сцене
	remove_player_on_game_scene(player_scene)
	
	# Добавляем игрока в список игроков на сцене данжа
	add_player_on_dungeon_scene(player_scene, dungeon_scene)
	
	# Создаем новую сцену для игрока на сцене данжа
	var new_player_scene = player_scene.duplicate()
	dungeon_scene.add_child(new_player_scene)
	
	# Устанавливаем текущую сцену игрока на сцену данжа
	get_tree().set_current_scene(dungeon_scene)
	
	# Добавляем игрока на сцену данжа
	add_player_on_dungeon_scene(new_player_scene, dungeon_scene)
	
	# Синхронизируем игрока с другими клиентами
	rpc("sync_player_on_dungeon_scene", new_player_scene, dungeon_scene)

# Синхронизация добавления игрока на сцену локации данжа
func sync_add_player_on_dungeon_scene(player_scene, dungeon_scene):
	add_player_on_dungeon_scene(player_scene, dungeon_scene)
	rpc("sync_add_player_on_dungeon_scene", player_scene, dungeon_scene)

# Синхронизация удаления игрока с сцены локации данжа
func sync_remove_player_on_dungeon_scene(player_scene, dungeon_scene):
	remove_player_on_dungeon_scene(player_scene, dungeon_scene)
	rpc("sync_remove_player_on_dungeon_scene", player_scene, dungeon_scene)

# Синхронизация удаления игрока с общей сцены
func sync_remove_player_on_game_scene(player_scene):
	remove_player_on_game_scene(player_scene)
	rpc("sync_remove_player_on_game_scene", player_scene)

# Синхронизация игрока на сцене локации данжа
func sync_player_on_dungeon_scene(player_scene, dungeon_scene):
	# Синхронизируем позицию игрока
	if dungeon_scene == mini_game_1_scene:
		players_on_dungeon_1_scene.sync_player_position(player_scene)
	elif dungeon_scene == mini_game_2_scene:
		players_on_dungeon_2_scene.sync_player_position(player_scene)
	elif dungeon_scene == mini_game_3_scene:
		players_on_dungeon_3_scene.sync_player_position(player_scene)
	rpc("sync_player_on_dungeon_scene", player_scene, dungeon_scene)

#  Синхронизация игрока на общей сцене
func sync_player_on_game_scene(player_scene):
	players_on_game_scene.sync_player_position(player_scene)
	rpc("sync_player_on_game_scene", player_scene)

# Добавление игрока на сцену данжа
func add_player_on_dungeon_scene(player_scene, dungeon_scene):
	if dungeon_scene == mini_game_1_scene:
		players_on_dungeon_1_scene.add_player(player_scene)
	elif dungeon_scene == mini_game_2_scene:
		players_on_dungeon_2_scene.add_player(player_scene)
	elif dungeon_scene == mini_game_3_scene:
		players_on_dungeon_3_scene.add_player(player_scene)

# Удаление игрока с сцены локации данжа
func remove_player_on_dungeon_scene(player_scene, dungeon_scene):
	if dungeon_scene == mini_game_1_scene:
		players_on_dungeon_1_scene.remove_player(player_scene)
	elif dungeon_scene == mini_game_2_scene:
		players_on_dungeon_2_scene.remove_player(player_scene)
	elif dungeon_scene == mini_game_3_scene:
		players_on_dungeon_3_scene.remove_player(player_scene)

# Удаление игрока с общей сцены
func remove_player_on_game_scene(player_scene):
	players_on_game_scene.remove_player(player_scene)

# Синхронизация игроков на сцене данжа
func sync_players_on_dungeon_scene(dungeon_scene):
	if dungeon_scene == mini_game_1_scene:
		players_on_dungeon_1_scene.sync_players()
	elif dungeon_scene == mini_game_2_scene:
		players_on_dungeon_2_scene.sync_players()
	elif dungeon_scene == mini_game_3_scene:
		players_on_dungeon_3_scene.sync_players()

# Синхронизация игроков на общей сцене
func sync_players_on_game_scene():
	players_on_game_scene.sync_players()
