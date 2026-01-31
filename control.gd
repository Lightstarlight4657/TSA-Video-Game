extends Control

# Shop prices
var prices = {
	"hp_upgrade": 50,
	"damage_upgrade": 50,
	"extra_cannons": 100,
	"rechargeable_shield": 150,
	"invincibility": 200,
	"kernel_kerns_9000": 120,
	"big_boom": 80
}

@onready var space_dollars_label = $SpaceDollarsLabel
@onready var upgrades_container = $ScrollContainer/VBoxContainer/UpgradesContainer
@onready var abilities_container = $ScrollContainer/VBoxContainer/AbilitiesContainer
@onready var continue_button = $ContinueButton
@onready var hp_level_label = $HPLevelLabel
@onready var damage_level_label = $DamageLevelLabel

func _ready() -> void:
	update_display()
	continue_button.pressed.connect(_on_continue_pressed)

func update_display() -> void:
	var dollars = GameData.get_space_dollars()
	space_dollars_label.text = "💵 Space Dollars: $" + str(dollars)
	
	# Update level labels
	var max_level = GameData.get_max_upgrade_level()
	hp_level_label.text = "HP Level: " + str(GameData.get_hp_level()) + "/" + str(max_level)
	damage_level_label.text = "Damage Level: " + str(GameData.get_damage_level()) + "/" + str(max_level)
	
	create_shop_items()

func create_shop_items() -> void:
	# Clear existing
	for child in upgrades_container.get_children():
		child.queue_free()
	for child in abilities_container.get_children():
		child.queue_free()
	
	# PERMANENT UPGRADES SECTION
	var upgrades_title = create_section_title("PERMANENT UPGRADES")
	upgrades_container.add_child(upgrades_title)
	
	# HP Upgrade
	var hp_card = create_upgrade_card(
		"HP Upgrade",
		"+15% Maximum Health",
		prices["hp_upgrade"],
		"hp_upgrade",
		"❤️",
		GameData.can_upgrade_hp()
	)
	upgrades_container.add_child(hp_card)
	
	# Damage Upgrade
	var damage_card = create_upgrade_card(
		"Damage Upgrade",
		"+20% Bullet Damage",
		prices["damage_upgrade"],
		"damage_upgrade",
		"💥",
		GameData.can_upgrade_damage()
	)
	upgrades_container.add_child(damage_card)
	
	# RUN ABILITIES SECTION
	var abilities_title = create_section_title("RUN ABILITIES (One-Time Use)")
	abilities_container.add_child(abilities_title)
	
	# Extra Cannons
	var cannons_card = create_ability_card(
		"Extra Cannons",
		"Fire multiple bullets at once. Side bullets do 25% less damage.",
		prices["extra_cannons"],
		"extra_cannons",
		"🚀"
	)
	abilities_container.add_child(cannons_card)
	
	# Rechargeable Shield
	var shield_card = create_ability_card(
		"Rechargeable Shield",
		"50% damage reduction. Recharges 10% per second when not hit.",
		prices["rechargeable_shield"],
		"rechargeable_shield",
		"🛡️"
	)
	abilities_container.add_child(shield_card)
	
	# Invincibility
	var invincibility_card = create_ability_card(
		"Invincibility",
		"15 seconds of invincibility + 30% HP heal. One use only.",
		prices["invincibility"],
		"invincibility",
		"✨"
	)
	abilities_container.add_child(invincibility_card)
	
	# Kernel Kerns 9000
	var kernel_card = create_ability_card(
		"Kernel Kerns 9000",
		"Bullets become popcorn! +30% damage for 15s. Cooldown: 30s.",
		prices["kernel_kerns_9000"],
		"kernel_kerns_9000",
		"🍿"
	)
	abilities_container.add_child(kernel_card)
	
	# Big Boom
	var boom_card = create_ability_card(
		"1 Big Boom",
		"Massive damage blast. One use. Cannot own multiple.",
		prices["big_boom"],
		"big_boom",
		"💣"
	)
	abilities_container.add_child(boom_card)

