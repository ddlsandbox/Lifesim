extends TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func is_cell_vacant(pos, direction = null) -> bool:
	return true

func update_child_pos(child, new_pos, direction):
	pass
