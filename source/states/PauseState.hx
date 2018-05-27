package states;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.FlxG;

class PauseState extends FlxSubState
{
    private var pausedText:FlxText;
    public function new()
    {
        super();
        openCallback = onSwitch;
        closeCallback = onSwitch;
    }

    override public function create():Void
    {
        pausedText = new FlxText(FlxG.width/2, FlxG.height/2, 0, "PAUSED", 9);
        add(pausedText);
        super.create();
    }

    override public function update(elapsed:Float):Void
    {
        if (FlxG.keys.pressed.P)
            close();
        super.update(elapsed);
    }
    
    function onSwitch() 
	{
		if (_parentState != null)
		{
			// you can keep updating parent state if you want to, but keep in mind that
			// if you will update parent state then you will update buttons in it,
			// so you need to deactivate buttons in parent state
			_parentState.persistentUpdate = !_parentState.persistentUpdate;
	
			// you can keep drawing parent state if you want to 
			// (for example, when substate have transparent background color)
			_parentState.persistentDraw = !_parentState.persistentDraw;
		}
	}
}