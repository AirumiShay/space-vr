extends Area2D

var damaged = false
var damage = 1000
var faction = 0
# Called when the node enters the scene tree for the first time.
func _ready():
#	print("damage Begin")
#	$Timer.start(0.1)
	faction =  get_parent().faction
func set_damage(dmg):
	damage = dmg



#func _process(_delta):
func _attack_true():
#	print("Archer search attack")	
#	if not damaged and get_overlapping_bodies() != []:
	if get_overlapping_bodies() != []:
#		print("Archer found attack")	
		for i in get_overlapping_bodies():
			if i in get_tree().get_nodes_in_group("player"):
#				print(i)
				print("SWARM  check area attack player")
				$DamageSprite.visible = true
				i.reduce_hp(damage,faction)
				return {"target":true, "what_target":i.position}
			if i in get_tree().get_nodes_in_group("bases_human"):
#				print(i)
#		print("Archer check area attack")
				print("SWARM  check area attack bases_human")
				$DamageSprite.visible = true
				i.reduce_hp(damage,faction)
			if i in get_tree().get_nodes_in_group("bases_creature"):
#				print(i)
#		print("Archer check area attack")
				print("SWARM  check area attack bases_creature")
				$DamageSprite.visible = true
				i.reduce_hp(damage,faction)
				return {"target":true, "what_target":i.position}				
			if i in get_tree().get_nodes_in_group("robot_human"):
				print("SWARM  check area attack robot_human")
				$DamageSprite.visible = true
				i.reduce_hp(damage,faction) # наносим урон всем , кто в зоне  DamageArea
				return {"target":true, "what_target":i.position}
#				print("Archer endattack")
#		damaged = true
			if i in get_tree().get_nodes_in_group("creatures"):
				print("SWARM  check area attack creature")
				$DamageSprite.visible = true
				i.reduce_hp(damage,faction) # наносим урон всем , кто в зоне  DamageArea
				return {"target":true, "what_target":i.position}
		return 	 {"target":false}	
	return 	 {"target":false}
#func _on_Timer_timeout():
#	print("damage end")
#	get_parent().remove_child(self)
#	queue_free()
