package game.system;

import ash.core.Entity;
import game.common.Config;
import flaxen.component.Display;
import flaxen.Flaxen;
import flaxen.FlaxenSystem;
import flaxen.common.LoopType;
import flaxen.component.Alpha;
import flaxen.component.Emitter;
import flaxen.component.Gravity;
import flaxen.component.Image;
import flaxen.component.Layer;
import flaxen.component.Offset;
import flaxen.component.Position;
import flaxen.component.Rotation;
import flaxen.component.Scale;
import flaxen.component.Sound;
import flaxen.component.Tween;
import flaxen.component.Velocity;
import flaxen.service.CameraService;
import flaxen.util.MathUtil;
import game.component.Feature;
import game.component.Monster;

class CollisionSystem extends FlaxenSystem
{
	private var smokeLayer:Layer = new Layer(30);

	// private static var lastPoolSize:Int = 0;
	private var rubblePool:Array<Entity>;
	private var rubbleLayer:Layer = new Layer(20);
	private var rubbleComponents:Array<Dynamic> = [new Layer(20), new Image("art/brick.png"), Offset.center(), new Gravity(0, 300)];

	public function new(f:Flaxen)
	{ 
		super(f);
		rubblePool = new Array<Entity>();
	}

	override public function update(time:Float)
	{
		// if(flaxen.service.InputService.released(com.haxepunk.utils.Key.F))
		// {
		// 	doRubbleFlying(5, new Position(650, 250));
		// }

		var monsterEnt:Entity = f.getEntity("monster", false);
		if(monsterEnt == null)
			return; // no monster found; disable system

		var pos:Float = f.getComponent(monsterEnt, Position).x + 12 + CameraService.getX();
		var monster:Monster = f.getComponent(monsterEnt, Monster);

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
	 		#if debug
	 		if(feature.nextId == null)
	 			trace("Feature.nextId is null!");
	 		#end
		}

