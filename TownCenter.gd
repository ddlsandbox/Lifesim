extends Node2D

onready var camera = $MainCamera
onready var nav_2d = $Navigation
onready var character = $Entities/Player
onready var line_2d = $Line2D
onready var tilemap = $Navigation/NavTileMap
onready var world_grid = $WorldGrid
onready var click_timer = $ClickTimer

const TreeClass = preload("res://entities/Tree.tscn")

var PositionMarkClass = preload("res://world/PositionMark.tscn")
var positionMark = null

# Called when the node enters the scene tree for the first time.
func _ready():
	var ref_nav_tile = $Ground1.tile_set.autotile_get_navigation_polygon(0, Vector2(0,0))
	rand_seed(42)
	for i in range(0,30):
		var tree = TreeClass.instance()
		var treepos = 0
		var searching = true
		while searching:
			treepos = Vector2(randi()%80,randi()%80)
			var cell = tilemap.get_cell(treepos.x, treepos.y)
			if cell >= 0:
				var cell_cord = tilemap.get_cell_autotile_coord(treepos.x, treepos.y)
				var nav = tilemap.tile_set.autotile_get_navigation_polygon(cell, cell_cord)
				#TODO: NAV = FULL SEQUARE!
				#print(nav, " vs ", ref_nav_tile)
				#break
				searching = (nav == null) # or Geometry.exclude_polygons_2d(nav, ref_nav_tile) > 0)
		tree.global_position = tilemap.map_to_world(treepos) + Vector2(16,16)
		tree.add_to_group("trees")
		print("Instance at ", treepos)
		tree.tree_type = randi() % 4
		tree.state = 4#randi() % 6
		tree.season = randi() % 4
		tilemap.set_cell(treepos.x, treepos.y, -1)
		world_grid.set_cell(treepos.x, treepos.y, 1)
		$Entities.add_child(tree)

func _unhandled_input(event : InputEvent) -> void:
	
	if event.is_action_pressed("ui_click"):
		click_timer.start(0.5)
		
	if event.is_action_released("ui_click"):
		if (click_timer.is_stopped()):
			return
		
		#for _entity in $Entities.get_children():
		#	if _entity.is_in_group("trees"):
		#		_entity.upgrade_state()
		
		if positionMark != null:
			remove_child(positionMark)
			positionMark.queue_free()
			positionMark = null
		
		# get path
		var end_pos = camera.get_global_mouse_position()
		var map_pos = tilemap.world_to_map(end_pos)
		
		# check if position is valid
		var cell = tilemap.get_cell(map_pos.x, map_pos.y)#get_cell(int(end_pos.x)/32, int(end_pos.y)/32)
		if cell == -1:
			return

		var new_path = nav_2d.get_simple_path(
			  character.global_position,
			  end_pos, false)
		
		if new_path.size() > 0:
			
			# set last point to center
			var last_point = new_path[new_path.size()-1]
			if (int(last_point.x) % 32 == 0):
				if end_pos.x > last_point.x:
					last_point.x -= 1
				else:
					last_point.x += 1
			if (int(last_point.y) % 32 == 0):
				if end_pos.y > last_point.y:
					last_point.y -= 1
				else:
					last_point.y += 1
			new_path[new_path.size()-1] = tilemap.map_to_world(tilemap.world_to_map(last_point)) + Vector2(16,16)
			if character.set_path(new_path):
				line_2d.points = new_path
				positionMark = PositionMarkClass.instance()
				positionMark.global_position = new_path[new_path.size()-1]
				add_child(positionMark)
		#pos_mark.visible = true
		#pos_mark.position = end_pos

func _on_ClickTimer_timeout():
	print("Timeout")


func _on_Player_path_end():
	if positionMark != null:
		remove_child(positionMark)
		positionMark.queue_free()
		positionMark = null
	line_2d.clear_points()
