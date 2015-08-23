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
import game.system.CollisionSystem;
import game.component.Monster;
import game.system.CitySystem;

class PlayHandler extends FlaxenHandler
{
	public static var MAX_SPEED:Int = 20;
	public var monster:Monster = new Monster();

	override public function start()
	{
		addEntities();	
		addSystems();
		updateSpeed(0);
	}

	public function addSystems()
	{
		f.addSystem(new MovementSystem(f));
		f.addSystem(new CollisionSystem(f));
		f.addSystem(new CitySystem(f));
	}

	public function addEntities()
	{
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
			.add(monster)
			.add(new Layer(20));
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

		if(monster.speedChanged)
		{
			monster.speedChanged = false;
			updateSpeed(monster.speed);
		}

		if(key == Key.SPACE && monster.speed < MAX_SPEED && monster.speed >= 0) 
			updateSpeed(monster.speed + 1);

		InputService.clearLastKey();
	}

	private function setVelocity(name:String, featureSpeed:Int, monsterSpeed:Int)
	{
		var e = f.getEntity(name);
		var vel:Float = monsterSpeed < 0 ? 0 :
			featureSpeed + featureSpeed * monsterSpeed * 0.5;
		f.resolveComponent(e, Velocity, [-vel, 0]).set(-vel, 0);
	}

	private function updateSpeed(speed:Int)
	{
		setVelocity("clouds", 5, speed);
		setVelocity("mountains", 20, speed);
		setVelocity("featureProxy", 50, speed);

		if(speed >= 0)
		{
			var pos = f.getComponent("monster", Position);
			pos.x = 5 + 6 * speed;
		}

		monster.speed = speed;
	}

	override public function stop()
	{
		f.removeSystemByClass(MovementSystem);
		f.removeSystemByClass(CollisionSystem);
		f.removeSystemByClass(CitySystem);
	}
}
