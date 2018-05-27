package objects;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.system.FlxSound;

import states.PlayState;

import flixel.effects.particles.FlxEmitter;

import utils.FSM;
import utils.Reg;

class Alien extends FlxSprite
{
    private var maxSpeed:Int = 40;
    public var movementDirection = 1; 
    private var explosion:FlxEmitter;
    private var sndBoom:FlxSound;
    private var sndEmerge:FlxSound;

    private var playState:PlayState = cast FlxG.state;

    public var alienType:Int; //to refer to calculate score

    public var weirdBehaviour:Int = 0;

    private var brain:FSM;

    public function new(X:Float, Y:Float, state:PlayState, imageNum:Int)
    {
        super(X, -50);
        alienType = imageNum; //to calculate score
        loadGraphic("assets/images/alien" + imageNum + ".png", true, 16, 16);
        animation.add("idle", [0, 1, 2, 3], 6);
        animation.play("idle");

        //set emitter for explosion particles
        explosion = new FlxEmitter(x, y, 20);
        explosion.makeParticles(1, 1, FlxColor.WHITE, 20);
        explosion.lifespan.set(0.1, 1);
        state.add(explosion);

        sndBoom = FlxG.sound.load(AssetPaths.sfx_explode__wav);
        sndBoom.volume = 0.4;

        sndEmerge = FlxG.sound.load(AssetPaths.emerge__wav);
        sndEmerge.volume = 0.3;

        //color = 0x33BB99;
        FlxTween.tween(this, { y: Y }, FlxG.random.float(0.2, 1));
            
        brain = new FSM(move);
        
    }

    override public function update(elapsed:Float):Void
    {
        brain.update();
        super.update(elapsed);
    }

    private function move():Void
    {
        if (weirdBehaviour > 0)
        {
            if (FlxG.random.int(0, 5000) == 1)
            {
                movementDirection *= -1;
            }
        }

        if (weirdBehaviour > 1)
        {
            if (FlxG.random.int(0, 100) == 1)
            {
                y++;
            }
        }
        //the alien will flip horizontal direction when reaching the edge of the screen and then tween 16 pixels down.
        velocity.x = maxSpeed * movementDirection;
        if (x >= FlxG.width - this.width && movementDirection == 1)
        {
            movementDirection = -1;
            flipX = true;
            FlxTween.tween(this, {y: y + 10}, 0.2);
        }
        else if (x < 0 && movementDirection == -1)
        {
            movementDirection = 1;
            flipX = false;
            FlxTween.tween(this, {y: y + 10}, 0.2);
        }
    }

    private function conquer():Void //game over state - aliens won
    {
        velocity.x = 0;
        velocity.y = 70;
    }

    public function aliensWin():Void //triggers the aliens' conquering move
    {
        brain.activeState = conquer;
    }

    public function fire():Void
    {
        if(alive)
        {
            var state:PlayState = cast FlxG.state;
            var bullet = state.alienBullets.recycle(); //find an available bullet
            if (bullet != null)  //if found, fire!
            {
                bullet.reset(x + 8, y + 16);
                bullet.animation.play("idle");
                bullet.velocity.y = Std.int(Reg.currentWave * 10 + 30);
            }
        }
    }

    public function die():Void
    {
        explosion.x = x + 8;
        explosion.y = y + 8;
        explosion.start(true, 0.01, 0);
        sndBoom.play();
        kill();
    }

    public function setSpeed(wave:Int, howManyLeft:Int):Void
    {
        maxSpeed = Std.int(Math.min(100 + wave * 5 - howManyLeft * 2, 150));
    }
}