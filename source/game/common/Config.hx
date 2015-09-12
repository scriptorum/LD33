package game.common;

class Config
{
	public static var maxPikeSpeed:Float = 4.0;
	public static var minBuildingDemoSpeed:Array<Float> = [0.0, 2.0, 4.0, 6.5, 9.0, 11.0];
	public static var buildingSizeToArea:Array<{x:Float, y:Float}> = 
		[{ x: 20,  y:31 }, { x: 32,  y:61 }, { x: 64,  y:95 }, { x: 96, y:122 }, { x:128, y:154 }, { x:160, y:186 }];
	public static var peasantPanicRate:Float = 0.45; // sec

	private function new() {}
}
