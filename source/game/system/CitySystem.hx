package game.system;

import ash.core.Entity;
import flaxen.component.Tile;
import flaxen.Flaxen;
import flaxen.FlaxenSystem;
import flaxen.component.Animation;
import flaxen.component.Image;
import flaxen.component.ImageGrid;
import flaxen.component.Layer;
import flaxen.component.Offset;
import flaxen.component.Position;
import flaxen.service.CameraService;
import flaxen.util.MathUtil;
import game.common.Config;
import game.common.FeatureType;
import game.component.Feature;
import game.component.Monster;
import game.node.FeatureNode;

class CitySystem extends FlaxenSystem
{
	private static var chart = [ // chances to spawn different building sizes at varying difficulties
		[ .15, .40, .20, .15, .10, .00],  // 0% diff
		[ .10, .20, .30, .20, .15, .05],  // 25%
		[ .05, .10, .20, .30, .25, .10],  // 50%
		[ .02, .06, .12, .20, .30, .30],  // 75%
		[ .01, .03, .06, .10, .20, .60]]; // 100%

	public var spawnCount:Int = 0;
	public var lastFeaturePos:Position;
	public var lastFeature:Feature = null;
	public var buildingLayer:Layer = new Layer(20);
	public var pikesLayer:Layer = new Layer(14);
	public var monster:Monster;

	public function new(f:Flaxen)
	{ 
		super(f);

		// Point monster toward some future feature to begin the collision-check-chain
		var first = spawnFeature(Empty);
		monster = f.getComponent("monster", Monster);
		monster.nextFeatureId = first.name;
		spawnFeatures();
	}

	override public function update(time:Float)
	{
		// Remove past features
	 	for(node in ash.getNodeList(FeatureNode))
	 	{
	 		// Check for feature has fallen off map
	 		if(CameraService.getX() > (node.position.x + 32 * node.feature.size))
	 		{
	 			// Point to next feature id if this is the monster's next feature
	 			if(monster.nextFeatureId == node.entity.name)
	 			{
	 				#if debug
		 			if(node.feature.nextId == null)
		 			{
			 			trace("Feature " + monster.nextFeatureId + " removed but next feature is null");
						trace(flaxen.util.LogUtil.dumpEntities(f, 2));
						trace("Camera:" + CameraService.getX());
					}
					#end
		 			monster.nextFeatureId = node.feature.nextId;
	 			}
	 			f.removeEntity(node.entity); // Remove feature
	 		}
	 	}

	 	// Spawn new features
	 	spawnFeatures();
	}

	public function spawnFeatures()
	{
		while(lastFeaturePos == null || lastFeaturePos.x <= (30 + 15) * 32 + CameraService.getX())
		{
			if(spawnCount >= 8)
			{
				monster.level += 1;
				spawnCount -= 8;
			}

			var difficulty = Math.min(1, monster.level / 100); // 0.0 = easy, 1.0 = hard/max

			spawnBuilding(difficulty);
			spawnEmpty(difficulty);

			if(Math.random() < 0.4 + (.3 * difficulty))
			{
				spawnFeature(Pikes);
				spawnEmpty(difficulty);
			}
		}
	}

	public function roll(min:Float, max:Float, dice:Int = 1): Float
	{
		var result:Float = 0;
		while(dice-- > 0)
			result += MathUtil.rnd(min, max);
		return result;
	}

	public function spawnEmpty(difficulty:Float)
	{
		var spawnCount = 3 + Math.floor(roll(0, 7 * (1 - difficulty), 2));
		spawnFeature(Empty, spawnCount);
	}

	public function spawnBuilding(difficulty:Float)
	{
		var raw:Float = difficulty * 4;
		var lower:Int = Math.floor(raw); //0-4
		var higher:Int = cast Math.min(4, lower + 1); // 1-4
		var slider:Float = (raw - lower);
		var size:Int = 0;
		var roll:Float = Math.random();

		while(size < 5)
		{
			var chance = (chart[higher][size] - chart[lower][size]) * slider + chart[lower][size];				
			if(roll < chance)
				break;

			size++;
			roll -= chance;
		}
		spawnFeature(Building, size);	
	}

	public function spawnFeature(type:FeatureType, size:Int = 1): Entity
	{		
		var spawnX:Float = CameraService.getX() + 850 - 32;
		if(lastFeaturePos != null)
			spawnX = lastFeaturePos.x + lastFeature.size * 32;

		var feature = new Feature(type, size);
		feature.peasantPanic = Config.peasantPanicRate;
		var pos = new Position(spawnX, 250);
		var e = f.newChildEntity("levelData", 'feature$type#')
			.add(feature)
			.add(new Offset(0, -1, true))
			.add(pos);
		feature.id = e.name;
		if(lastFeature != null)
			lastFeature.nextId = feature.id;

		spawnCount++;
		lastFeature = feature;
		lastFeaturePos = pos;

		switch(type)
		{
			case Pikes:
			var anim:Animation;
			e.add(new Image("art/pikes.png"))
				.add(pikesLayer)
				.add(new ImageGrid(52, 26))
				.add(anim = new Animation("0-2", 10));
			anim.random = true;

			case Building:
			var data = Config.buildingSizeToArea[size];
			e.add(new Image('art/building$size.png')).add(buildingLayer)
				.add(new ImageGrid(data.x, data.y))
				.add(new Tile(0));	

			case Empty:
			case Rubble:
		}

		// trace("Spawning feature name:" + feature.id + " type:" + feature.type + " size:" + feature.size + " offset:" + 
		// 	(spawnX - CameraService.getX()) + " spawnX:" + spawnX + " cameraX:" + CameraService.getX());

		// BUG FIX Two users reported going into a state after button mashing where they stopped colliding.
		if(monster != null && monster.nextFeatureId == null)
			monster.nextFeatureId = e.name;

		return e;
	}
}



