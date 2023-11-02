extends Area2D
var faction = 0
var uid = 0
var race1 = 0
func _ready():
	uid = get_parent().get_uid()
	race1 = get_parent().get_race()
	faction = get_parent().faction	
func get_uid():
	get_parent().get_uid()
func get_faction():
	return get_parent().faction		
func reduce_hp(a, uid):
	if get_tree().is_network_server():	
		if Global.HardMode == false and uid != race1:
			get_parent().reduce_hp(a,uid)
func _process(delta):
	if is_network_master():		
#		FireBullet1()	
		look_at(get_global_mouse_position())
func Spell_Action1():
		get_parent().FireEnable = false
		get_parent().get_node("FireTimer").start(0.5)		
		var bull = get_parent().bullet.instance()
	#	var uid_bull = randi()
		bull.set_uid(get_parent().race,Global.player_id)
		bull.dir = rotation
		bull.rotation = rotation
		bull.global_position = get_parent().get_node("Player_Position").position
		get_parent().add_child(bull)
func FireBullet1():
	if Input.is_action_pressed("fire2") and get_parent().FireEnable == true:
#		get_parent().Spell_Action()
		Spell_Action1()


func _on_Area2D_area_exited(area):
	pass
	
