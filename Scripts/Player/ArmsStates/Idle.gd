extends ArmsState

func enter(_msg := {}):
	if _msg.has("replace_weapon") and _msg.has("isSwappingValue"):
		replace_weapon(_msg.get("replace_weapon"), _msg.get("isSwappingValue"))
	
	arms.animationPlayer.play("Idle")

func physics_update(delta):
	if Input.is_action_pressed("Reload") and arms.actualWeapon.weaponData.bulletsInMag < arms.actualWeapon.weaponData.magSize and arms.actualWeapon.weaponData.reserveAmmo > 0:
		state_machine.transition_to("Reload")
	
	mouse_swap_weapon_logic()
	swap_weapon()
	reload_listener()

func replace_weapon(pickupWeapon, isSwapping):
	if not pickupWeapon.isPickupReady:
		return
	
	var weapon_equipped = null
	var weapon_with_same_caliber = null
	for x in arms.weaponHolder.get_child_count():
		if arms.weaponHolder.get_child(x).weaponData.name == pickupWeapon.weaponData.name:
			arms.weaponHolder.get_child(x).name = pickupWeapon.weaponData.name
			weapon_equipped = arms.weaponHolder.get_child(x)
		if arms.weaponHolder.get_child(x).weaponData.weaponCaliber == pickupWeapon.weaponData.weaponCaliber:
			arms.weapon_with_same_caliber = arms.weaponHolder.get_child(x)
			
	#if the weapon is not equipped (which means it can't give ammo) and there is no other in inventory with same caliber -> swap weapon
	if not weapon_equipped and not weapon_with_same_caliber and arms.weaponHolder.get_child_count() == 2:
		state_machine.transition_to("SwappingWeapon", {drop_weapon = arms.actualWeapon.weaponData.name})
	
	#If player has some sort of weapon with the same name and caliber, add ammo to it and destroy it
	if weapon_equipped and weapon_with_same_caliber and not isSwapping:
		var randomReserveAmmo = randf_range(pickupWeapon.weaponData.magSize, pickupWeapon.weaponData.reserveAmmo / 2)
		#Give ammo to the other weapon reserve - RANDOMIZED, else: body.weaponData.bulletsInMag
		for x in arms.weaponHolder.get_child_count():
			if arms.weaponHolder.get_child(x) != weapon_equipped and arms.weaponHolder.get_child(x).weaponData.weaponCaliber == weapon_equipped.weaponData.weaponCaliber:
				if pickupWeapon.isAlreadyGrabbed:
					arms.weaponHolder.get_child(x).weaponData.reserveAmmo += pickupWeapon.weaponData.reserveAmmo
				else:
					arms.weaponHolder.get_child(x).weaponData.reserveAmmo += randomReserveAmmo
		
		weapon_equipped.weaponData.reserveAmmo += randomReserveAmmo
		pickupWeapon.queue_free()
	
	#if there is no weapon equipped but one or 2 weapons have same caliber -> add ammo to them, but don't destroy weapon
	if not weapon_equipped and weapon_with_same_caliber:
		weapon_with_same_caliber.weaponData.reserveAmmo += pickupWeapon.weaponData.reserveAmmo
		pickupWeapon.isAlreadyGrabbed = true
		pickupWeapon.weaponData.reserveAmmo = 0
		if isSwapping:
			state_machine.transition_to("SwappingWeapon", {drop_weapon = arms.actualWeapon.weaponData.name})
			
	#weapon switching
	if not weapon_equipped and arms.weaponHolder.get_child_count() < 2:
		var spawnedWeaponScene = load(pickupWeapon.weaponData.weaponScene)
		var spawnedWeapon = spawnedWeaponScene.instantiate()
		spawnedWeapon.position = pickupWeapon.weaponData.weaponSpawnPosition
		spawnedWeapon.handsNode = self.get_path()
		arms.weaponHolder.add_child(spawnedWeapon)
		pickupWeapon.queue_free()
		
		arms.actual_weapon_index = 1
		
		arms.actualWeapon = arms.weaponHolder.get_child(arms.actual_weapon_index)
		
		#Give ammo to the other weapon reserve - RANDOMIZED, else: body.weaponData.bulletsInMag
		var randomMagAmmo = randf_range(0, pickupWeapon.weaponData.magSize)
		var randomReserveAmmo = randf_range(pickupWeapon.weaponData.reserveAmmo / 3, pickupWeapon.weaponData.reserveAmmo)
		
		if (not pickupWeapon.isAlreadyGrabbed and not isSwapping):
			arms.actualWeapon.weaponData.bulletsInMag = randomMagAmmo
			arms.actualWeapon.weaponData.reserveAmmo = randomReserveAmmo
		elif pickupWeapon.isAlreadyGrabbed:
			arms.actualWeapon.weaponData.bulletsInMag = pickupWeapon.weaponData.bulletsInMag
			arms.actualWeapon.weaponData.reserveAmmo = pickupWeapon.weaponData.reserveAmmo
		
		arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
		
		#if both weapons have the same caliber, add more ammo to both reserve
		if arms.actualWeapon.weaponData.weaponCaliber == arms.weaponHolder.get_child(0).weaponData.weaponCaliber:
			arms.weaponHolder.get_child(1).weaponData.reserveAmmo = arms.weaponHolder.get_child(0).weaponData.reserveAmmo
			arms.weaponHolder.get_child(0).weaponData.reserveAmmo = arms.weaponHolder.get_child(1).weaponData.reserveAmmo
		state_machine.transition_to("SwappingWeapon")


func mouse_swap_weapon_logic():
	if Input.is_action_just_pressed("Next Weapon"):
		arms.actual_weapon_index = (arms.actual_weapon_index + 1) % arms.weaponHolder.get_child_count()
		
		arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
		state_machine.transition_to("SwappingWeapon")
		
	if Input.is_action_just_pressed("Previous Weapon"):
		arms.actual_weapon_index = (arms.actual_weapon_index - 1) % arms.weaponHolder.get_child_count()
		
		arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
		state_machine.transition_to("SwappingWeapon")
	
	
func swap_weapon():
	if Input.is_action_just_pressed("Primary weapon"):
		if arms.actual_weapon_index != 0:
			arms.actual_weapon_index = 0
			arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
		state_machine.transition_to("SwappingWeapon")
	if Input.is_action_just_pressed("Secondary weapon"):
		if arms.actual_weapon_index != 1:
			arms.actual_weapon_index = 1
			arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
		state_machine.transition_to("SwappingWeapon")

func reload_listener():
	if arms.actualWeapon.weaponData.bulletsInMag <= 0 and arms.actualWeapon.weaponData.reserveAmmo > 0:
		state_machine.transition_to("Reload")
