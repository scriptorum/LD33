package game.system;

import ash.core.Entity;
import ash.core.Node;
import ash.core.System;
import flaxen.component.Image;
import flaxen.component.Layer;
import flaxen.component.Offset;
import flaxen.component.Position;
import flaxen.component.Velocity;
import flaxen.Flaxen;
import flaxen.FlaxenSystem;
import game.common.FeatureType;
import game.component.Feature;
import game.node.FeatureNode;
import game.component.Monster;

class CollisionSystem extends FlaxenSystem
{
	public function new(f:Flaxen)
	{ 
		super(f);
	}

	override public function update(time:Float)
	{
		var monsterEnt:Entity = f.getEntity("monster", false);
		if(monsterEnt == null)
			return; // no monster found; disable system

		var pos:Float = monsterEnt.get(Position).x + monsterEnt.get(Image).width - 5;
		var monster:Monster = monsterEnt.get(Monster);

		var nextFeatureEnt:Entity = f.getEntity(monster.nextFeatureId, false);
		if(nextFeatureEnt == null)
			return; // No next feature, disable system
		
		// Check for player collision with next collidable feature
		if(pos >= f.getComponent(nextFeatureEnt, Position).x)
		{
			var feature = f.getComponent(nextFeatureEnt, Feature);
			trace("Collision with " + feature.type + " named " + nextFeatureEnt.name);
			switch(feature.type)
			{
				case Building:
					resolveBuildingCollision(monster, feature, nextFeatureEnt);
				case Pikes:
					resolvePikesCollision(monster);
				case Empty:
					monster.nextFeatureId = feature.nextId; // Thanks, move to the next feature
			}
		}
	 }

	 public function resolveBuildingCollision(monster:Monster, feature:Feature, featureEnt:Entity)
	 {
	 	if(feature.size <= monster.speed)
	 	{
	 		// Remove building
	 		// TODO Ugh, I seem to have a bug in Flaxen where an HP Entity is not removed when the Image component is removed.
	 		//      I have to remove the Display component as well. Tsk, shouldn't be that way.
	 		feature.type = Empty;
	 		featureEnt.remove(Image);
	 		featureEnt.remove(Layer);
	 		featureEnt.remove(flaxen.component.Display);

	 		// TODO Leave ruin
	 		// TODO Show puff of smoke
	 		// TODO Collision sound
	 		trace("Kaboom");

	 		// Slow monster
	 		monster.speed -= feature.size;
	 		monster.speedChanged = true;

	 		// Update "next feature" pointer for monster
	 		trace("Changing nextFeatureId:" + monster.nextFeatureId + " to feature.nextId:" + feature.nextId);
	 		monster.nextFeatureId = feature.nextId;
	 	}

	 	else
	 	{
	 		trace("BONK!");
		 	// TODO Add death sequence, play sound, show sitting monster with headache and seeing stars
		 	// TODO Update speed to null
		 	// TODO Change connotation of speed 0 to speed 1 and up them all because it's frankly confusing, also change building sizes +1, duh
		 	// TODO Remove input controls
		 	// TODO Popup message and score
	 	}

	 }

	 public function resolvePikesCollision(monster:Monster)
	 {
	 	if(monster.speed <= 1)
	 		return; // Safe to pass at slow speed

	 	// Otherwise you die! TODO
	 	trace("You die from violent painful spikes! Why did you have to go so fast?!!!");
	 	// TODO Add death sequence, play sound, show dead guy
	 	// TODO Update speed to null
	 	// TODO Change connotation of speed 0 to speed 1 and up them all because it's frankly confusing, also change building sizes +1, duh
	 	// TODO Remove input controls
	 	// TODO Popup message and score
	 }
}
