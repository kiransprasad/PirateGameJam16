extends Button

var skill

func _ready() -> void:
	$Title.text = skill.name
	$Title.modulate = skill.colour
	
	$Panel.texture = load("res://Sprites/Skills/" + arr_to_str(skill.name.split(" ")) + ".png")
	
	$HBoxContainer.modulate = skill.colour
	$HBoxContainer/Stats.text = str(skill.damage) + " Damage\n" + str(skill.max_cooldown) + " Cooldown"
	$HBoxContainer/Stats2.text = str(skill.knockback.length()) + " Knockback\n" + str(skill.recoil.length()) + " Recoil"

func arr_to_str(arr):
	var output = ""
	for s in arr:
		output += s
	return output
