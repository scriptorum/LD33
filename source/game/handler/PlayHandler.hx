package game.handler;

import com.haxepunk.utils.Key;
import flaxen.common.Completable;
import flaxen.component.ScrollFactor;
import flaxen.FlaxenHandler;
import flaxen.common.Easing;
import flaxen.common.Completable;
import flaxen.common.OnCompleteAnimation;
import flaxen.common.LoopType;
import flaxen.common.Completable;
import flaxen.common.OnCompleteAnimation;
import flaxen.component.Animation;
import flaxen.component.Image;
import flaxen.component.ImageGrid;
import flaxen.component.Layer;
import flaxen.component.Offset;
import flaxen.component.Position;
import flaxen.component.Repeating;
import flaxen.component.Size;
import flaxen.component.Text;
import flaxen.component.Tween;
import flaxen.service.CameraService;
import flaxen.service.InputService;
import flaxen.system.GravitySystem;
import flaxen.system.MovementSystem;
import flaxen.util.LogUtil;
import flaxen.util.MathUtil;
import game.component.Monster;
import game.node.FeatureNode;
import game.system.CitySystem;
import game.system.CollisionSystem;
 
class PlayHandler extends FlaxenHandler
{
	public static var MAX_SPEED:Int = 20;
	public var monster:Monster = new Monster();
	public var gameState:GameState = Ready;
	public var score:Float = 0;

	override public function start()
	{
		CameraService.init(f);
		addEntities();	
		updateMonsterState(Idle);
		f.addSystem(new MovementSystem(f));
		f.addSystem(new GravitySystem(f));
	}

	public function addEntities()
	{
		f.newEntity("sky")
			.add(new Image("art/sky.png"))
			.add(Size.screen())
			.add(new Layer(100))
			.add(ScrollFactor.lock)
			.add(Position.zero());

		f.newEntity("sun")
			.add(new Image("art/sun.png"))
			.add(new Layer(90))
			.add(ScrollFactor.lock)
			.add(new Position(15, 15));

		f.newEntity("clouds")
			.add(new Image("art/clouds.png"))
			.add(Repeating.instance)
			.add(new Layer(80))
			.add(new ScrollFactor(0.06666))
			.add(Position.zero());

		f.newEntity("mountains")
			.add(new Image("art/mountains.png"))
			.add(Repeating.instance)
			.add(new Layer(70))
			.add(new ScrollFactor(0.26666))
			.add(Position.zero());

		f.newEntity("grass")
			.add(new Image("art/grass.png"))
			.add(new Repeating(true, false))
			.add(new Layer(0))
			.add(Position.bottomLeft().subtract(0, 10));

		f.newComponentSet("monsterIdleSet").addClass(Animation, ["63-80", 30, LoopType.Forward]);
		f.newComponentSet("monsterSpeed0Set").addClass(Animation, ["0,23-33", 30, LoopType.Forward]);
		f.newComponentSet("monsterSpeed1Set").addClass(Animation, ["0,23-33", 45, LoopType.Forward]);
		f.newComponentSet("monsterSpeed2Set").addClass(Animation, ["12,34-45", 30, LoopType.Forward]);
		f.newComponentSet("monsterSpeed3Set").addClass(Animation, ["12,34-45", 45, LoopType.Forward]);
		f.newComponentSet("monsterSpeed4Set").addClass(Animation, ["45-56", 30, LoopType.Forward]);
		f.newComponentSet("monsterSpeed5Set").addClass(Animation, ["45-56", 45, LoopType.Forward]);
		f.newComponentSet("monsterSpeed6Set").addClass(Animation, ["57-62", 30, LoopType.Forward]);
		f.newComponentSet("monsterSpeed7Set").addClass(Animation, ["57-62", 45, LoopType.Forward]);
		f.newComponentSet("monsterPikedSet").addClass(Animation, ["12-22", 30, LoopType.None, OnCompleteAnimation.Last]);
		f.newComponentSet("monsterKnockbackSet").addClass(Animation, ["0-11", 30, LoopType.None, OnCompleteAnimation.Last]);

		f.newEntity("levelData"); // Parent entity to group all feature items

		f.newSetEntity("monsterIdleSet", "monster")
			.add(new Image("art/monster.png"))
			.add(new ImageGrid(141, 101))
			.add(new Offset(-80,-71))
			.add(new Position(80, 250-2))
			.add(ScrollFactor.lock)
			.add(monster)
			.add(new Layer(10));

		var style = TextStyle.createTTF();
		style.halign = Left;
		f.resolveEntity("score")
			.add(new Text("0"))
			.add(style)
			.add(new Size(50, 50))		
			.add(ScrollFactor.lock)
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
			.add(ScrollFactor.lock)
			.add(new Layer(1));

		f.newEntity("startButton")
			.add(new Image("art/startButton.png"))
			.add(Offset.center())
			.add(Position.center().add(0,45))
			.add(ScrollFactor.lock)
			.add(new Layer(1));
	}

