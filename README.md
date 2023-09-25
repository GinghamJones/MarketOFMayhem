# MarketOFMayhem
 A 3D arena brawler

If you decide to contribute, feel free to add a pull request. I'd love to see this thing get updated!

Due to my 'humerous' naming of things, this project is a bit PG-13.

#########################################################################################################################

Outline:
This game pits 7 teams of 3 against each other in an all-out brawl set in a grocery store. Each character has a 
basic punch move, a projectile attack, and a special melee attack (which unfortunately hasn't been implemented). 
2 game modes were in progress, a timed mode and an elimination mode. A dev mode is also included which 
allows free roaming and spawning individual characters. The 7 teams are:

(and keep in mind these are rough stat estimates)
Produce : Shoots a banana which drops a peel causing other players to slip. Has a carrot hammer. Average speed/health.
Meat : Shoots a high velocity/high damage knife. Slaps people with a fish. Average speed/lower health
Cashier : Shoots coins like a machine gun. "You wanna' bag with dat??" throws a bag over enemy and stuns. High speed/low health
Baker : Shoots frosting which slows and does minor damage. Slams a pie at enemy. Low speed/average health
Kitchen : Throws food. Smacks with a frying pan. Higher speed/average health
Freight : Beams laser at enemies for high damage. Smacks with a ladder. Low speed/high health.
Floral : Flings vase of flowers. Swings boquet to poison enemy. Average speed/average health.

There's also a Manager character who is supposed to spawn mid-way through a match and hunt a random player. If the 
player is caught, it's viciously smacked and sent flying across the store. The Manager is damn near invincible.

Lastly, a Customer was planned who would wander in the store and could be beaten up for extra ammo. I'm not sure this
is the best idea though.

The physics engine has been switched to Jolt because it seems more reliable and performant than Godot Physics.

#########################################################################################################################

How execution works:

Execution begins with the SceneLoader node located in res://. This immediately calls to load the character selection 
screen. The GameSelection scene is located in Menu/GameSelect along with the GameModes in the corresponding folder.
Once a character and game mode are selected, play begins!

The main world is loaded when the game starts so that's taken care of before "play" is pressed. The characters are then 
instantiated using a SpawnManager global scene. Each character is given a Controller as a child. The player controller
is labeled PlayerMovement and is in Characters/Resources. Don't ask me why... The AI controller is in AI/Base. 
I used "Base" because I was planning on creating different controllers for different characters to play to their strengths.
There's a Manager character too located in NPC.

#########################################################################################################################

How AI currently works:

Look, I had a whole AI system written out once. I still have the old files but it was a mess and I broke it at some point. 
So for now things are extremely simple: the AI chooses 3 things to do each frame, a targetting action, movement action, and
an attack action. There's no state machine or decision tree, just a bunch of if/else statements. This seemed to me the best
since we need to both target, move, and attack sometimes all at the same time. But indeed, maybe it's not. Anyway:

Targetting: If there's no target, we check if a target is available in the DetectionArea node in the Controller. If not,
we check for a position to wander to and calculate one if there isn't one. If we have a target, we check if the target is
valid. What does 'valid' mean? So far, just that the target isn't dead yet. One idea is to set this up to where we determine
how many other opponents are nearby: if there are too many, run away, if just a few, select one as a target and wail on 'em,
if there are none, wander around. I considered making some more complex decisions like checking health stats to determine if
it should run away or switch to ranged combat. Also, a check for Managers should happen 'cause no one wants to fight them..

Movement:
Right now, movement is just 'move forward and look at target position'. I wanted to implement random strafing, dodging
projectiles, and backing up after attempting to punch. 

Attack:
There's a PunchThinkTimer and a FireThinkTimer so that things don't happen at an inhuman speed. It doesn't work very well yet.
But either the character decides to punch if close enough, or shoot if far away enough. Special attacks need to be implemented
too and should be preferred if available.

Target detection depends on DetectionArea which has its own script for populating an array of opponents in sight. A raycast
is used to determine if the opponent is behind an obstacle or not but this needs some tweaking. 

#########################################################################################################################

Things to do:

1) AI needs a lotttttt of work.
    - Prevent from moving back into spawn point after leaving
    - Make actions more sensicle.
    - Create specialized AI scripts to play to character strengths
    - Improve Manager AI.
    - Prevent from pooling in same spot
2) Implement special attacks. There is a SpecialAttach node on each Character which would spawn the attack and an animation
    would play.
3) Ragdolling is reallllly weird right now. Sometimes it works as intended, sometimes dudes go flying and stretching all to 
    hell. 
4) Obvious visual updates would be ideal to the menus and HUD.
5) More/upgraded VFX 
6) Fine tuning of movement. Dodging is especially spotty for all characters right now but is an easy parameter fix (I think).
    Projectile speed/angle and movement speed are also in need of tuning.
7) Freight's laser effect isn't working right.
8) Baker's camera is really jittery for some reason.
9) Fix spawn barriers. Characters should not be able to move back into spawn points.
10) Camera can clip through walls and obstacles. Maybe could use raycasts to determine if it's about to hit obstacle and 
    guide camera away from the obstacle. 
11) Elimination hasn't been finished.
12) Hit shader applies to all characters of same team.
13) Performance optimizations. Nothing identified yet but performance isn't as good as it should be for such a small game.
