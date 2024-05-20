# ARSG

##CAMPAIGN MECHANICS
The campaign will have 4 chapters, each one player will control a soldier of the same family (great grandfather, grandfather, father, son) and the objective of the players will be to complete each campaign.
If they die, the campaign continues but in the next chapter, with the next family member. 
Depending of the player choices, each chapter will have different results.



## GAME HISTORY (if I get to do it)
4 main chapters -> 

### THE GREAT WAR
 First world war, russian pov

### A GREAT PATRIOTIC WAR
 Second world war, beginning in the operation barbarossa, russian pov
 
### PROXY WAR
 Cold war, russian forming part of a militia pov
 
### THE WAR THAT ENDED ALL
 Third world war, russian civilian (depending if all the other protagonist of each chapter survive, the game will have an ending or another)


## TODO:

### GUN PLAY
 - Bullet impact decals

### MECHANICS
 - Add super ammo boxes (refills ammo of all weapons) 
 - Add health system //falta mecanica curarse - Hud done 
 - Pensar en como equilibrar el tema de la salud para multiplayer -> Hacer que todos los jugadores tengan un botiquin y si no lo usan lo dropean al morir
 - Add healing items
 - Climb ladders (tbd)

## WEAPON LIST
 - Grenades
 - Rocket launcher / Grenade Launcher
 
### UI / HUD
 - Menu
 - Show player state (crouched, running, standing -> like COD1)
 
### OTHER:
 - Preload all possible pickup weapons on scene start, so it doesn't lag when picking up ones (pool maybe)
 	#### -> OPTION 0: Put the pickup as string but the weapon as packed scene and preload it
	#### -> OPTION 1: You could have a pool of created objects and store them somewhere, hidden with process and physics process disabled and instead of instantiating a new object, take one object out of the pool and set it up. When you want to destroy it, don't free it, just store it in the pool 