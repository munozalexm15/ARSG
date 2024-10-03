extends ArmsState

func enter(_msg := {}):
	if not is_multiplayer_authority():
		return
	if _msg.has("drop_weapon"):
		drop_weapon(_msg.get("drop_weapon"), _msg.get("pickup_weapon"), _msg.get("is_dropping_weapon"))

	arms.animationPlayer.play("SwapWeapon")
	
	if arms.player.player_sounds:
		for audio in arms.player.player_sounds.get_children():
			arms.player.player_sounds.remove_child(audio)
		
	if arms.weaponHolder.get_child_count() > 0:
		if arms.actualWeapon.weaponData.weaponType == "Sniper" and Input.is_action_pressed("ADS"):
			arms.player.hud.aimAnimationPlayer.play("Aim", -1, -1, true)

func physics_update(_delta):
	if not is_multiplayer_authority():
		return
	
	if not arms.weaponHolder.get_child_count() > 0:
		return
	
	swap_weapon()
	mouse_swap_weapon_logic()


#metodo que se encarga de dropearte el arma actual y spawnearte en las manos la que querias coger
func drop_weapon(_weaponName, pickupWeapon, isSwapping):
	var weapon_Ref = null
	for x in arms.weaponHolder.get_child_count():
		if arms.weaponHolder.get_child(x).weaponData.name == _weaponName:
			weapon_Ref = arms.weaponHolder.get_child(x)
	
	if weapon_Ref == null:
		return
		
	var weapon_to_spawn = load(weapon_Ref.weaponData.weaponPickupScene)
	var droppedWeapon = weapon_to_spawn.instantiate()
	
	droppedWeapon.weaponData.reserveAmmo = weapon_Ref.weaponData.reserveAmmo
	droppedWeapon.weaponData.bulletsInMag = weapon_Ref.weaponData.bulletsInMag

	#if both weapons have the same caliber, when dropping the actual weapon it will lose all its reserve ammo 
	if arms.weaponHolder.get_child(0).weaponData.weaponCaliber == arms.weaponHolder.get_child(1).weaponData.weaponCaliber:
		droppedWeapon.weaponData.reserveAmmo = 0
	
	droppedWeapon.isAlreadyGrabbed = true
	droppedWeapon.set_global_transform(arms.weaponHolder.get_global_transform())
	if arms.weaponHolder.get_child_count() > 1:
		Network.game.interactables_node.add_child(droppedWeapon)
	arms.weaponHolder.remove_child(weapon_Ref)
	
	arms.actual_weapon_index = 0
	arms.actualWeapon = arms.weaponHolder.get_child(arms.actual_weapon_index)
	
	arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
	
	#weapon switching
	var spawnedWeaponScene = load(pickupWeapon.weaponData.weaponScene)
	var newWeapon = spawnedWeaponScene.instantiate()
	newWeapon.position = pickupWeapon.weaponData.weaponSpawnPosition
	newWeapon.handsNode = arms.get_path()
	
	arms.weaponHolder.add_child(newWeapon)
	pickupWeapon.queue_free()
	
	#as it is swapping weapons on pickup, set the current weapon to not being used
	arms.actual_weapon_index = 1
	loadWeapon(arms.actual_weapon_index)
	arms.actualWeapon = arms.weaponHolder.get_child(arms.actual_weapon_index)
	
	#Give ammo to the other weapon reserve - RANDOMIZED, else: body.weaponData.bulletsInMag
	var randomMagAmmo = randi_range(0, pickupWeapon.weaponData.magSize)
	var randomReserveAmmo = randi_range(pickupWeapon.weaponData.reserveAmmo / 3, pickupWeapon.weaponData.reserveAmmo)
	
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
	
	state_machine.transition_to("Idle")

func _on_animation_player_animation_finished(anim_name):
	if anim_name != "SwapWeapon":
		return
	
	if anim_name == "SwapWeapon" and state_machine.state.name == "Melee":
		return
	
	if not arms.weaponHolder.get_child_count() > 0:
		return
	
	#RESET OTHER WEAPON ANIMATION IF IT IS RELOAD CANCELLING
	arms.actualWeapon.being_used = false
	arms.actualWeapon.handsAnimPlayer.play("RESET")
	await arms.actualWeapon.handsAnimPlayer.animation_finished
	
	loadWeapon(arms.actual_weapon_index)
	arms.actualWeapon = arms.weaponHolder.get_child(arms.actual_weapon_index)
	
	arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
	
	state_machine.transition_to("Idle")
	#elif arms.player.state == "Run":
		#arms.animationPlayer.play("Run")

func mouse_swap_weapon_logic():
	if Input.is_action_just_pressed("Next Weapon"):
		arms.actual_weapon_index = (arms.actual_weapon_index + 1) % arms.weaponHolder.get_child_count()
		
		arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
		state_machine.transition_to("SwappingWeapon")
		return
		
	if Input.is_action_just_pressed("Previous Weapon"):
		arms.actual_weapon_index = (arms.actual_weapon_index - 1) % arms.weaponHolder.get_child_count()
		
		arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
		state_machine.transition_to("SwappingWeapon")
		return
	
	
func swap_weapon():
	if Input.is_action_just_pressed("Primary weapon") and arms.actual_weapon_index != 0:
		arms.actual_weapon_index = 0
		arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
		state_machine.transition_to("SwappingWeapon")
		return
		
	if Input.is_action_just_pressed("Secondary weapon") and arms.actual_weapon_index != 1:
		arms.actual_weapon_index = 1
		arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
		state_machine.transition_to("SwappingWeapon")
		return

func loadWeapon(index):
	for x in arms.weaponHolder.get_child_count():
		arms.weaponHolder.get_child(x).being_used = false
		arms.weaponHolder.get_child(x).visible = false

#me pilla index 1 porque no termina de borrarse el arma. Hay que asegurarse de que el player al morir se le setee la arma que tiene en la clase, sea la actualWeapon y se le haga un loadWeapon de la que tiene actualmente
	arms.weaponHolder.get_child(index).being_used = true
	arms.weaponHolder.get_child(index).visible = true

func replace_weapon_content(weapon : Node3D):
	for child : Node in weapon.get_children():
		child.queue_free()

func exit():
	arms.actualWeapon.leftArm.get_active_material(0).albedo_texture = arms.handsAssignedTexture
	arms.actualWeapon.rightArm.get_active_material(0).albedo_texture = arms.handsAssignedTexture
	arms.playerSwappingWeapons.emit()
	
	var playerWeaponDict : Dictionary = { "id" = arms.player.name }
	playerWeaponDict["actualWeaponName"] = arms.actualWeapon.weaponData.name
	playerWeaponDict["actualWeaponPath"] = arms.actualWeapon.weaponData.weaponScene
	
	playerWeaponDict["primaryWeaponName"] = arms.weaponHolder.get_child(0).weaponData.name
	playerWeaponDict["primaryWeaponPath"] = arms.weaponHolder.get_child(0).weaponData.weaponScene
	
	if arms.weaponHolder.get_child_count() > 1:
		playerWeaponDict["secondaryWeaponName"] = arms.weaponHolder.get_child(1).weaponData.name
		playerWeaponDict["secondaryWeaponPath"] = arms.weaponHolder.get_child(1).weaponData.weaponScene
	
	arms.updatePlayerWeaponStatus.rpc(playerWeaponDict)
	
	if is_multiplayer_authority():
		arms.actualWeapon.being_used = true
