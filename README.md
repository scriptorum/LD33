# LD33: Flappy Monster
Ludum Dare #33 compo

This is the post-compo version of my game from Ludum Dare 33. Theme: You are the monster.

For the compo version submitted to LD33, go to the [LD33/compo branch](https://github.com/scriptorum/LD33/tree/compo). You can also [play the game](http://ludumdare.com/compo/ludum-dare-33/?action=preview&uid=17811) on Ludum Dare

## Changes from the compo version
- Slight camera shake on building demolition
- Smoother movement on monster positioning
- Revised map generator leads to fewer impossible pike/building setups
- Monster now slows down with increasing deceleration (more Flappy-like feel)
- Updated and animated pikes. Easier to distinguish now.
- Left click and SPACEBAR are now interchangeable.
- After death, do not put up start button until after sfx.
- Added monster shading, highlights, and selout.
- Added smoke demolition effect.
- Improved building edging.
- Added rubble effect
- Disgusting monster speedup sound effects
- Score more points the faster you travel

## Stuff that didn't make it into the compo version
- Foot pounding
- Flap puff dust
- Tree parallax
- Villagers escaping buildings/running from you
- Sun lowers/Sunset as difficulty rise
- Tutorial tips to explain the game as you run
- Test variant pike rules (for a variation of max speeds)
- Better indicators of whether you're going fast/slow enough to deal with obstacles
- Music? What music?

## To Do
- Examine Threadbare preloader which just showed at 0% in practice
- Do some barebones audio testing to figure out why the first sound played always comes at a delay
- Award score based on SPEED, not just distance. Going faster earns more points!

## Build Notes
- Export Spriter files with a custom rect of -80,-70,60,30 to make all the cells 141x101. I had a hard time working with this tool!


