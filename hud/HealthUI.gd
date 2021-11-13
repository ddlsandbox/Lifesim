extends Control

onready var heartUI0 = $Heart0
onready var heartUI1 = $Heart1

var hearts setget set_hearts
var max_hearts setget set_max_hearts

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heartUI1 != null:
		heartUI1.rect_size.x = hearts * 32

func set_max_hearts(value):
	max_hearts = max(value, 1)
	if heartUI0 != null:
		heartUI0.rect_size.x = max_hearts * 32

func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.connect("health_changed", self, "set_hearts")
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
