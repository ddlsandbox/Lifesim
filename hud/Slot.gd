extends Panel

var default_texture = preload("res://hud/slot.png")
var disabled_texture = preload("res://hud/slot_dis.png")

var default_style: StyleBoxTexture = null
var disabled_style: StyleBoxTexture = null

var ItemClass = preload("res://items/Item.tscn")
var item = null

func _ready():
	default_style = StyleBoxTexture.new()
	disabled_style = StyleBoxTexture.new()
	default_style.texture = default_texture
	disabled_style.texture = disabled_texture
	
	if randi() % 2 == 0:
		item = ItemClass.instance()
		add_child(item)
	refresh_style()

func refresh_style():
	if item == null:
		set('custom_styles/panel', disabled_style)
	else:
		set('custom_styles/panel', default_style)

func pickFromSlot():
	remove_child(item)
	var inventoryNode = find_parent("Inventory")
	inventoryNode.add_child(item)
	item = null
	refresh_style()

func putIntoSlot(new_item):
	item = new_item
	item.position = Vector2(0,0)
	var inventoryNode = find_parent("Inventory")
	inventoryNode.remove_child(item)
	add_child(item)
	refresh_style()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
