package game.component;

import game.common.Config;
import game.common.FeatureType;
import ash.core.Entity;

class Feature
{
	public var type:FeatureType;
	public var size:Int;
	public var id:String;
	public var nextId:String = null;
	public var peasantPanic:Float = 0;

	public function new(type:FeatureType, size:Int)
	{
		this.type = type;
		this.size = size;
	}

	public function getMinBuildingDemoSpeed(): Float
	{
		return Config.minBuildingDemoSpeed[size];
	}
}