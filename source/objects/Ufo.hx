package objects;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.effects.particles.FlxEmitter;

import states.PlayState;
import utils.Reg;

import flixel.util.FlxColor;
import flixel.system.FlxSound;


class Ufo extends FlxSprite
{
    private var moveDirection:Int = 1;
    private var explosion:FlxEmitter;
    private var sndBoom:FlxSound;
    private var sndUfo:FlxSound;
    

    public function new()
    {
        var state:PlayState = cast FlxG.state;
        super (-200, -100);
        loadGraphic(AssetPaths.ufo__png, true, 32, 16);
        animation.add("idle", [0, 1, 2, 3], 24, true);
        //active = false;
        alive = false;
        explosion = new FlxEmitter(x, y, 20);
        explosion.makeParticles(1, 1, FlxColor.WHITE, 20);
        explosion.lifespan.set(0.1, 1);
        state.add(explosion);

        sndBoom = FlxG.sound.load(AssetPaths.ufoExplode__wav, 0.4);
        sndUfo = FlxG.sound.load(AssetPaths.ufo__wav, 0.4, true);
        
    }

    override public function update(elapsed:Float):Void
    {
        move();
        super.update(elapsed);
    }

    private function move()
    {
        velocity.x = Math.min(150, 100 + Reg.currentWave * 5) * moveDirection;
        if (x < -10 - width || x > FlxG.width + 10)
        {
            sndUfo.stop();
            kill();
        }    
    }

    public function setUp():Void
    {
        moveDirection *= FlxG.random.sign(50);        
        var restoreX:Int = 0;
        if (moveDirection == 1)
            restoreX = 0;
        else if (moveDirection == -1)
            restoreX = FlxG.width;
        reset(restoreX, 10);
        animation.play("idle");
        sndUfo.play();
        //trace("Direction: " + moveDirection + ", X: " + x);
    }

    public function die():Void
    {
        sndUfo.stop();
        if(alive)
        {
            sndBoom.play();
            explosion.x = x + 8;
            explosion.y = y + 8;
            explosion.start(true, 0.01, 0);
            //sndBoom.play();
            kill();
        }
    }
}