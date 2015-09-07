package game.component;

import game.common.FeatureType;
import ash.core.Entity;

class Monster
{
	public var nextFeatureId:String = null;
	public var state:MonsterState;
	public var nextState:Null<MonsterState> = Idle;
	public var set:String;
	public var level:Int = 0;
	public var deceleration:Float = 0;

	public function new()
	{
	}
}

enum MonsterState 
{
	Idle;
	Knockback;
	Piked;
	Running(speed:Float);
}