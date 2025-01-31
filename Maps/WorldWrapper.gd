extends NavigationRegion2D

var player
var tiles = []

var structures = []

var score = preload("res://score.tres")
var currScore : int = 0
var tileNum = 0

func _ready() -> void:
	pass
	currScore = 0
	score.set_meta("score", currScore)
	
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
	
	# Generate the 3 tiles
	tiles = [generateTile(0), generateTile(1), []]
	
	bake_navigation_polygon()

func _physics_process(delta: float) -> void:
	var newScore : int = tileNum * 40 + floor((player.global_position.y - 7500) / -375)
	if newScore > currScore:
		currScore = newScore
		score.set_meta("score", currScore)
	
	if player.global_position.y <= -7501:
		shiftWorld()

func shiftWorld():
	
	const shiftVec = Vector2(0, 15000)
	
	tileNum += 1
	
	# Teleport the player back
	player.global_position += shiftVec
	# Teleport the enemies
	for child in get_parent().get_children():
		if child.is_in_group("Enemy"):
			child.global_position += shiftVec
	for child in get_children():
		child.global_position += shiftVec
		
	
	# Shift off old tiles and generate new ones
	deleteTile(tiles[2])
	tiles[2] = tiles[1]
	tiles[1] = tiles[0]
	tiles[0] = generateTile(0)
	
	
	bake_navigation_polygon()

func generateTile(tileNum : int):
	
	var newTile = []
	
	var tilesFilled : Array[bool] = []
	tilesFilled.resize(100)
	
	# Step 1: Generate square structures where possible
	for i in 100:
		# Try to place structures randomly
		var structureSize = randi() % (3 if i < 20 else 2 if i < 50 else 1) + 2
		
		var randPos = randi() % 100
		while (randPos % 10 > 10 - structureSize) or (floor(float(randPos)/10) >= 10 - structureSize):
			randPos -= 1 + randi() % 3
		
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
	
	# Step 2: Fill in gaps
	for i in 100:
		if not tilesFilled[i]:
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
	newStructure.position = Vector2((index % 10) * 1500 - 7500, floor(index / 10) * 1500 - 22500 + tileNum * 15000)
	add_child(newStructure)
	return newStructure

func deleteTile(tile):
	for structure in tile:
		structure.queue_free()
