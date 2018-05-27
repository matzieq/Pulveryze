package objects;

import flixel.group.FlxGroup;
import flixel.FlxG;
import flixel.FlxSprite;
import objects.Star;

class Stars extends FlxTypedGroup<Star>
{
    public function new(starNumber:Int, maxSize:Int)
    {
        super();
        for (i in 0...starNumber)
        {
            var star:Star = new Star(FlxG.random.int(0, FlxG.width), FlxG.random.int(0, FlxG.height), FlxG.random.int(1, maxSize));
            add(star);
        }
    }
}