package game.handler; 

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

class PlayHandler extends FlaxenHandler
{
	override public function start()
	{
		var e = f.newEntity("sky")
			.add(new Image("art/sky.png"))
			.add(Size.screen())
			.add(new Layer(100))
			.add(Position.zero());

		var e = f.newEntity("sun")
			.add(new Image("art/sun.png"))
			.add(new Layer(90))
			.add(new Position(15, 15));

		var e = f.newEntity("clouds")
			.add(new Image("art/clouds.png"))
			.add(Repeating.instance)
			.add(new Layer(80))
			.add(Position.zero());

		var e = f.newEntity("mountains")
			.add(new Image("art/mountains.png"))
			.add(Repeating.instance)
			.add(new Layer(70))
			.add(Position.zero());


		updateVelocity(5);
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

		if(key == Key.DIGIT_0) updateVelocity(0);
		if(key == Key.DIGIT_1) updateVelocity(1);
		if(key == Key.DIGIT_2) updateVelocity(2);
		if(key == Key.DIGIT_3) updateVelocity(3);
		if(key == Key.DIGIT_4) updateVelocity(4);
		if(key == Key.DIGIT_5) updateVelocity(5);
		#end

		InputService.clearLastKey();
	}

	private function updateVelocity(speed:Int)
	{
		for(o in [{name:"clouds", vel:5}, {name:"mountains", vel:20}])//, ["items", -50]])
		{
			var vel:Float = o.vel + o.vel * speed * 0.5;
			f.resolveEntity(o.name).add(new Velocity(-vel, 0));
		}
	}
}
