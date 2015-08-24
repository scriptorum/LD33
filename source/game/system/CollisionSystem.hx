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

		var pos:Float = monsterEnt.get(Position).x + 12;
		var monster:Monster = monsterEnt.get(Monster);

		var nextFeatureEnt:Entity = f.getEntity(monster.nextFeatureId, false);
		if(nextFeatureEnt == null)
			return;
		
		// Check for player collision with next collidable feature
		if(pos >= f.getComponent(nextFeatureEnt, Position).x)
		{
			var feature = f.getComponent(nextFeatureEnt, Feature);
			switch(feature.type)
			{
				case Building:
					resolveBuildingCollision(monster, feature, nextFeatureEnt);
				case Pikes:
					resolvePikesCollision(monster);
				case Empty:
				case Rubble:
			}

	 		// Update "next feature" pointer for monster
	 		monster.nextFeatureId = feature.nextId;
		}
	 }

	 // TODO Add puff of smoke
	 public function doSmokeFx()
	 {
		// var emitter = new Emitter("art/particle-smoke.png");
		// emitter.destroyEntity = true;
		// emitter.maxParticles = Math.floor(radius * radius / 15);
		// emitter.lifespan = 1.0;
		// emitter.lifespanRand = 0.1;
		// emitter.distance = radius * 1.5;
		// emitter.rotationRand = new Rotation(360);
		// emitter.stopAfterSeconds = 0.3;
		// emitter.emitRadiusRand = radius / 10;
		// emitter.alphaStart = 0.2;

		// var e = flaxen.newEntity("emitter")
		// 	.add(new Layer(10))
		// 	.add(position.clone());

		// // Delay emitter start
		// e.add(new ActionQueue()
		// 	.delay(0.25)
		// 	.addComponent(e, emitter));
	}

	// TODO Ugh, I seem to have a bug in Flaxen where an HP Entity is not removed when the Image component is removed.
	//      I have to remove the Display component as well. Tsk, shouldn't be that way.
	// featureEnt.remove(Image);
	// featureEnt.remove(Layer);
	// featureEnt.remove(flaxen.component.Display);
	 public function resolveBuildingCollision(monster:Monster, feature:Feature, featureEnt:Entity)
	 {
	 	// Successful demolition
	 	if(feature.size <= monster.speed)
	 	{
	 		// Replace building with rubble
	 		feature.type = Rubble;
			featureEnt.remove(flaxen.component.Display);
	 		featureEnt.add(new Image('art/rubble${feature.size}.png'));

	 		// Show puff of smoke
	 		doSmokeFx();

	 		// Collision sound
	 		var id = flaxen.util.MathUtil.rndInt(1,3);
	 		f.newSound('sound/destroy$id.wav');

	 		// Slow down monster
	 		monster.nextSpeed = monster.speed - feature.size *.8;
	 	}

	 	// Unsuccessful demo
	 	else if(!f.hasMarker("godMode"))
	 	{
	 		f.newSound("sound/crack.wav");

		 	// Trigger knockback collision
		 	monster.nextSpeed = -2;

		 	// TODO Popup message and score
	 	}

	 }

	 public function resolvePikesCollision(monster:Monster)
	 {
	 	if(f.hasMarker("godMode"))
	 		return;

	 	if(monster.speed <= 4)
	 		return; // Safe to pass at slow speed

	 	// Otherwise you die!
	 	f.newSound("sound/ouch.wav");

	 	// Trigger monster pike anim
	 	monster.nextSpeed = -3;

	 	// TODO Popup message and score
	 }
}