		// if(lastPoolSize != rubblePool.length)
		// {
		// 	lastPoolSize = rubblePool.length;
		// 	trace("Pool Size:" + lastPoolSize);
		// }
	 }

	 // Show puff of smoke
	 public function doSmokeFx(size:Int, pos:Position)
	 {
	 	var data = Config.buildingSizeToArea[size];
		var emitter = new Emitter("art/smoke.png");
		emitter.onComplete = DestroyEntity;
		emitter.maxParticles = 15 + size * size * 20;
		emitter.lifespan = 2.3;
		emitter.lifespanRand = 0.1;
		emitter.distance = data.y;
		emitter.rotation = new Rotation(-90 + 45);
		emitter.gravity = -5;
		emitter.gravityRand = -5;
		emitter.stopAfterSeconds = 0.6;
		emitter.emitRectRand = { x:data.x, y:data.y / 2 };
		emitter.colorStart = 0x666666;
		emitter.colorEnd = 0xFFFFFF;
		emitter.alphaStart = 0.5;

		var e = f.newEntity("emitter#")
			.add(emitter)
			.add(smokeLayer)
			.add(new Position(pos.x + data.x/2, pos.y - data.y / 4));
	}

	 // Show rubble flying
	 public function doRubbleFlying(size:Int, mainPos:Position)
	 {
		// var start = haxe.Timer.stamp();
		// var amount = (size + 10) * 100;
		var amount = (size * 2 + 10);

 		for(i in 0...amount)
 			loadRubble(size, mainPos);

		// var end = haxe.Timer.stamp();
		// trace("Elapsed:" + (end - start));
 	}

 	/**
 	 * Load one rubble from the pool or create it.
 	 */
 	public function loadRubble(size:Int, mainPos:Position)
	{
		var data = Config.buildingSizeToArea[size];

		var e:Entity;
		if(rubblePool.length > 0)
			e = rubblePool.pop();
		else
		{
			e = f.newEntity("brick#", false)
				.add(new Rotation(0))
				.add(new Alpha(1.0))
				.add(Position.zero())
				.add(Offset.center())
				.add(Scale.full())
				.add(Velocity.zero());
			for(c in rubbleComponents)
				e.add(c);
		}

		// Adjust values
		var rot = e.get(Rotation);
		rot.angle = MathUtil.rnd(0.0, 360.0);
		var alpha = e.get(Alpha);
		alpha.value = 1.0;
		e.get(Position).set(mainPos.x + MathUtil.rnd(0, data.x), mainPos.y + MathUtil.rnd(0, -data.y));
		e.get(Scale).set(MathUtil.rnd(0.5, 1.0 + (size/2.5)));
		e.get(Velocity).set(MathUtil.rnd(-100, 400), -200);
		var tween = new Tween (MathUtil.rnd(0.5, 1.0), null, MathUtil.rndBool() ? LoopType.Forward: LoopType.Backward)
			.to(rot, "angle", rot.angle + 360);
		e.add(tween);

		// Add entity to Ash
		f.addEntity(e);

		// Give entity fade out and return to pool
		f.newActionQueue()
			.wait(1.5)
			.call(function() f.newTween(0.25).to(alpha, "value", 0.0) )
			.wait(0.25)
			.removeEntity(e) // Remove entity from Ash
			.removeComponent(e, Display) // Do not cache Display component
			.call(function() rubblePool.push(e)); // Add entity to pool
	}

	// TODO Ugh, I seem to have a bug in Flaxen where an HP Entity is not removed when the Image component is removed.
	//      I have to remove the Display component as well. Tsk, shouldn't be that way. Verify bug.
	// featureEnt.remove(flaxen.component.Display);
	 public function resolveBuildingCollision(monster:Monster, feature:Feature, featureEnt:Entity)
	 {
	 	var speed:Float = 0.0;
	 	switch(monster.state)
	 	{
	 		case Running(s):
	 		speed = s;

	 		default:
	 		return; // Cannot collide if not running!
	 	}

	 	// Successful demolition
	 	if(feature.getMinBuildingDemoSpeed() <= speed)
	 	{

			// trace("Building demo occurs! size:" + feature.size + " speed:" + speed + " min:" + feature.getMinBuildingDemoSpeed());

	 		// Show puff of smoke
 			var pos:Position = f.getComponent(featureEnt, Position);
	 		doSmokeFx(feature.size, pos);

	 		// Add some rubble flying
	 		doRubbleFlying(feature.size, pos);

	 		// Collision sound
	 		var id = MathUtil.rndInt(1,3);
	 		f.newSound('sound/destroy$id.wav');

	 		// Collision shake
	 		if(feature.size > 0)
 				CameraService.shake(cast 1 + feature.size / 2, 0.25 + (feature.size / 30));

	 		// Replace building with rubble
	 		featureEnt
	 			.add(new Image('art/rubble${feature.size}.png'))
	 			.add(rubbleLayer)
	 			.remove(flaxen.component.Display);
	 		feature.type = Rubble;

	 		// Slow down monster from collision
	 		monster.nextState = Running(Math.max(0, speed - (feature.size + 1) * 2));
	 	}

	 	// Unsuccessful demo
	 	else if(!f.hasMarker("godMode"))
	 	{
	 		playDeath("crack");

		 	// Trigger knockback collision
		 	monster.nextState = Knockback;
	 	}

	 }

	 public function playDeath(soundName:String)
	 {
 		var sound = f.newSound('sound/$soundName.wav');
 		f.newActionQueue()
 			.waitForComplete(sound)
 			.call(function() { f.newMarker("deathSoundComplete"); });
	 }

	 public function resolvePikesCollision(monster:Monster)
	 {
	 	if(f.hasMarker("godMode"))
	 		return;

	 	var speed:Float = 0.0;
	 	switch(monster.state)
	 	{
	 		case Running(s):
	 		speed = s;

	 		default:
	 		return; // Cannot collide if not running!
	 	}

	 	if(speed <= Config.maxPikeSpeed)
	 		return; // Safe to pass at slow speed

	 	// Otherwise you die!
	 	playDeath("ouch");

	 	// Trigger monster pike anim
	 	monster.nextState = Piked;
	 }
}
