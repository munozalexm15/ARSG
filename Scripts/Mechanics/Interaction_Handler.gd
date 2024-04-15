extends RayCast3D

@onready var label = $"../../../../UI/CenterContainer2/Label"

@onready var arms = $"../arms"
signal swap_weapon(weapon)

# Called when the node enters the scene tree for the first time.
func _ready():
	add_exception(owner)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	label.text = ""
	if is_colliding():
		var interactable = get_collider()
		var isInHolder = false
		if interactable is Interactable:
			for x in arms.weaponHolder.get_child_count():
				if interactable.weaponData.name == arms.weaponHolder.get_child(x).weaponData.name:
					isInHolder = true
			
			if isInHolder:
				label.text = "Press 'Interact' to pickup ammo"
			else:
				label.text = "Press 'Interact' to swap for "  + interactable.name
				
			if Input.is_action_just_pressed("Interact"):
				swap_weapon.emit(interactable)
