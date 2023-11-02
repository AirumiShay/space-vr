extends Node2D

onready var _impactParticleScene = preload("res://turret_asteroid/scenes/impact-particle/impact-particle.tscn")

func _ready():
	Signals.connect("BulletImpact", self, "BulletImpact")

func BulletImpact(bulletLocation):
	var impactParticle = _impactParticleScene.instance()
	$ParticleCollection.add_child(impactParticle)
	impactParticle.global_position = bulletLocation
