extends StaticBody2D
var shield = 1
var health = 1000
var max_health = 1000
var faction = 8 # фракция
var new_faction #фракция того игрока, который сейчас захватывает базу
var resource = 0
var hp1 = 100
var race = 1
var capture_count = 0 #таймер захвата базы
var capturing = false #идёт захват базы?
var playing_capture2 = false # играет звук захвата базы?
var playing_capture = 2 # играет звук захвата базы?
var uuid = 0 # уникальный номер объекта в игровом мире
func _ready():
		$HP_bar.value = int(health)	
		Global.count_base_creatures += 1	
		var a = get_node("/root/Map/UI/UI/STATS/BasesCreature")	
		a.text = "GB: " + str(Global.count_base_creatures)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
remote func update_building_stats(res,hp):
	resource = res
	$Resource.text = str(resource)
	self.hp = hp
func reduce_hp(a,race1):
	if race1 != race:
		if race1 == Global.swarm_race:
				print("swarm attack  base creature")
				health -= 0.1 * max_health		
		health -= shield
		$HP_bar.value = int(health)	
		if health < 0:

#			Global.count_base_human -= 1
#			get_node("/root/Map/UI/UI/STATS/Bases").text = "BASES: " + str(Global.count_base_human)			
			queue_free()
func dead():
#	print("creatures_dead=======================================")
#	print(self.name)		
	if not get_tree().is_network_server():
		Global.count_base_creatures -= 1
		var a = get_node("/root/Map/UI/UI/STATS/BasesCreature")		
		a.text = "GB: " + str(Global.count_base_creatures)			
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


func _on_CaptureTimer_timeout():
	start_capture()
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
#		$Play/Play2.play(0.0)


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
	




func _on_Base_Human_area_entered(area):
	if "Player" in area.name: #.is_in_group("player"):
		var f = area.get_faction()
		if f == faction:
			return
		else:	
			capturing = true
			new_faction = f
#			create_timer_capture(new_faction)
#func create_timer_capture(new_faction):
			$CaptureTimer.start(1)	
