"# ARSG" 
## TODO:

### GUN PLAY
 - Bullet impact decals

### MECHANICS
 - Add super ammo boxes (refills ammo of all weapons)
 - Add healing items
 - Climb ladders

## WEAPON LIST
 - Grenades
 - Rocket launcher / Grenade Launcher
 
### UI / HUD
 - Menu
 - Show player state (crouched, running, standing -> like COD1)
 - Show Health(maybe?)
 
### OTHER:
 - Preload all possible pickup weapons on scene start, so it doesn't lag when picking up ones (pool maybe)
 	#### -> OPTION 0: Put the pickup as string but the weapon as packed scene and preload it
	#### -> OPTION 1: You could have a pool of created objects and store them somewhere, hidden with process and physics process disabled and instead of instantiating a new object, take one object out of the pool and set it up. When you want to destroy it, don't free it, just store it in the pool 