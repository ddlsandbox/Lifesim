extends Node2D

func _ready():
	if randi() % 2 == 0:
		$TextureRect.texture = load("res://hud/hearts0.png")
	else:
		$TextureRect.texture = load("res://hud/hearts1.png")
