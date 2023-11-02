extends Node

signal BulletImpact
var type_update_creature = 0
var type_update_robot_human = 1
var type_update_robot_swarm = 2
var type_update_base_creature =3
var type_update_base_human = 4
var type_update_base_swarm = 5
var swarm_race = 9
var creature_race = 10
var HardMode = false
var player_id = Vector2(0,0)
var player_uid = 0
var player_max_health = 1000
var player_stealth_off = true
var player_race = 0
var player_race1 = 0
var player_live_status = true
var Lifetime = {
	"Creature":150,
	"RobotHuman":100,
	"RobotSwarm":100,
	"RobotRoy":100
}
var creature_data2 = {
	"Creature_List":{},
	"RobotHuman_List":{},
	"RobotRoy_List":{},
	"Bases_List":{},
	"Robots_List":{}	
}
var creature_data1 = {
	"Creature_List":{
	"creature1": {"pos": Vector2(50, 50),"health":100},
	"creature2": {"pos": Vector2(150, 150),"health":90},
	"creature3": {"pos": Vector2(250, 250),"health":70},
	"creature4": {"pos": Vector2(350, 350),"health":90},
	"creature5": {"pos": Vector2(450, 450),"health":95},
	"creature6": {"pos": Vector2(550, 550),"health":40},
	"creature7": {"pos": Vector2(650, 650),"health":30},
	"creature8": {"pos": Vector2(750, 550),"health":60},
	"creature9": {"pos": Vector2(850, 450),"health":50},
	"creature10": {"pos": Vector2(950, 350),"health":90},
	"creature11": {"pos": Vector2(1050, 250),"health":95},
	"creature12": {"pos": Vector2(1150, 150),"health":70},
	"creature13": {"pos": Vector2(1250, 50),"health":80},
	"creature14": {"pos": Vector2(1350, 20),"health":29},
	"creature15": {"pos": Vector2(1450, 630),"health":90},
	}
}
var building_data = {}
var creatures = []
var count_robot_human = 0
var count_base_human = 0
var count_robot_swarm = 0
var count_base_swarm = 0
var count_robot_creatures = 0
var count_base_creatures = 0
var count_robot_neutral = 0
var count_base_neutral= 0
var player_resource = 500
func Rand(low, high):
	return round(rand_range(low, high))

