extends Node

export(int) var max_health = 10 setget set_max_health
var health setget set_health

signal no_health
signal health_changed(value)
signal max_health_changed(value)

func set_health(value):
	health = min(value, max_health)
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_changed", health)

func _ready():
	self.health = 3.5# max_health
