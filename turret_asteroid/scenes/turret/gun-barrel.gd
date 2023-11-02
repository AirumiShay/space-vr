extends Node2D

var _bullet = preload("res://turret_asteroid/scenes/bullets/basic-bullet.tscn")
var _smoke1 = preload("res://turret_asteroid/scenes/turret/smoke1.tscn")
var _smoke2 = preload("res://turret_asteroid/scenes/turret/smoke2.tscn")
var _bulletSpeed = 2000

func _ready():
	var gunBarrelNum = Common.Rand(1, 2)
	var icon = load("res://turret_asteroid/assets/turret/GunBarrel" + str(gunBarrelNum) + ".png")
	$Sprite.set_texture(icon)

func Shoot(turretRotation):
	var bulletInstance = _bullet.instance()
	bulletInstance.position = position
	bulletInstance.position.x += 4
	bulletInstance.apply_impulse(Vector2(), Vector2(_bulletSpeed, 0).rotated(turretRotation))
	call_deferred("add_child", bulletInstance)
	Bang()
	Kick()
	Smoke1(turretRotation)

func Bang():
	# TODO: Add sound
	$AudioStreamPlayer.play()
	
func Kick():
	$AnimationPlayer.play("Kick")
	
func Smoke1(turretRotation):
	var smoke = _smoke1.instance()
	smoke.global_position = global_position
	smoke.rotation = turretRotation
	get_tree().get_root().call_deferred("add_child", smoke)
	smoke.Play()

func Smoke2(turretRotation):
	var smoke = _smoke2.instance()
	smoke.global_position = global_position
	smoke.rotation = turretRotation
	get_tree().get_root().call_deferred("add_child", smoke)
	smoke.Play()
