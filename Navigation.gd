extends Navigation2D

onready var entities = get_node("/root/TownCenter/Entities")
onready var player = get_node("/root/TownCenter/Entities/Player")
var navTilemap

# Called when the node enters the scene tree for the first time.
func _ready():
	for tilemap in get_children():
		if tilemap.is_in_group("navigation"):
			self.navTilemap = tilemap
			break
	refreshNavigation()

func _process(delta):
  pass

func findCell(navPolygon) -> Vector2:
	var width = navTilemap.tile_set.autotile_get_size(1).x
	var height = navTilemap.tile_set.autotile_get_size(1).y
	
	for x in range(0, width):
		for y in range(0, height):
			var cellCord = Vector2(x,y)
			var nav = navTilemap.tile_set.autotile_get_navigation_polygon(1, cellCord)
			if nav == null:
				continue
			if (Geometry.exclude_polygons_2d(nav.get_vertices(), navPolygon).size() == 0):
				return cellCord
	print("Not found ", navPolygon)
	return Vector2(0,0)

func refreshNavigation():
	if(self.navTilemap):
		for _tilemap in get_tree().get_nodes_in_group("tilemap"):
			var tilemap : TileMap = _tilemap
			if not tilemap.is_in_group("navigation"):
				for cellIdx in tilemap.get_used_cells():
					var cell = tilemap.get_cell(cellIdx.x, cellIdx.y)
					var tile_mode = tilemap.tile_set.tile_get_tile_mode(cell)
					#has navigation?
					var nav : NavigationPolygon
					if (tile_mode == TileSet.SINGLE_TILE):
						nav = tilemap.tile_set.tile_get_navigation_polygon(cell)
					elif (tile_mode == TileSet.ATLAS_TILE):
						var cell_cord = tilemap.get_cell_autotile_coord(cellIdx.x, cellIdx.y)
						nav = tilemap.tile_set.autotile_get_navigation_polygon(cell, cell_cord)
					if(nav != null):
						if (self.navTilemap.get_cell(cellIdx.x, cellIdx.y) == -1):
							#Add Navigation tile
							var cellCord = findCell(nav.get_vertices())
							self.navTilemap.set_cell(cellIdx.x, cellIdx.y, 1, false, false, false, cellCord)
						# TODO: Get the most difference nav polygon
						elif (self.navTilemap.get_cell(cellIdx.x, cellIdx.y) > -1):
							# get the most restrictive
							var nav_cell = navTilemap.get_cell(cellIdx.x, cellIdx.y)
							var cell_cord = navTilemap.get_cell_autotile_coord(cellIdx.x, cellIdx.y)
							var cur_nav = navTilemap.tile_set.autotile_get_navigation_polygon(nav_cell, cell_cord)
							var new_nav = Geometry.intersect_polygons_2d(nav.get_vertices(), cur_nav.get_vertices())[0]
							cell_cord = findCell(new_nav)
							self.navTilemap.set_cell(cellIdx.x, cellIdx.y, 1, false, false, false, cell_cord)
					else:
						#Remove any navigation tile on that position
						self.navTilemap.set_cell(cellIdx.x, cellIdx.y, -2)
			tilemap.update_dirty_quadrants()
		for _entity in entities.get_children():
			if _entity != player:
				print("->",_entity.get_name(), navTilemap.world_to_map(_entity.global_position))
				var entity_cords = navTilemap.world_to_map(_entity.global_position)
				self.navTilemap.set_cell(entity_cords.x, entity_cords.y, -2)
