extends RayCast3D

@export var hudNode := NodePath()
@onready var hud : HUD = get_node(hudNode)
@onready var InteractTimer : Timer = $"../InteractTimer"

@onready var arms = $"../arms"
signal swap_weapon(weapon, isSwapping)

signal pickup_ammo(ammoBox)

signal button_pressed

var weaponInteractable : WeaponInteractable

# Called when the node enters the scene tree for the first time.
func _ready():
	add_exception(owner)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	hud.marginContainer.visible = false
	hud.pickupAmmoContainer.visible = false
	hud.pickupWeaponContainer.visible = false
	hud.interactContainer.visible = false
	if is_colliding():
		
		var interactable = get_collider()
		var isInHolder = false
		var isHoldingWeaponWithSameCaliber = false
		if interactable is Interactable_Button:
			hud.interactContainer.visible = true
			if Input.is_action_just_pressed("Interact"):
				hud.pointsLabel.text = "0"
				hud.timeLabel.text = "60"
				button_pressed.emit()
				
		if interactable is WeaponInteractable:
			weaponInteractable = interactable
			for x in arms.weaponHolder.get_child_count():
				if interactable.weaponData.name == arms.weaponHolder.get_child(x).weaponData.name:
					isInHolder = true
				if interactable.weaponData.weaponCaliber == arms.weaponHolder.get_child(x).weaponData.weaponCaliber:
					isHoldingWeaponWithSameCaliber = true
			
			#si la tiene equipada -> pillar municion
			# si tiene un arma que es del mismo calibre y no esta equipada -> pillar municion o arma
			# si no tiene un arma que no es del mismo calibre ni está equipada
			
			if isHoldingWeaponWithSameCaliber and not isInHolder:
				var weaponImage : TextureRect = hud.pickupWeaponContainer.get_child(1)
				weaponImage.texture = interactable.weaponData.weaponImage
				if interactable.weaponData.reserveAmmo > 0:
					hud.marginContainer.visible = true
					hud.pickupAmmoContainer.visible = true
				hud.pickupWeaponContainer.visible = true
			
			elif isInHolder:
				hud.pickupAmmoContainer.visible = true

			elif not isInHolder and not isHoldingWeaponWithSameCaliber:
				var weaponImage : TextureRect = hud.pickupWeaponContainer.get_child(1)
				weaponImage.texture = interactable.weaponData.weaponImage
				hud.pickupWeaponContainer.visible = true
				
			#grab ammo
			if Input.is_action_just_pressed("Interact") and isInHolder:
				swap_weapon.emit(interactable, false)
			
			#grab ammo without destroying weapon
			if Input.is_action_just_pressed("Interact") and not isInHolder and isHoldingWeaponWithSameCaliber:
				swap_weapon.emit(interactable, false)
			
			#grab weapon (different weapon)
			if Input.is_action_just_pressed("Interact") and not isInHolder:
				await get_tree().create_timer(0.3).timeout
				if Input.is_action_pressed("Interact"):
					on_pickup_weapon(weaponInteractable.weaponData.weaponScene, true)
			
			if Input.is_action_just_released("Interact") and not isInHolder:
				if not InteractTimer.is_stopped():
					InteractTimer.stop()
		
		if interactable is Ammo:
			if hud.player_controller.arms.actualWeapon.weaponData.weaponType == interactable.ammoData.ammoType:
				hud.pickupAmmoContainer.visible = true
				if Input.is_action_just_pressed("Interact"):
					pickup_ammo.emit(interactable)

@rpc("any_peer", "reliable", "call_local")
func on_pickup_weapon(newWeaponStringScene : String, isInHolder : bool):
	arms._on_interact_ray_swap_weapon.rpc(newWeaponStringScene, isInHolder)

func _on_interact_timer_timeout():
	swap_weapon.emit(weaponInteractable, true)
	InteractTimer.stop()
