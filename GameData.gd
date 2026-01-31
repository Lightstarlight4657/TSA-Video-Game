extends Node

# GameData - Manages Space Dollars and Upgrades

# Currency
var space_dollars: int = 0

# Permanent upgrades (persist between runs)
var permanent_upgrades = {
	"hp_level": 0,        # Max 3 for area 1, 5 for area 2, 10 for area 3
	"damage_level": 0     # Max 3 for area 1, 5 for area 2, 10 for area 3
}

# Current area (determines upgrade caps)
var current_area: int = 1  # 1, 2, or 3

# Run-specific abilities (reset each run)
var run_abilities = {
	"extra_cannons": false,
	"rechargeable_shield": false,
	"invincibility": false,
	"kernel_kerns_9000": false,
	"big_boom": false
}

# Shield state
var shield_charge: float = 100.0  # 0-100%
var shield_active: bool = false

# Invincibility state
var invincibility_used: bool = false

# Kernel Kerns state
var kernel_kerns_active: bool = false
var kernel_kerns_cooldown_ready: bool = true

# Stats tracking
var enemies_killed_this_run: int = 0
var total_enemies_killed: int = 0

func _ready() -> void:
	print("GameData initialized - Space Dollars ready!")

# *****SPACE DOLLARS 
func add_space_dollars(amount: int) -> void:
	space_dollars += amount
	print("Space Dollars earned: +$", amount, " | Total: $", space_dollars)

func spend_space_dollars(amount: int) -> bool:
	if space_dollars >= amount:
		space_dollars -= amount
		return true
	return false

func get_space_dollars() -> int:
	return space_dollars

# Award space dollars based on enemies killed when player dies
func award_death_bonus() -> void:
	var bonus = enemies_killed_this_run * 5  # $5 per enemy
	add_space_dollars(bonus)
	print("Death bonus: $", bonus, " for ", enemies_killed_this_run, " enemies killed")

# ****ENEMY TRACKING 
func add_enemy_kill() -> void:
	enemies_killed_this_run += 1
	total_enemies_killed += 1
	add_space_dollars(2)  # $2 per enemy killed

func get_enemies_killed_this_run() -> int:
	return enemies_killed_this_run

# ****PERMANENT UPGRADES 
func get_max_upgrade_level() -> int:
	match current_area:
		1: return 3
		2: return 5
		3: return 10
		_: return 3

func can_upgrade_hp() -> bool:
	return permanent_upgrades["hp_level"] < get_max_upgrade_level()

func can_upgrade_damage() -> bool:
	return permanent_upgrades["damage_level"] < get_max_upgrade_level()

func upgrade_hp() -> bool:
	if can_upgrade_hp():
		permanent_upgrades["hp_level"] += 1
		print("HP upgraded to level ", permanent_upgrades["hp_level"])
		return true
	return false

func upgrade_damage() -> bool:
	if can_upgrade_damage():
		permanent_upgrades["damage_level"] += 1
		print("Damage upgraded to level ", permanent_upgrades["damage_level"])
		return true
	return false

func get_hp_multiplier() -> float:
	return 1.0 + (permanent_upgrades["hp_level"] * 0.15)  # +15% per level

func get_damage_multiplier() -> float:
	return 1.0 + (permanent_upgrades["damage_level"] * 0.2)  # +20% per level

func get_hp_level() -> int:
	return permanent_upgrades["hp_level"]

func get_damage_level() -> int:
	return permanent_upgrades["damage_level"]

# ==================== RUN ABILITIES ====================
func purchase_ability(ability_name: String) -> bool:
	if ability_name == "big_boom" and run_abilities["big_boom"]:
		return false  # Can't own more than one
	
	run_abilities[ability_name] = true
	
	# Activate special states
	if ability_name == "rechargeable_shield":
		shield_active = true
		shield_charge = 100.0
	
	print("Ability purchased: ", ability_name)
	return true

func has_ability(ability_name: String) -> bool:
	return run_abilities.get(ability_name, false)

func use_big_boom() -> void:
	run_abilities["big_boom"] = false
	print("BIG BOOM used!")

func use_invincibility() -> void:
	invincibility_used = true
	print("Invincibility activated!")

func is_invincibility_available() -> bool:
	return run_abilities["invincibility"] and not invincibility_used

func activate_kernel_kerns() -> void:
	kernel_kerns_active = true
	kernel_kerns_cooldown_ready = false
	print("Kernel Kerns 9000 activated!")

func deactivate_kernel_kerns() -> void:
	kernel_kerns_active = false
	print("Kernel Kerns 9000 deactivated")

func kernel_kerns_ready() -> void:
	kernel_kerns_cooldown_ready = true
	print("Kernel Kerns 9000 ready!")

func is_kernel_kerns_active() -> bool:
	return kernel_kerns_active

func can_use_kernel_kerns() -> bool:
	return run_abilities["kernel_kerns_9000"] and kernel_kerns_cooldown_ready

# ==================== SHIELD SYSTEM ====================
func update_shield(delta: float, taking_damage: bool) -> void:
	if not run_abilities["rechargeable_shield"]:
		return
	
	if taking_damage:
		# Shield is being hit, don't recharge
		pass
	else:
		# Recharge 10% per second when not taking damage
		shield_charge = min(100.0, shield_charge + (10.0 * delta))
		
		# Reactivate shield when fully charged
		if shield_charge >= 100.0 and not shield_active:
			shield_active = true
			print("Shield recharged!")

func apply_shield_damage(damage: float) -> float:
	if not run_abilities["rechargeable_shield"] or not shield_active:
		return damage
	
	# Reduce damage by 50%
	var reduced_damage = damage * 0.5
	
	# Shield takes the other 50%
	var shield_damage = damage * 0.5
	shield_charge -= shield_damage
	
	if shield_charge <= 0:
		shield_charge = 0
		shield_active = false
		print("Shield broken!")
	
	return reduced_damage

func get_shield_charge() -> float:
	return shield_charge

func is_shield_active() -> bool:
	return shield_active

# ==================== RUN MANAGEMENT ====================
func start_new_run() -> void:
	# Reset run-specific data
	enemies_killed_this_run = 0
	run_abilities = {
		"extra_cannons": false,
		"rechargeable_shield": false,
		"invincibility": false,
		"kernel_kerns_9000": false,
		"big_boom": false
	}
	shield_charge = 100.0
	shield_active = false
	invincibility_used = false
	kernel_kerns_active = false
	kernel_kerns_cooldown_ready = true
	print("New run started!")

func set_area(area: int) -> void:
	current_area = area
	print("Area set to: ", area)

# ==================== GAME RESET ====================
func reset_all() -> void:
	space_dollars = 0
	permanent_upgrades = {"hp_level": 0, "damage_level": 0}
	current_area = 1
	enemies_killed_this_run = 0
	total_enemies_killed = 0
	start_new_run()
	print("All game data reset!")
