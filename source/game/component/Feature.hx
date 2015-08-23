package game.component;

import game.common.FeatureType;

class Feature
{
	public var type:FeatureType;
	public var size:Int = 1;

	public function new(type:FeatureType, size:Int = 1)
	{
		this.type = type;
		this.size = size;
	}
}