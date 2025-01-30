extends NavigationRegion2D

var player
var tiles = []

var structures = []
var specialStructures = []

func _ready() -> void:
	
	# Get the player location
	var children = get_parent().get_children()
	for child in children:
		if child.is_in_group("Player"):
			player = child
	
	# Load in all the structure prefabs
	for i in 9:
		structures.append([])
		var pathName = "res://Maps/Structures/" + str(i) + "/"
		for file in DirAccess.get_files_at(pathName):
			structures[i].append(load(pathName + file))
	
	specialStructures = []
	
	# Generate the 9 tiles
	for i in 9:
		tiles.append(generateTile(i))

func _physics_process(delta: float) -> void:
	
	if abs(player.global_position.x) >= 7501:
		shiftWorld(snappedi(player.global_position.x, 7500), 0)
	if abs(player.global_position.y) >= 7501:
		shiftWorld(0, snappedi(player.global_position.y, 7500))

func shiftWorld(shiftX : int, shiftY : int):
	
	var shiftVec = Vector2(shiftX, shiftY) * 2
	
	# Teleport the player
	player.global_position -= shiftVec
	# Teleport the enemies
	for child in get_parent().get_children():
		if child.is_in_group("Enemy"):
			child.global_position -= shiftVec
	for child in get_children():
		child.global_position -= shiftVec
	
	# Shift off old tiles and generate new ones
	if shiftY < 0:
		for i in [8, 7, 6]:
			deleteTile(tiles[i])
		for i in [8, 7, 6, 5, 4, 3]:
			tiles[i] = tiles[i - 3]
		for i in [2, 1, 0]:
			tiles[i] = generateTile(i)
	elif shiftY > 0:
		for i in [0, 1, 2]:
			deleteTile(tiles[i])
		for i in [0, 1, 2, 3, 4, 5]:
			tiles[i] = tiles[i + 3]
		for i in [6, 7, 8]:
			tiles[i] = generateTile(i)
	elif shiftX < 0:
		for i in [2, 5, 8]:
			deleteTile(tiles[i])
		for i in [2, 5, 8, 1, 4, 7]:
			tiles[i] = tiles[i - 1]
		for i in [0, 3, 6]:
			tiles[i] = generateTile(i)
	elif shiftX > 0:
		for i in [0, 3, 6]:
			deleteTile(tiles[i])
		for i in [0, 3, 6, 1, 4, 7]:
			tiles[i] = tiles[i + 1]
		for i in [2, 5, 8]:
			tiles[i] = generateTile(i)
	
	bake_navigation_polygon()

func generateTile(tileNum : int):
	
	var newTile = []
	
	var tilesFilled : Array[bool] = []
	tilesFilled.resize(100)
	
	# Step 1: Generate special structures
	# Try to generate a special structure 1 times <?>
	for i in 1:
		# Pick a random special structure
		var structureNum = randi() % 2
		if structureNum == 0:
			print("Place Structure 0")
		elif structureNum == 1:
			print("Place Structure 1")
		# structureNum >= 2, don't generate anything
		
	# Step 2: Generate large structures where possible
	for i in 100:
		# Try to place structures randomly
		var structureSize = randi() % (3 if i < 20 else 2 if i < 50 else 1) + 2
		
		var randPos = randi() % 100
		while (randPos % 10 > 10 - structureSize) or (floor(float(randPos)/10) >= 10 - structureSize):
			randPos = randi() % 100
		
		var canPlace = true
		for y in structureSize:
			for x in structureSize:
				if tilesFilled[randPos + x + 10 * y]:
					canPlace = false
		
		if canPlace:
			newTile.append(randomStructure(structureSize, randPos, tileNum))
			for y in structureSize:
				for x in structureSize:
					tilesFilled[randPos + x + 10 * y] = true
	
	# Step 3: Fill in gaps
	for i in 100:
		if not tilesFilled[i]:
			# 1/3 chance to skip
			if randi() % 3 == 0:
				tilesFilled[i] = -1
				continue
			
			if floor(i/10) < 9:
				# Look for an L 3 piece
				if not tilesFilled[i + 10]:
					var A = i%10 > 0 and not tilesFilled[i + 9]
					var B = i%10 < 9 and not tilesFilled[i + 11]
					if A and B:
						tilesFilled[i] = true
						tilesFilled[i + 10] = true
						
						var randomSide = -1 if randi() % 2 else 1
						tilesFilled[i + 10 + randomSide] = true
						newTile.append(randomStructure(6, i, tileNum) if randomSide == 1 else randomStructure(5, i - 1, tileNum))
						continue
					elif A:
						tilesFilled[i] = true
						tilesFilled[i + 9] = true
						tilesFilled[i + 10] = true
						newTile.append(randomStructure(5, i - 1, tileNum))
						continue
					elif B:
						tilesFilled[i] = true
						tilesFilled[i + 10] = true
						tilesFilled[i + 11] = true
						newTile.append(randomStructure(6, i, tileNum))
						continue
				elif i%10 < 9 and not tilesFilled[i + 1]:
					var A = not tilesFilled[i + 10]
					var B = not tilesFilled[i + 11]
					if A and B:
						tilesFilled[i] = true
						tilesFilled[i + 1] = true
						var randomSide = randi() % 2
						tilesFilled[i + 10 + randomSide] = true
						newTile.append(randomStructure(8 if randomSide else 7, i, tileNum))
						continue
					elif A:
						tilesFilled[i] = true
						tilesFilled[i + 1] = true
						tilesFilled[i + 10] = true
						newTile.append(randomStructure(7, i, tileNum))
						continue
					elif B:
						tilesFilled[i] = true
						tilesFilled[i + 1] = true
						tilesFilled[i + 11] = true
						newTile.append(randomStructure(8, i, tileNum))
						continue
			
			# Can only be a pair or a single
			if i%10 == 9 or tilesFilled[i + 1]:
				tilesFilled[i] = true
				newTile.append(randomStructure(0, i, tileNum))
			else:
				tilesFilled[i] = true
				tilesFilled[i + 1] = true
				newTile.append(randomStructure(1, i, tileNum))
				
	return newTile

func randomStructure(structType : int, index : int, tileNum : int):
	var newStructure = structures[structType].pick_random().instantiate()
	var x = tileNum % 3
	var y = floor(tileNum / 3) 
	newStructure.position = Vector2((index % 10) * 1500 - 22500 + x * 15000, floor(index / 10) * 1500 - 22500 + y * 15000)
	add_child(newStructure)
	return newStructure

func deleteTile(tile):
	print(tile)
	for structure in tile:
		structure.queue_free()
