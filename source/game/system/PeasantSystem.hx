package game.system;

import ash.core.Node;
import ash.core.Entity;
import flaxen.component.Alpha;
import flaxen.component.Animation;
import flaxen.component.Tile;
import flaxen.component.Tween;
import flaxen.Flaxen;
import flaxen.FlaxenSystem;
import flaxen.component.Position;
import flaxen.component.Velocity;
import flaxen.service.CameraService;
import flaxen.util.MathUtil;
import game.common.Config;
import game.component.Feature;
import game.component.Monster;
import game.component.Peasant;
import game.node.FeatureNode;

class PeasantSystem extends FlaxenSystem
{
	public function new(f:Flaxen)
	{ 
		super(f);
	}

	override public function update(time:Float)
	{
		var monsterEnt:Entity = f.getEntity("monster");
		spawnPeasants(f.getComponent(monsterEnt, Monster), time);
		cullPeasants(f.getComponent(monsterEnt, Position));
	}

	private function spawnPeasants(monster:Monster, time:Float)
	{
		var spawnLevel:Int = 0;
		var monsterSpeed:Float = 0;

		switch(monster.state)
		{
			// If monster idle, only spawn peasants from level 0 buildings
			case Idle:
			spawnLevel = 0; 

			// If monster piked or knocked back, spawn no new peasants
			case Piked:		return;
			case Knockback:	return;

			// If running, spawn peasants from any building where monster speed > minBuildingSpeed
			case Running(speed):
			for(lev in 0...6)
			{
				if(Config.minBuildingDemoSpeed[lev] <= speed)
					spawnLevel = lev;
			}
			monsterSpeed = speed;
		}

	 	for(node in ash.getNodeList(FeatureNode))
	 	{
	 		var panicking = node.feature.size <= spawnLevel;
	 		if(node.feature.type == Building)
	 			checkBuildingPanic(node.feature, node.position, node.entity, time, spawnLevel);
	 		else if (node.feature.type == Pikes)
				checkPikesPanic(node.feature, monsterSpeed, node.entity);
		}

	}

	private function checkPikesPanic(feature:Feature, speed:Float, entity:Entity)
	{
 		// "Panic" in this case means the monster should panic!
 		var panicking:Bool = speed >= Config.maxPikeSpeed;

 		// The pikes should scintillate if you're going too fast and they're deadly
 		if(feature.panicking != panicking)
 		{
 			feature.panicking = panicking;
	 		var anim = f.getComponent(entity, Animation);
 			anim.random = !panicking;
 			anim.setFrames(panicking ? "3,3-5,4" : "0-2");
 		}
	}

	private function checkBuildingPanic(feature:Feature, position:Position, entity:Entity, time:Float, spawnLevel:Int)
	{
 		// Register rising level of panic	 	
 		feature.peasantPanic += time;

 		// However only peasants in building with impending demo flee the building
 		var panicking = feature.size <= spawnLevel;
 		if(panicking)
 		{
 			// Ignore offscreen features
 			if(position.x > (CameraService.getX() + 850))
 				return;

	 		if(feature.peasantPanic >= Config.peasantPanicRate)
	 		{
	 			// Restart timer for next flee
	 			feature.peasantPanic = 0;

	 			// Spawn a peasant at this feature
	 			spawnPeasant(feature, position);
	 		}
 		}

 		// A peasant-spawning building puts its lights on so you can tell you're going fast enough
 		if(feature.panicking != panicking)
 		{
 			feature.panicking = panicking;
	 		var tile = f.getComponent(entity, Tile);
 			tile.value = (panicking ? 1 : 0);	 			
 		}
	 }

	private function spawnPeasant(feature:Feature, position:Position)
	{
		var x:Float = MathUtil.rndInt(10, Config.buildingSizeToArea[feature.size].x - 10);
		var e = f.newChildEntity("levelData", "peasant#");
		f.addSet(e, "peasant")
			.add(position.clone().add(x, 0))
			.add(new Velocity(MathUtil.rnd(15, 30), 0));
		e.get(Animation).random = true;
	}

	private function cullPeasants(monsterPos:Position)
	{
		for(node in ash.getNodeList(PeasantNode))
		{
			if(node.position.x < CameraService.getX() + monsterPos.x + 12)
			{
				f.getComponent(node.entity, Animation).setFrames("2");
				node.entity.remove(Peasant);
				var alpha = new Alpha(1);
				node.entity.add(alpha);
				var tween = new Tween(4).to(alpha, "value", 0);
				node.entity.add(tween);
				f.newActionQueue(true, "bloodFade#")
					.waitForComplete(tween)
					.removeEntity(node.entity);
			}
		}
	}
}

private class PeasantNode extends Node<PeasantNode>
{
	public var peasant:Peasant;
	public var position:Position;
}