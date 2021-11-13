extends CanvasLayer

func _ready():
	WorldGlobals.connect("world_time_update", self, "update_time")
	pass # Replace with function body.

func _process(delta):
	pass

func update_time(hour, minute):
	$TimeLabel.text = str("Time: ", hour, ":", minute)
