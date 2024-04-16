extends RayCast3D

@onready var label = $"../../../../UI/CenterContainer2/Label"
@onready var InteractTimer : Timer = $"../InteractTimer"

@onready var arms = $"../arms"
signal swap_weapon(weapon, isSwapping)

var WeaponInteractable

# Called when the node enters the scene tree for the first time.
func _ready():
	add_exception(owner)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	label.text = ""
	if is_colliding():
		var interactable = get_collider()
		var isInHolder = false
		var isHoldingWeaponWithSameCaliber = false
		
		if interactable is Interactable:
			WeaponInteractable = interactable
			for x in arms.weaponHolder.get_child_count():
				if interactable.weaponData.name == arms.weaponHolder.get_child(x).weaponData.name:
					isInHolder = true
				if interactable.weaponData.weaponCaliber == arms.weaponHolder.get_child(x).weaponData.weaponCaliber:
					isHoldingWeaponWithSameCaliber = true
			
			#si la tiene equipada -> pillar municion
			# si tiene un arma que es del mismo calibre y no esta equipada -> pillar municion o arma
			# si no tiene un arma que no es del mismo calibre ni está equipada
			
			if isHoldingWeaponWithSameCaliber and not isInHolder:
				label.text = "Press 'Interact' to pickup ammo\n Hold 'Interact to swap for " + interactable.weaponData.name
			
			elif isInHolder:
				label.text = "Press 'Interact' to pickup ammo"

			elif not isInHolder and not isHoldingWeaponWithSameCaliber:
				label.text = "Hold 'Interact' to swap for "  + interactable.weaponData.name
				
			#grab ammo
			if Input.is_action_just_pressed("Interact") and isInHolder:
				swap_weapon.emit(interactable, false)
			
			#grab ammo without destroying weapon
			if Input.is_action_just_pressed("Interact") and not isInHolder and isHoldingWeaponWithSameCaliber:
				swap_weapon.emit(interactable, false)
			
			#grab weapon (different weapon)
			if Input.is_action_just_pressed("Interact") and not isInHolder:
				print("grab gun")
				InteractTimer.start()
			
			if Input.is_action_just_released("Interact") and not isInHolder:
				if not InteractTimer.is_stopped():
					InteractTimer.stop()

func _on_interact_timer_timeout():
	swap_weapon.emit(WeaponInteractable, true)
	InteractTimer.stop()

