extends CanvasModulate

func _ready():
	WorldGlobals.connect("world_time_update", self, "update_time")
	$DayNightAnimation.play("DayCycleSpring", -1, 0)
	
func _process(delta):
	pass

func update_time(hour, minute):
	var CurrentFrame = range_lerp(WorldGlobals.get_time(),0,1440,0,24)
	$DayNightAnimation.play("DayCycleSpring", -1, 0)
	$DayNightAnimation.seek(CurrentFrame)
