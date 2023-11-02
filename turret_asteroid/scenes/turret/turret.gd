extends KinematicBody2D

var movespeed = 500
var _gun1Ready = true
var _gun2Ready = false

func _physics_process(_delta):
	var motion = Vector2()
	if Input.is_action_pressed("up"):
		motion.y -= 1
	if Input.is_action_pressed("down"):
		motion.y += 1
	if Input.is_action_pressed("right"):
		motion.x += 1
	if Input.is_action_pressed("left"):
		motion.x -= 1
		
	motion = motion.normalized()
	motion = move_and_slide(motion * movespeed)
	
	look_at(get_global_mouse_position())

	if Input.is_action_pressed("lmb"):
		fire1()
		fire2()
		
func fire1():
	if !_gun1Ready:
		return
	_gun1Ready = false
		
	$GunBarrel1.Shoot(self.rotation)
	$GunTimer1.start()
	
func fire2():
	if !_gun2Ready:
		return
	_gun2Ready = false
		
	$GunBarrel2.Shoot(self.rotation)
	$GunTimer2.start()

func _on_GunTimer1_timeout():
	_gun2Ready = true

func _on_GunTimer2_timeout():
	_gun1Ready = true
