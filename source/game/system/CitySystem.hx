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
	public var lastFeaturePos:Position;
	public var featureLayer:Layer = new Layer(30);
	public var featureVelocity:Velocity = new Velocity(0,0);

	public function new(f:Flaxen)
	{ 
		super(f);

		f.newEntity("featureProxy")
			.add(featureVelocity);

		for(i in 0...3)
			spawnFeature(Empty);

		spawnFeature(Building(0));
		spawnFeature(Empty);
		spawnFeature(Building(1));
		spawnFeature(Pikes);
		spawnFeature(Building(2));
		spawnFeature(Empty);
		spawnFeature(Building(3));
		spawnFeature(Empty);
		spawnFeature(Building(4));
		spawnFeature(Empty);
		spawnFeature(Building(5));
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
		return; // TODO
	}

	public function spawnFeature(type:FeatureType)
	{		
		var spawnX = 0;
		if(lastFeaturePos != null)
		{
			var slot = Math.floor(lastFeaturePos.x / 32) + 1;
			spawnX = 32 * slot;
		}

		var e = f.newEntity()
			.add(new Offset(0, -1, true))
			.add(featureVelocity)
			.add(new Feature(type));
		lastFeaturePos = new Position(spawnX, 250);
		e.add(lastFeaturePos);

		switch(type)
		{
			case Pikes:
			e.add(new Image("art/pikes.png")).add(featureLayer);

			case Building(size):
			e.add(new Image('art/building$size.png')).add(featureLayer);
			while(size-- > 1)
				spawnFeature(Empty); // Add a number of empties so the total number of "features" is constant, even though a Building(5) takes up 5 spaces

			case Empty:
		}
	}
}

private class FeatureNode extends Node<FeatureNode>
{
	public var feature:Feature;
	public var position:Position;
}

