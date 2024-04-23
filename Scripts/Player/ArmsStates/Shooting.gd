extends ArmsState


func enter(_msg := {}):
	pass

func _physics_update(delta):
	reload_listener()
	mouse_swap_weapon_logic()
	swap_weapon()

func mouse_swap_weapon_logic():
	if not Input.is_action_pressed("Next Weapon") or not Input.is_action_pressed("Previous Weapon"):
		return
	
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
		
	state_machine.transition_to("SwappingWeapon")
	
func swap_weapon():
	if not Input.is_action_pressed("Primary weapon") or not Input.is_action_pressed("Secondary weapon"):
		return
	
	if Input.is_action_just_pressed("Primary weapon"):
		if arms.actual_weapon_index != 0:
			arms.actual_weapon_index = 0
			arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)
		
	if Input.is_action_just_pressed("Secondary weapon"):
		if arms.actual_weapon_index != 1:
			arms.actual_weapon_index = 1
			arms.player.eyes.get_child(0).setRecoil(arms.actualWeapon.weaponData.recoil)

	state_machine.transition_to("SwappingWeapon")

func reload_listener():
	if arms.actualWeapon.weaponData.bulletsInMag <= 0 and arms.actualWeapon.weaponData.reserveAmmo > 0:
		state_machine.transition_to("Reload")
