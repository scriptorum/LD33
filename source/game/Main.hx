package game; 

import flaxen.Flaxen;
import flaxen.FlaxenOptions;
import game.handler.PlayHandler;
import flaxen.system.MovementSystem;

class Main extends Flaxen
{
	public static function main()
	{
		new Main(800, 250, 60, true);
	}

	override public function ready()
	{
		setHandler(new PlayHandler(this));
		addSystem(new MovementSystem(this));
	}
}
