extends Node

enum {
	SPRING = 0,
	SUMMER = 1,
	AUTUMN = 2,
	WINTER = 3
}

var time
var season = SPRING
var day = 1
var hour = 12
var minute = 0

signal world_time_update(hour, minute)

func _ready():
	$WorldTimer.wait_time = 1
	$WorldTimer.start()
	pass # Replace with function body.

func _process(delta):
	pass

func get_time() -> int:
	return hour*60 + minute

func _on_WorldTimer_timeout():
	minute += 1
	if minute == 60:
		minute = 0
		hour = (hour + 1) % 24
	emit_signal("world_time_update", hour, minute)
