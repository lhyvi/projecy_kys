class_name Player extends Node2D

var character: Character

func _ready():
	add_to_group("player")
	var gm = ResourceManager.game_manager
	character.connect("energy_changed", gm.update_energy_label)
	character.connect("hp_changed", gm.update_player_hp)
	gm.update_energy_label(character.energy)
	gm.update_player_hp(character.hp)
	character.energy = character.energy
	character.hp = character.hp

func set_character(new_character: Character):
	self.character = new_character
	var character_parent = new_character.get_parent()
	if character_parent:
		character_parent.remove_child(character)
	add_child(new_character)
	character.target = "nonplayer"
	ResourceManager.player = character
	character.add_to_group("player")
	return

static func player_from(player_character: Character) -> Player:
	var player = Player.new()
	player.set_character(player_character)
	return player

