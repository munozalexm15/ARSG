"# ARSG" 
## TODO:

### GUN PLAY
 - Bullet impact decals
 - Add clipping gun prevention

### MECHANICS
 - Add ammo boxes (refills actual weapon or both)
 - Add healing items

## WEAPON LIST
 - ARs
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