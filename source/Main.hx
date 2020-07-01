package;

import states.MenuState;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite {
	public function new() {
		super();
		addChild(new FlxGame(320, 180, MenuState, 1, 60, 60, true));
	}
}
