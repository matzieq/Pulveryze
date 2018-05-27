package objects;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.system.FlxSound;



class Bullet extends FlxSprite
{
    private static inline var SPEED:Int = 200;
    private static inline var ACCELERATION:Int = 1400;

    public var sndFire:FlxSound;

    public function new(X:Float, Y:Float)
    {
        super(X, Y);
        loadGraphic(AssetPaths.laser__png, false, 3, 8);
        maxVelocity.y = SPEED;
        sndFire = FlxG.sound.load(AssetPaths.sfx_lazor__wav);
        sndFire.volume = 0.4;
    }


    override public function update(elapsed:Float) 
    {
        acceleration.y = -ACCELERATION;
        if (y < 0)
            kill();
        super.update(elapsed);
    }
}