	override public function update()
	{
		var key = InputService.lastKey();

		#if debug
		if(key == Key.D)
		{

			trace("Entities:");
			trace(LogUtil.dumpEntities(f, 2));
			trace("CameraX:" + CameraService.getX());
			
			// trace("Component Sets:");
			// for(setName in f.getComponentSetKeys())
			// 	trace(setName + ":{" + f.getComponentSet(setName) + "}");
		}

		if(key == Key.DIGIT_0) updateMonsterState(Running(0.0));
		if(key == Key.DIGIT_1) updateMonsterState(Running(1.0));
		if(key == Key.DIGIT_2) updateMonsterState(Running(2.0));
		if(key == Key.DIGIT_3) updateMonsterState(Running(3.0));
		if(key == Key.DIGIT_4) updateMonsterState(Running(4.0));
		if(key == Key.DIGIT_5) updateMonsterState(Running(5.0));
		if(key == Key.G) trace("God Mode:" + f.toggleMarker("godMode"));
		if(key == 187) { monster.level += 10; trace("Cheat! Level now:" + monster.level); }
		if(key == 188) { monster.level -= 10; trace("Cheat! Level now:" + monster.level); }
		#end

		switch(gameState)
		{
			// Main menu
			case Ready:
			if(f.isPressed("startButton") || key == Key.SPACE)
			{
				// Remove features from previous gameplay
			 	f.removeDependents("levelData");

			 	// Remove titling
				f.removeEntity("startButton");
				f.removeEntity("title");

				// Reset monster
				monster.nextFeatureId = null;
				monster.level = 0;
				monster.nextState = null;
				monster.set = "Idle";
				monster.deceleration = 0;

				// Reset score, speed, and state
				score = 0;
				updateScore();
				updateMonsterState(Running(0.0));
				changeState(Play);

				// Reset camera
				moveCamera(0, false);

				// Add gameplay systems
				f.addSystem(new CollisionSystem(f));
				f.addSystem(new CitySystem(f));

				// Lousy sfx
				f.newSound("sound/twinkle.wav");
			}

			// Game play
			case Play:
			if(monster.nextState != null)
			{
				updateMonsterState(monster.nextState);
				monster.nextState = null;
			}

			switch(monster.state)
			{
				case Running(speed):
				if((InputService.clicked || key == Key.SPACE) && speed >= 0 && speed < MAX_SPEED) 
				{
					var newSpeed = speed + 2.5;
					var vol = 0.25 + newSpeed / MAX_SPEED * 0.75;
					f.newSound('sound/squish${MathUtil.rndInt(1,8)}.wav', false, vol);
					monster.deceleration = 0;
					updateMonsterState(Running(newSpeed));
				}

				slowMonster();
				moveCamera((75 + (75 * ((speed + 3) / 5)) * 2.0) * com.haxepunk.HXP.elapsed);

				score += (speed >=0  ? com.haxepunk.HXP.elapsed  * (speed + 1) : 0);
				updateScore();

				default:
				// Nada
			}

			// Death throes complete
			case Dead:
			if(f.hasMarker("deathSoundComplete"))
			{
				f.removeMarker("deathSoundComplete");
				addTitling();
			 	changeState(Ready);
			 }
		}

		InputService.clearLastKey();
	}

	private function moveCamera(amount:Float, relative:Bool = true)
	{
		if(relative)
			 CameraService.moveRel(amount, 0);
		else CameraService.move(amount, 0);
	}

	private function slowMonster()
	{
		switch(monster.state)
		{
			case Running(speed):
			if(speed <= 0)
				return;

			monster.deceleration += 0.5 * com.haxepunk.HXP.elapsed;
			var newSpeed = Math.max(0, speed - monster.deceleration);
			if(newSpeed == 0)
				monster.deceleration = 0;
			updateMonsterState(Running(newSpeed));

			default:
			// Do not slow monster in non-running states
		}
	}

	private function updateScore()
	{
		var text = f.getComponent("score", Text);
		var str:String = "" + cast Math.floor(score * 100);
		if(str.length == 2)
			str = "0" + str;
		else if (str.length == 1)
			str = "00" + str;
		text.message = str.substr(0, str.length - 2) + "." + str.substr(-2, 2);
	}

	private function updateMonsterState(newState:MonsterState)
	{
		var monsterEnt = f.getEntity("monster");
		var setName = "Speed0";
		var gameOver:Bool = false;

		switch(newState)
		{
			case Idle:
			setName = "Idle";

			case Knockback:
			setName = "Knockback";
			gameOver = true;

			case Piked:
			setName = "Piked";
			gameOver = true;

			case Running(speed):
			if(speed >= 0)
			{
				// Animate to new speed
				var pos:Position = f.getComponent(monsterEnt, Position);
				var target:Float = 80 + 6 * speed;
				var diff:Float = MathUtil.diff(target, pos.x);
				if(diff <= 2.0)
					pos.x = target;
				else
					monsterEnt.add(new Tween(0.25, Easing.quadOut, null, OnComplete.DestroyComponent).to(pos, "x", target));
			}

			var index = Math.max(0, Math.floor(speed));
			if(index > 6)
			{
				if(index > 10) 
					index = 7;
				else index = 6;
			}
			setName = "Speed" + index;
		}

		monster.state = newState;

		if(monster.set != setName)
		{
			f.addSet(monsterEnt, 'monster${setName}Set');
			monster.set = setName;
		}

		// End game .. death!
		if(gameOver)
		{
			changeState(Dead);
			f.removeSystemByClass(CollisionSystem);
			f.removeSystemByClass(CitySystem);
		 }
	}

	public function changeState(state:GameState)
	{
		gameState = state;
	}

	override public function stop()
	{
		f.removeSystemByClass(MovementSystem);
		f.removeSystemByClass(GravitySystem);
		f.removeSystemByClass(CollisionSystem);
		f.removeSystemByClass(CitySystem);
	}
}

enum GameState { Ready; Play; Dead; }