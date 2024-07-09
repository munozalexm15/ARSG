extends ArmsState

var bullet_reload_time : float
var wantsToShoot = false

func enter(_msg := {}):
	set_process(true)
	if arms.actualWeapon.being_used == false:
		state_machine.transition_to("Idle")
		return
	
	wantsToShoot = false
	
	if arms.actualWeapon.weaponData.isBoltAction:
		if arms.actualWeapon.weaponData.weaponType == "Sniper":
			arms.actualWeapon.handsAnimPlayer.play(arms.actualWeapon.weaponData.name + "_Bolt")
			arms.actualWeapon.bolt_back_sound.play()
			await arms.actualWeapon.handsAnimPlayer.animation_finished
		arms.actualWeapon.handsAnimPlayer.play(arms.actualWeapon.weaponData.name + "_Enter_Reload")
		await arms.actualWeapon.handsAnimPlayer.animation_finished
		reload_bullet_by_bullet()
	else:
		if arms.actualWeapon.weaponData.bulletsInMag > 0:
			arms.actualWeapon.handsAnimPlayer.play(arms.actualWeapon.weaponData.name + "_Reload")
			arms.actualWeapon.reload_sound.play()
			arms.reloadTimer.wait_time = arms.actualWeapon.reload_sound.stream.get_length() + 0.2
		else:
			arms.actualWeapon.handsAnimPlayer.play(arms.actualWeapon.weaponData.name + "_Full_Reload")
			arms.actualWeapon.full_reload_sound.play()
			arms.reloadTimer.wait_time = arms.actualWeapon.full_reload_sound.stream.get_length() + 0.2
		
		arms.reloadTimer.start()

func physics_update(_delta):
	mouse_swap_weapon_logic()
	swap_weapon()
	
	if Input.is_action_just_pressed("Fire") and arms.actualWeapon.weaponData.isBoltAction:
		wantsToShoot = true
		if arms.actualWeapon.weaponData.weaponType == "Sniper":
			arms.actualWeapon.handsAnimPlayer.play(arms.actualWeapon.weaponData.name + "_Bolt", -1, -1, true)
			arms.actualWeapon.bolt_forward_sound.play()
			await arms.actualWeapon.handsAnimPlayer.animation_finished
			arms.actualWeapon.handsAnimPlayer.assigned_animation = "RESET"
		else:
			arms.actualWeapon.handsAnimPlayer.play(arms.actualWeapon.weaponData.name + "_Enter_Reload", -1, -1, true)
			await arms.actualWeapon.handsAnimPlayer.animation_finished
		_on_reload_timer_timeout()
		return

func mouse_swap_weapon_logic():
	if Input.is_action_just_pressed("Next Weapon") or Input.is_action_just_pressed("Previous Weapon"):
		_on_reload_timer_timeout()
		if Input.is_action_just_pressed("Next Weapon"):
			if arms.actual_weapon_index < arms.weaponHolder.get_child_count() -1:
				arms.actual_weapon_index += 1
			else:
				arms.actual_weapon_index = 0
			arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
			
		if Input.is_action_just_pressed("Previous Weapon"):
			if arms.actual_weapon_index < arms.weaponHolder.get_child_count() -1:
				arms.actual_weapon_index += 1
			else:
				arms.actual_weapon_index = 0
			arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
		
		arms.actualWeapon.reload_sound.stop()
		#arms.actualWeapon.full_reload_sound.stop()
		arms.reloadTimer.stop()
		state_machine.transition_to("SwappingWeapon")
	
func swap_weapon():
	if (Input.is_action_just_pressed("Primary weapon") and arms.actual_weapon_index != 0) or (Input.is_action_just_pressed("Secondary weapon") and arms.actual_weapon_index != 1):
		_on_reload_timer_timeout()
		if Input.is_action_just_pressed("Primary weapon"):
			if arms.actual_weapon_index != 0:
				arms.actual_weapon_index = 0
				arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
			
		if Input.is_action_just_pressed("Secondary weapon") and arms.actual_weapon_index != 1:
			if arms.actual_weapon_index != 1:
				arms.actual_weapon_index = 1
				arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
		
		if not arms.actualWeapon.isBoltAction:
			arms.actualWeapon.reload_sound.stop()
			arms.actualWeapon.full_reload_sound.stop()
		else:
			arms.actualWeapon.reload_sound.stop()
		arms.reloadTimer.stop()
		state_machine.transition_to("SwappingWeapon")
		


