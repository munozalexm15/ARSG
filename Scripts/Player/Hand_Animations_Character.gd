extends Node3D

@export var animationNode := NodePath()
@onready var animationPlayer : AnimationPlayer = get_node(animationNode)

@export var playerNode := NodePath()
@onready var player : Player = get_node(playerNode)

@onready var weaponHolder = $WeaponHolder

var actual_weapon_index = 0
var actualWeapon
var actual_animation = ""
var isSwappingWeapon = false
var isReloading = false

var cam_rotation_amount : float = 0.01
var weapon_rotation_amount : float = 0.01
var weapon_sway_amount : float = 5
var invert_weapon_sway : bool = false

var mouse_input : Vector2

var default_weaponHolder_pos = Vector3(Vector3.ZERO)

# Called when the node enters the scene tree for the first time.
func _ready():
	weaponHolder.get_child(actual_weapon_index).visible = true
	animationPlayer.play("Idle")
	default_weaponHolder_pos = weaponHolder.position
	actualWeapon = weaponHolder.get_child(actual_weapon_index)
	loadWeapon(actual_weapon_index)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_input = event.relative
	
	swap_weapon()
	mouse_swap_weapon_logic()
	
	if Input.is_action_pressed("Reload") and actualWeapon.WeaponData.bulletsInMag < actualWeapon.WeaponData.magSize and not isReloading:
		animationPlayer.play("Reload")
		isReloading = true

func _process(delta):
	#cam_tilt(player.input_direction.x, delta)
	weapon_tilt(player.input_direction.x, delta)
	weapon_sway(delta)
	reload_listener()
	
func _physics_process(delta):
	pass
	
func cam_tilt(input_x, delta):
	if player.camera:
		player.camera.rotation.z = lerp(player.camera.rotation.z, -input_x * cam_rotation_amount, 10 * delta)

func weapon_tilt(input_x, delta):
	if weaponHolder:
		weaponHolder.rotation.y = lerp(weaponHolder.rotation.y, -input_x * weapon_rotation_amount * 10, 10 * delta)

func weapon_sway(delta):
	mouse_input = lerp(mouse_input,Vector2.ZERO,10*delta)
	weaponHolder.rotation.x = lerp(weaponHolder.rotation.x, mouse_input.y * weapon_rotation_amount * (-1 if invert_weapon_sway else 1), 10 * delta)
	weaponHolder.rotation.y = lerp(weaponHolder.rotation.y, mouse_input.x * weapon_rotation_amount * (-1 if invert_weapon_sway else 1), 10 * delta)	

func mouse_swap_weapon_logic():
	if Input.is_action_just_pressed("Next Weapon") and not isSwappingWeapon:
		isSwappingWeapon = true
		if actual_weapon_index < weaponHolder.get_child_count() -1:
			actual_weapon_index += 1
		else:
			actual_weapon_index = 0
			
		actualWeapon = weaponHolder.get_child(actual_weapon_index)
		player.eyes.get_child(0).setRecoil(actualWeapon.WeaponData.recoil)
		animationPlayer.play("HideSecondaryWeapon")
		
	if Input.is_action_just_pressed("Previous Weapon") and not isSwappingWeapon:
		isSwappingWeapon = true
		if actual_weapon_index >= 0:
			actual_weapon_index -= 1
		else:
			actual_weapon_index = get_child_count() -1
			
		actualWeapon = weaponHolder.get_child(actual_weapon_index)
		player.eyes.get_child(0).setRecoil(actualWeapon.WeaponData.recoil)
		animationPlayer.play("HideSecondaryWeapon")

func swap_weapon():
	if Input.is_action_just_pressed("Primary weapon") and not isSwappingWeapon:
		if actual_weapon_index != 0:
			isSwappingWeapon = true
			actual_weapon_index = 0
			actualWeapon = weaponHolder.get_child(actual_weapon_index)
			player.eyes.get_child(0).setRecoil(actualWeapon.WeaponData.recoil)
			animationPlayer.play("HideSecondaryWeapon")
		
	if Input.is_action_just_pressed("Secondary weapon") and not isSwappingWeapon:
		if actual_weapon_index != 1:
			isSwappingWeapon = true
			actual_weapon_index = 1
			actualWeapon = weaponHolder.get_child(actual_weapon_index)
			player.eyes.get_child(0).setRecoil(actualWeapon.WeaponData.recoil)
			animationPlayer.play("HideSecondaryWeapon")

func _on_animation_player_animation_finished(anim_name):
	if (anim_name == "Reload"):
		await get_tree().create_timer(actualWeapon.WeaponData.reloadTime).timeout
		#if its true still it means the animation hasn't been changed
		if isReloading == true:
			isReloading = false
			isSwappingWeapon = false
			actualWeapon.WeaponData.bulletsInMag = actualWeapon.WeaponData.magSize
			if player.state != "Run":
				animationPlayer.play("Idle")
			if player.state == "Run":
				animationPlayer.play("Run")
	
	if (anim_name == "HideSecondaryWeapon"):
		loadWeapon(actual_weapon_index)
		isSwappingWeapon = false
		if player.state != "Run" and not isReloading:
			animationPlayer.play("Idle")
		elif player.state == "Run" and not isReloading:
			animationPlayer.play("Run")
	

	
func loadWeapon(index):
	for x in weaponHolder.get_child_count():
		weaponHolder.get_child(x).process_mode = Node.PROCESS_MODE_DISABLED
		weaponHolder.get_child(x).visible = false
	weaponHolder.get_child(index).process_mode = Node.PROCESS_MODE_ALWAYS
	weaponHolder.get_child(index).visible = true
	

func reload_listener():
	if actualWeapon.WeaponData.bulletsInMag <= 0 and not isReloading:
		animationPlayer.play("Reload")
		isReloading = true


func _on_animation_player_animation_started(anim_name):
	if anim_name == "HideSecondaryWeapon":
		isSwappingWeapon = true

	#cancel weapon switching if player runs, crouch, etc.
	
	if (anim_name == "Run" or anim_name == "Idle") and isSwappingWeapon:
		isSwappingWeapon = false
	if anim_name != "Reload" and isReloading:
		isReloading = false

#reload cancelling
func _on_animation_player_animation_changed(old_name, new_name):
	if old_name == "Reload" and new_name != "Reload":
		isReloading = false
	if new_name == "HideSecondaryWeapon":
		isSwappingWeapon = true
