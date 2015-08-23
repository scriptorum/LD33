package game.system;

import ash.core.Engine;
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
	public var featureLayer:Layer = new Layer(30);
	public var featureVelocity:Velocity = new Velocity(0,0);

	public function new(f:Flaxen)
	{ 
		super(f);

		f.newEntity("featureProxy")
			.add(featureVelocity);

		spawnFeature(Empty, 3);

		spawnFeature(Building, 0);
		spawnFeature(Empty);
		spawnFeature(Building, 1);
		spawnFeature(Pikes);
		spawnFeature(Building, 2);
		spawnFeature(Empty);
		spawnFeature(Building, 3);
		spawnFeature(Empty);
		spawnFeature(Building, 4);
		spawnFeature(Empty);
		spawnFeature(Building, 5);
		spawnFeature(Empty);

		spawnFeatures();

		// com.haxepunk.HXP.camera.x = -160;
	}

	override public function update(time:Float)
	{
	 	for(node in ash.getNodeList(FeatureNode))
	 	{
	 		// Check for feature has fallen off map
	 		if(node.position.x < -32 * 5)
	 		{
	 			// Remove feature
	 			f.removeEntity(node.entity);

	 			// Queue up new features
	 			spawnFeatures();
	 		}
	 	}
	}

	public function spawnFeatures()
	{
		while(lastFeaturePos.x <= 29 * 32)
		{
			var difficulty = Math.min(0, 100 - spawnCount / 8) / 100; // 0.0 = easy, 1.0 = hard/max

			// Spawn empty right after pikes or building?
			if(lastFeature.type != Empty && Math.random() < (1 - difficulty) * 0.50 + 0.50) // 50-100%
			{
				var numToSpawn:Int = Math.floor(1 + Math.random() * 15 * (1 - difficulty));
				spawnFeature(Empty, numToSpawn);
			}

			// Spawn building?
			else if(Math.random() < 0.25 + difficulty * 0.50)
			{
				var raw:Float = difficulty * 4;
				var lower:Int = Math.floor(raw); //0-4
				var higher:Int = lower + 1; // 1-5
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

			// Spawn pikes if we didn't spawn empty?
			else if(Math.random() < 0.10 + (.25 * difficulty)) // 10-30%
				spawnFeature(Pikes);
		}
	}

	public function spawnFeature(type:FeatureType, size:Int = 1)
	{		
		var spawnX:Float = 0;
		if(lastFeaturePos != null)
			spawnX = lastFeaturePos.x + lastFeature.size * 32;

		lastFeature = new Feature(type, size);
		lastFeaturePos = new Position(spawnX, 250);
		var e = f.newEntity()
			.add(new Offset(0, -1, true))
			.add(featureVelocity)
			.add(lastFeature)
			.add(lastFeaturePos);
		spawnCount++;

		switch(type)
		{
			case Pikes:
			e.add(new Image("art/pikes.png")).add(featureLayer);

			case Building:
			e.add(new Image('art/building$size.png')).add(featureLayer);

			case Empty:
		}
	}
}

private class FeatureNode extends Node<FeatureNode>
{
	public var feature:Feature;
	public var position:Position;
}

