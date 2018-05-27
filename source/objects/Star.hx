package objects;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;

class Star extends FlxSprite
{
    public function new(X:Float, Y:Float, starSize:Int)
    {
        super(X, Y);
        makeGraphic(starSize, starSize, FlxColor.GRAY);
        velocity.y = starSize * 20;
    }

    override public function update(elapsed:Float):Void
    {
        if (y > FlxG.height)
            y = 0;
        super.update(elapsed);
    }
}