func create_section_title(title: String) -> Label:
	var label = Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
	return label

func create_upgrade_card(title: String, description: String, price: int, upgrade_key: String, icon: String, can_purchase: bool) -> PanelContainer:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(600, 100)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	card.add_child(margin)
	
	var hbox = HBoxContainer.new()
	margin.add_child(hbox)
	
	# Icon
	var icon_label = Label.new()
	icon_label.text = icon
	icon_label.add_theme_font_size_override("font_size", 48)
	icon_label.custom_minimum_size = Vector2(70, 0)
	hbox.add_child(icon_label)
	
	# Info
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)
	
	var name_label = Label.new()
	name_label.text = title
	name_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(name_label)
	
	var desc_label = Label.new()
	desc_label.text = description
	desc_label.add_theme_font_size_override("font_size", 16)
	desc_label.modulate = Color(0.8, 0.8, 0.8)
	vbox.add_child(desc_label)
	
	var price_label = Label.new()
	price_label.text = "💵 $" + str(price)
	price_label.add_theme_font_size_override("font_size", 18)
	price_label.modulate = Color(0.4, 1, 0.4)
	vbox.add_child(price_label)
	
	# Buy button
	var buy_button = Button.new()
	buy_button.custom_minimum_size = Vector2(100, 0)
	
	if not can_purchase:
		buy_button.text = "MAXED"
		buy_button.disabled = true
	else:
		buy_button.text = "BUY"
		buy_button.pressed.connect(_on_buy_upgrade.bind(upgrade_key, price))
	
	hbox.add_child(buy_button)
	
	return card

func create_ability_card(title: String, description: String, price: int, ability_key: String, icon: String) -> PanelContainer:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(600, 120)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	card.add_child(margin)
	
	var hbox = HBoxContainer.new()
	margin.add_child(hbox)
	
	# Icon
	var icon_label = Label.new()
	icon_label.text = icon
	icon_label.add_theme_font_size_override("font_size", 48)
	icon_label.custom_minimum_size = Vector2(70, 0)
	hbox.add_child(icon_label)
	
	# Info
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)
	
	var name_label = Label.new()
	name_label.text = title
	name_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(name_label)
	
	var desc_label = Label.new()
	desc_label.text = description
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.modulate = Color(0.8, 0.8, 0.8)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_label)
	
	var price_label = Label.new()
	price_label.text = "💵 $" + str(price)
	price_label.add_theme_font_size_override("font_size", 18)
	price_label.modulate = Color(0.4, 1, 0.4)
	vbox.add_child(price_label)
	
	# Buy button
	var buy_button = Button.new()
	buy_button.custom_minimum_size = Vector2(100, 0)
	
	if GameData.has_ability(ability_key):
		if ability_key == "big_boom":
			buy_button.text = "OWNED"
			buy_button.disabled = true
		else:
			buy_button.text = "OWNED"
			buy_button.disabled = true
	else:
		buy_button.text = "BUY"
		buy_button.pressed.connect(_on_buy_ability.bind(ability_key, price))
	
	hbox.add_child(buy_button)
	
	return card

func _on_buy_upgrade(upgrade_key: String, price: int) -> void:
	if not GameData.spend_space_dollars(price):
		print("Not enough Space Dollars!")
		return
	
	match upgrade_key:
		"hp_upgrade":
			GameData.upgrade_hp()
		"damage_upgrade":
			GameData.upgrade_damage()
	
	update_display()

func _on_buy_ability(ability_key: String, price: int) -> void:
	if not GameData.spend_space_dollars(price):
		print("Not enough Space Dollars!")
		return
	
	GameData.purchase_ability(ability_key)
	update_display()

func _on_continue_pressed() -> void:
	# Start new run
	GameData.start_new_run()
	# Return to level
	get_tree().change_scene_to_file("res://scenes/Level1.tscn")