func _on_reload_timer_timeout():
	arms.reloadTimer.stop()
	
	if not arms.actualWeapon.weaponData.isBoltAction:
		arms.actualWeapon.reload_sound.play()
		ammo_behavior()
	state_machine.transition_to("Idle")
	

func reload_bullet_by_bullet():
	if arms.actualWeapon.being_used == false:
		state_machine.transition_to("Idle")
		return
	
	if wantsToShoot:
		wantsToShoot = false
		arms.actualWeapon.reload_sound.play()
		state_machine.transition_to("Idle")
		return
	
	if arms.actualWeapon.weaponData.bulletsInMag >= arms.actualWeapon.weaponData.magSize:
		if arms.actualWeapon.weaponData.weaponType == "Sniper":
			arms.actualWeapon.handsAnimPlayer.play(arms.actualWeapon.weaponData.name + "_Bolt", -1, -1, true)
			arms.actualWeapon.bolt_forward_sound.play()
			await arms.actualWeapon.handsAnimPlayer.animation_finished
			arms.actualWeapon.handsAnimPlayer.assigned_animation = "RESET"
		else:
			arms.actualWeapon.handsAnimPlayer.play(arms.actualWeapon.weaponData.name + "_Enter_Reload", -1, -1, true)
			await arms.actualWeapon.handsAnimPlayer.animation_finished
		_on_reload_timer_timeout()
		return
	
	if arms.actualWeapon.weaponData.reserveAmmo == 0:
		if arms.actualWeapon.weaponData.weaponType == "Sniper":
			arms.actualWeapon.handsAnimPlayer.play(arms.actualWeapon.weaponData.name + "_Bolt", -1, -1, true)
			arms.actualWeapon.bolt_forward_sound.play()
			await arms.actualWeapon.handsAnimPlayer.animation_finished
		else:
			arms.actualWeapon.handsAnimPlayer.play(arms.actualWeapon.weaponData.name + "_Enter_Reload", -1, -1, true)
			await arms.actualWeapon.handsAnimPlayer.animation_finished
		arms.actualWeapon.handsAnimPlayer.assigned_animation = "RESET"
		state_machine.transition_to("Idle", {"play_reload": false})
		return
	
	bullet_reload_time = arms.actualWeapon.weaponData.reloadTime / arms.actualWeapon.weaponData.magSize
	
	arms.actualWeapon.handsAnimPlayer.play(arms.actualWeapon.weaponData.name + "_Reload")
	arms.actualWeapon.reload_sound.play()
	await arms.actualWeapon.handsAnimPlayer.animation_finished
	
	arms.actualWeapon.weaponData.bulletsInMag += 1
	arms.actualWeapon.weaponData.reserveAmmo -= 1
	for x in arms.weaponHolder.get_child_count():
		if arms.weaponHolder.get_child(x) != arms.actualWeapon and arms.weaponHolder.get_child(x).weaponData.weaponCaliber == arms.actualWeapon.weaponData.weaponCaliber:
			arms.weaponHolder.get_child(x).weaponData.reserveAmmo -= 1
	
	reload_bullet_by_bullet()

func ammo_behavior():
	var ammoLeft = arms.actualWeapon.weaponData.bulletsInMag
	if (arms.actualWeapon.weaponData.magSize - ammoLeft) <= arms.actualWeapon.weaponData.reserveAmmo:
		arms.actualWeapon.weaponData.reserveAmmo -= arms.actualWeapon.weaponData.magSize - ammoLeft
		arms.actualWeapon.weaponData.bulletsInMag += arms.actualWeapon.weaponData.magSize - ammoLeft
	
	#If both weapons share the same caliber, subtract to both weapons the reserve ammo
		for x in arms.weaponHolder.get_child_count():
			if arms.weaponHolder.get_child(x) != arms.actualWeapon and arms.weaponHolder.get_child(x).weaponData.weaponCaliber == arms.actualWeapon.weaponData.weaponCaliber:
				arms.weaponHolder.get_child(x).weaponData.reserveAmmo -= arms.actualWeapon.weaponData.magSize - ammoLeft

#if not, give the remaining reserve ammo to the mag
	else:
		arms.actualWeapon.weaponData.bulletsInMag += arms.actualWeapon.weaponData.reserveAmmo
		arms.actualWeapon.weaponData.reserveAmmo = 0
	
func exit():
	if arms.actualWeapon.reload_sound.playing and arms.actualWeapon.reload_sound:
		arms.actualWeapon.reload_sound.stop()
	set_process(false)

