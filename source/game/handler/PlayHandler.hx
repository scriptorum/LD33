package game.handler; 

import ash.core.Entity;
import com.haxepunk.utils.Key;
import flaxen.component.Image;
import flaxen.component.Offset;
import flaxen.component.Size;
import flaxen.component.Position;
import flaxen.component.Layer;
import flaxen.component.Velocity;
import flaxen.component.Repeating;
import flaxen.Flaxen;
import flaxen.FlaxenHandler;
import flaxen.Log;
import flaxen.util.LogUtil;
import flaxen.service.InputService;
import flaxen.system.MovementSystem;
import game.system.CitySystem;

class PlayHandler extends FlaxenHandler
{
	public static var MAX_SPEED:Int = 10;
	public var monsterSpeed:Int = 0;

	override public function start()
	{
		f.addSystem(new MovementSystem(f));
		f.addSystem(new CitySystem(f));

		f.newEntity("sky")
			.add(new Image("art/sky.png"))
			.add(Size.screen())
			.add(new Layer(100))
			.add(Position.zero());

		f.newEntity("sun")
			.add(new Image("art/sun.png"))
			.add(new Layer(90))
			.add(new Position(15, 15));

		f.newEntity("clouds")
			.add(new Image("art/clouds.png"))
			.add(Repeating.instance)
			.add(new Layer(80))
			.add(Position.zero());

		f.newEntity("mountains")
			.add(new Image("art/mountains.png"))
			.add(Repeating.instance)
			.add(new Layer(70))
			.add(Position.zero());

		f.newEntity("monster")
			.add(new Image("art/monster.png"))
			.add(new Position(10, 193))
			.add(new Layer(30));

		updateSpeed(0);
	}

	override public function update()
	{
		var key = InputService.lastKey();

		#if debug
		if(key == Key.D)
		{
			trace("Entities:");
			trace(LogUtil.dumpEntities(f));
			
			trace("Component Sets:");
			for(setName in f.getComponentSetKeys())
				trace(setName + ":{" + f.getComponentSet(setName) + "}");
		}

		if(key == Key.DIGIT_0) updateSpeed(0);
		if(key == Key.DIGIT_1) updateSpeed(1);
		if(key == Key.DIGIT_2) updateSpeed(2);
		if(key == Key.DIGIT_3) updateSpeed(3);
		if(key == Key.DIGIT_4) updateSpeed(4);
		if(key == Key.DIGIT_5) updateSpeed(5);
		#end

		if(key == Key.SPACE && monsterSpeed < MAX_SPEED) 
			updateSpeed(monsterSpeed + 1);

		InputService.clearLastKey();
	}

	private function setVelocity(e:Entity, featureSpeed:Int, monsterSpeed:Int)
	{
		var vel:Float = featureSpeed + featureSpeed * monsterSpeed * 0.5;
		f.resolveComponent(e, Velocity).set(-vel, 0);
	}

	private function updateSpeed(speed:Int)
	{
		setVelocity(f.resolveEntity("clouds"), 5, speed);
		setVelocity(f.resolveEntity("mountains"), 20, speed);
		setVelocity(f.resolveEntity("featureProxy"), 50, speed);

		var pos = f.resolveComponent("monster", Position);
		pos.x = 5 + 6 * speed;

		monsterSpeed = speed;
	}

	override public function stop()
	{
		f.removeSystemByClass(MovementSystem);
		f.removeSystemByClass(CitySystem);
	}
}
