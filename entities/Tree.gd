extends StaticBody2D

enum {
	GROW0 = 0,
	GROW1 = 1,
	GROW2 = 2,
	GROW3 = 3,
	STAND = 4,
	FALLEN = 5,
	DEAD
}

export(int) var tree_type = 0
export(int) var hitpoints = 3

const tileset_width = 12#$TreeSprite/Bottom.get("hframes")
var sprite_frame_base = 0
var season_frame_base = 0
var sprite_start_y = 0

var state = GROW0 setget set_state
var season = WorldGlobals.WINTER setget set_season


# Called when the node enters the scene tree for the first time.
func _ready():
	sprite_start_y = tree_type * 9 * 32
	sprite_frame_base = tree_type * 9 * tileset_width
	set_season(season)

func set_season(_season):
	season = _season
	$TreeSprite/Top.region_rect = Rect2(season * 32 * 3, sprite_start_y, 32 * 3, 160)
	season_frame_base = sprite_frame_base + 3 * season
	$TreeSprite/Bottom.frame = season_frame_base + 6*tileset_width + 1
	
	set_state(state)

func upgrade_state():
	match state:
		GROW0:
			set_state(GROW1)
		GROW1:
			set_state(GROW2)
		GROW2:
			set_state(GROW3)
		GROW3:
			set_state(STAND)
		STAND:
			$AnimationPlayer.play("Fall")
			set_state(FALLEN)
		FALLEN:
			pass

func set_state(_state):
	state = _state
	$TreeSprite/Top.visible = (state == STAND)
	$TreeSprite/Bottom2.visible = (state == FALLEN or state == GROW3)
	match state:
		GROW0:
			$TreeSprite/Bottom.frame = season_frame_base + 7*tileset_width
		GROW1:
			$TreeSprite/Bottom.frame = season_frame_base + 7*tileset_width + 1
		GROW2:
			$TreeSprite/Bottom.frame = season_frame_base + 7*tileset_width + 2
		GROW3:
			$TreeSprite/Bottom.frame = season_frame_base + 6*tileset_width + 2
			$TreeSprite/Bottom2.frame = season_frame_base + 5*tileset_width + 2
			print($TreeSprite/Bottom.frame_coords)
			print($TreeSprite/Bottom2.frame_coords)
		STAND:
			$TreeSprite/Bottom.frame = season_frame_base + 6*tileset_width + 1
		FALLEN:
			$TreeSprite/Bottom.frame = season_frame_base + 6*tileset_width + 1
			$TreeSprite/Bottom2.frame = $TreeSprite/Bottom.frame - tileset_width
