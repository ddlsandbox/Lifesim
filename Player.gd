extends KinematicBody2D

enum {
	MOVE,
	USE_TOOL,
	ATTACK
}
const Direction = {
	NONE = -1,
	DOWN = 0,
	UP = 1,
	LEFT = 2,
	RIGHT = 3
	}

signal path_end

var path := PoolVector2Array() setget set_path
var stats = PlayerStats
var state = MOVE

onready var bodySprite = $CompositeSprite/Body
onready var clothesSprite = $CompositeSprite/Clothes
onready var armsSprite = $CompositeSprite/Arms
onready var hairSprite = $CompositeSprite/Hair
onready var pantsSprite = $CompositeSprite/Pants

onready var animation = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

export var speed = 5000.0
var hairFrame
var clothesFrame
var velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	# temp connect to queue_free
	stats.connect("no_health", self, "queue_free")
	
	hairFrame = hairSprite.frame
	clothesFrame = clothesSprite.frame
	hairSprite.modulate = Color(0,1,1)
	pantsSprite.modulate = Color(1,0,1)
	pass # Replace with function body.

func _process(delta: float) -> void:
	var move_distance = 100 * delta
	move_along_path(delta)

func move_player(delta, inputVector):
	if inputVector != Vector2.ZERO:
		animationTree.set("parameters/Idle/blend_position", inputVector)
		animationTree.set("parameters/Walk/blend_position", inputVector)
		animationTree.set("parameters/UseTool/blend_position", inputVector)
		animationState.travel("Walk")
		velocity = inputVector * speed
	else:
		velocity = Vector2.ZERO
		animationState.travel("Idle")
	
	move_and_slide(velocity * delta)
	
	if path.size() == 0 and Input.is_action_just_pressed("ui_select"):
		state = USE_TOOL

func move_state(delta):
	var inputVector = Vector2.ZERO
	inputVector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	inputVector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	inputVector = inputVector.normalized()
	
	if path.size() == 0:
		move_player(delta, inputVector)
	elif inputVector != Vector2.ZERO:
		# clear path
		while path.size() > 0:
			path.remove(0)

func use_tool_state(delta):
	animationState.travel("UseTool")

func animation_finished():
	state = MOVE
	animationState.travel("Idle")

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		USE_TOOL:
			use_tool_state(delta)
		ATTACK:
			pass

func set_path(value : PoolVector2Array):
	if state != MOVE:
		return false
	
	path = value
	if value.size() == 0:
		return
	set_process(true)
	return true

func move_along_path(delta):
	var start_point = global_position
	if path.size() > 0:
		var next_position = path[0]
		var distance = start_point.distance_to(next_position)
		if (distance > 0):
			var direction = start_point.linear_interpolate(next_position, speed*delta / distance) - start_point
			direction = direction.normalized()
			
			var sign_x = global_position.x > next_position.x
			var sign_y = global_position.y > next_position.y
			move_player(delta, direction)
			if (sign_x != (global_position.x > next_position.x) 
			   or sign_y != (global_position.y > next_position.y) 
			   or (abs(start_point.x - next_position.x) <= 1.0 
				   and abs(start_point.y - next_position.y) <= 1.0)
			  or (distance == global_position.distance_to(next_position))):
				path.remove(0)
		else:
			path.remove(0)
		if path.size() == 0:
			emit_signal("path_end")
	else:
		set_process(false)
