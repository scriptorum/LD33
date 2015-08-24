package game.handler; 

import ash.core.Entity;
import com.haxepunk.utils.Key;
import flaxen.common.LoopType;
import flaxen.common.OnCompleteAnimation;
import flaxen.component.Animation;
import flaxen.component.Image;
import flaxen.component.ImageGrid;
import flaxen.component.Layer;
import flaxen.component.Offset;
import flaxen.component.Position;
import flaxen.component.Repeating;
import flaxen.component.Size;
import flaxen.component.Velocity;
import flaxen.Flaxen;
import flaxen.FlaxenHandler;
import flaxen.Log;
import flaxen.service.InputService;
import flaxen.system.MovementSystem;
import flaxen.util.LogUtil;
import game.component.Monster;
import game.system.CitySystem;
import game.system.CollisionSystem;
import flaxen.component.Text;

class PlayHandler extends FlaxenHandler
{
	public static var MAX_SPEED:Int = 20;
	public var monster:Monster = new Monster();
	public var state:Int = 1; // intro / play / end
	public var score:Float = 0;

	override public function start()
	{
		addEntities();	
		updateSpeed(-1);
		f.addSystem(new MovementSystem(f));
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

		f.newComponentSet("monsterIdleSet").addClass(Animation, ["63-80", 30, Forward]);
		f.newComponentSet("monsterSpeed0Set").addClass(Animation, ["0,23-33", 30, Forward]);
		f.newComponentSet("monsterSpeed1Set").addClass(Animation, ["0,23-33", 45, Forward]);
		f.newComponentSet("monsterSpeed2Set").addClass(Animation, ["12,34-45", 30, Forward]);
		f.newComponentSet("monsterSpeed3Set").addClass(Animation, ["12,34-45", 45, Forward]);
		f.newComponentSet("monsterSpeed4Set").addClass(Animation, ["45-56", 30, Forward]);
		f.newComponentSet("monsterSpeed5Set").addClass(Animation, ["45-56", 45, Forward]);
		f.newComponentSet("monsterSpeed6Set").addClass(Animation, ["57-62", 30, Forward]);
		f.newComponentSet("monsterSpeed7Set").addClass(Animation, ["57-62", 45, Forward]);
		f.newComponentSet("monsterPikedSet").addClass(Animation, ["12-22", 30, None, Last]);
		f.newComponentSet("monsterKnockbackSet").addClass(Animation, ["0-11", 30, None, Last]);

		f.newSetEntity("monsterIdleSet", "monster")
			.add(new Image("art/monster.png"))
			.add(new ImageGrid(141, 101))
			.add(new Offset(-80,-71))
			.add(new Position(80, 250-2))
			.add(monster)
			.add(new Layer(10));

		var style = TextStyle.createTTF();
		style.halign = Left;
		f.resolveEntity("score")
			.add(new Text("0"))
			.add(style)
			.add(new Size(50, 50))		
			.add(Position.topRight().add(-50, 10));
		score = 0;
		updateScore();

		addTitling();
	}

	public function addTitling()
	{
		f.newEntity("title")
			.add(new Image("art/title.png"))
			.add(Offset.center())
			.add(Position.center().subtract(0,30))
			.add(new Layer(0));

		f.newEntity("startButton")
			.add(new Image("art/startButton.png"))
			.add(Offset.center())
			.add(Position.center().add(0,45))
			.add(new Layer(0));
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
			for(
				setName in f.getComponentSetKeys())
				trace(setName + ":{" + f.getComponentSet(setName) + "}");
		}

		if(key == Key.DIGIT_0) updateSpeed(0);
		if(key == Key.DIGIT_1) updateSpeed(1);
		if(key == Key.DIGIT_2) updateSpeed(2);
		if(key == Key.DIGIT_3) updateSpeed(3);
		if(key == Key.DIGIT_4) updateSpeed(4);
		if(key == Key.DIGIT_5) updateSpeed(5);
		#end

		switch(state)
		{
			case 1:
			if(f.isPressed("startButton"))
			{
				f.removeEntity("startButton");
				f.removeEntity("title");
				f.addSystem(new CollisionSystem(f));
				f.addSystem(new CitySystem(f));
				score = 0;
				updateScore();
				updateSpeed(0);
				state = 2;
				f.newSound("sound/twinkle.wav");
			}

			case 2:
			if(monster.nextSpeed != null)
			{
				updateSpeed(monster.nextSpeed);
				monster.nextSpeed = null;
			}

			if(key == Key.SPACE && monster.speed >= 0 && monster.speed < MAX_SPEED) 
			{
				updateSpeed(monster.speed + 2.5);
			}

			score += (monster.speed >=0  ? com.haxepunk.HXP.elapsed  * (monster.speed + 1) : 0);
			updateScore();

			if(monster.speed >= 0)
				updateSpeed(Math.max(0, monster.speed - com.haxepunk.HXP.elapsed * 4));
		}

		InputService.clearLastKey();
	}

	private function updateScore()
	{
		var text = f.getComponent("score", Text);
		var str:String = cast Math.floor(score * 100);
		if(str.length == 2)
			str = "0" + str;
		else if (str.length == 1)
			str = "00" + str;
		text.message = str.substr(0, str.length - 2) + "." + str.substr(-2, 2);
	}

	private function setVelocity(name:String, featureSpeed:Int, monsterSpeed:Float)
	{
		var e = f.getEntity(name, false);
		if(e == null)
			return;

		var vel:Float = monsterSpeed < 0 ? 0 :
			featureSpeed + (featureSpeed * (monsterSpeed / 5)) * 2.0;
		f.resolveComponent(e, Velocity, [-vel, 0]).set(-vel, 0);
	}

	private function updateSpeed(newSpeed:Float)
	{
		setVelocity("clouds", 5, newSpeed);
		setVelocity("mountains", 20, newSpeed);
		setVelocity("featureProxy", 50, newSpeed);

		// Change monster anim
		var monsterEnt = f.getEntity("monster");
		if(newSpeed >= 0)
		{
			var pos = f.getComponent(monsterEnt, Position);
			pos.x = 80 + 6 * newSpeed;
		}

		var setName = "Speed0";
		if (newSpeed == -1) setName = "Idle";
		else if (newSpeed == -2) setName = "Knockback";
		else if (newSpeed == -3) setName = "Piked";
		else
		{
			var index = Math.floor(newSpeed);
			if(index > 6)
			{
				if(index > 10) 
					index = 7;
				else index = 6;
			}
			setName = "Speed" + index;
		}

		if(monster.set != setName)
		{
			f.addSet(monsterEnt, 'monster${setName}Set');
			monster.set = setName;
		}

		monster.speed = newSpeed;

		if(newSpeed == -2 || newSpeed == -3)
		{
			state = 1;
			f.removeSystemByClass(CollisionSystem);
			f.removeSystemByClass(CitySystem);
			addTitling();
		 	for(node in f.ash.getNodeList(game.node.FeatureNode))
		 		f.removeEntity(node.entity);
		 	f.removeEntity("featureProxy");
		 }
	}

	override public function stop()
	{
		f.removeSystemByClass(MovementSystem);
		f.removeSystemByClass(CollisionSystem);
		f.removeSystemByClass(CitySystem);
	}
}
