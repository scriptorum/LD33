package game.system;

import ash.core.Node;
import ash.core.Entity;
import flaxen.component.Display;
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
		}

	 	for(node in ash.getNodeList(FeatureNode))
	 	{
	 		if(node.feature.type != Building)
	 			continue;

	 		// Register rising level of panic	 	
	 		node.feature.peasantPanic += time;

	 		// However only peasants in building with impending demo flee the building
	 		if(node.feature.size <= spawnLevel)
	 		{
	 			// Ignore offscreen features
	 			if(node.position.x > (CameraService.getX() + 850))
	 				continue;

		 		if(node.feature.peasantPanic >= Config.peasantPanicRate)
		 		{
		 			// Restart timer for next flee
		 			node.feature.peasantPanic = 0;

		 			// Spawn a peasant at this feature
		 			spawnPeasant(node.feature, node.position);
		 		}
	 		}
	 	}
	}

	private function spawnPeasant(feature:Feature, position:Position)
	{
		var x:Float = Config.buildingSizeToArea[feature.size].x / 2;
		var e = f.newChildEntity("levelData", "peasant#");
		f.addSet(e, "peasant")
			.add(position.clone().add(x, 0))
			.add(new Velocity(MathUtil.rnd(15, 30), 0));
	}

	private function cullPeasants(monsterPos:Position)
	{
		for(node in ash.getNodeList(PeasantNode))
		{
			if(node.position.x < CameraService.getX() + monsterPos.x + 12)
				node.display.destroyEntity = true;
		}
	}
}

private class PeasantNode extends Node<PeasantNode>
{
	public var peasant:Peasant;
	public var position:Position;
	public var display:Display;
}