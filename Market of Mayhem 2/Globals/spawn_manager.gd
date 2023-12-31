extends Node

@onready var characters_available : Dictionary = {
	"Bakery" : preload("res://Characters/Bakery/baker.tscn"),
	"Cashier" : preload("res://Characters/Cashier/cashier.tscn"),
	"Floral" : preload("res://Characters/Floral/florist.tscn"),
	"Kitchen" : preload("res://Characters/Kitchen/kitchen_dude.tscn"),
	"Meat" : preload("res://Characters/Meat/meat_seafood_dude.tscn"),
	"Freight" : preload("res://Characters/Freight/freight.tscn"),
	"Produce" : preload("res://Characters/Produce/produce_clerk.tscn")
}
@onready var player_movement = preload("res://Characters/Resources/player_movement.tscn")
@onready var ai_controller : PackedScene = preload("res://AI/Base/ai_controller.tscn")

@onready var manager : PackedScene = preload("res://NPC/Manager/manager.tscn")
@onready var manager_controller : PackedScene = preload("res://NPC/Manager/Manager AI/manager_controller.tscn")

var spawn_points : Dictionary = {}
var manager_spawn_point : Vector3 = Vector3.ZERO


func get_new_character(character_type : String, player_controlled : bool, spawn_point_number : int) -> Character:
	var new_character : Character = characters_available[character_type].instantiate()
	var new_controller = null
	if player_controlled:
		new_controller = player_movement.instantiate()
		new_character.player_controlled = true
	else:
		if new_character is Baker:
#			new_controller = baker_controller.instantiate()
			new_controller = ai_controller.instantiate()
		elif new_character is Freight:
#			new_controller = freight_controller.instantiate()
			new_controller = ai_controller.instantiate()
		else:
#			new_controller = balanced_ai_controller.instantiate()
			new_controller = ai_controller.instantiate()
		
		new_character.player_controlled = false

	new_character.add_child(new_controller)
	new_character.spawn_point = spawn_points[character_type][spawn_point_number].global_position

	return new_character


func get_new_manager() -> Manager:
	var new_character : Manager = manager.instantiate()
	var new_controller : ManagerController = manager_controller.instantiate()
	new_character.add_child(new_controller)
	new_character.spawn_point = manager_spawn_point
	return new_character


func populate_spawn_points():
	spawn_points = {
		"Bakery" : get_tree().get_nodes_in_group("BakerSpawn"),
		"Cashier" : get_tree().get_nodes_in_group("CashierSpawn"),
		"Floral" : get_tree().get_nodes_in_group("FloristSpawn"),
		"Kitchen" : get_tree().get_nodes_in_group("KitchenSpawn"),
		"Meat" : get_tree().get_nodes_in_group("MeatSpawn"),
		"Freight" : get_tree().get_nodes_in_group("FreightSpawn"),
		"Produce" : get_tree().get_nodes_in_group("ProduceSpawn")
	}
	
	manager_spawn_point = get_tree().get_first_node_in_group("ManagerSpawn").global_position
