package objects;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import states.PlayState;
import flixel.input.gamepad.FlxGamepad;

import utils.FSM;
import utils.Reg;

import flixel.effects.particles.FlxEmitter;
import objects.Wave;


class Ship extends FlxSprite
{
    private static inline var ACCELERATION:Int = 320; //constants to define ship movement
    private static inline var DRAG:Int = 320;
    private static inline var SPEED:Int = 140;
    private static inline var START_X:Int = 150;
    private static inline var START_Y:Int = 160; //the initial position of the ship after it enters from below the screen
    private static inline var OUT_Y:Int = 250; //how far below the screen the ship starts
        

    private var behavior:FSM; //state machine to change ship behavior
    public var notControlled:Bool; //to make sure that the start tweens are activated only once and for determining whether the bullets should hit the ship
    public var invulnerable:Bool; //to make sure that the player can't do anything and the ship cannot be killed when it is emerging from below the screen or wherever
    private var isFlyingOff:Bool;

    private var sndFly:FlxSound; //whoosh for ship engines
    private var sndFlyOut:FlxSound;
    private var sndExplode:FlxSound; //explosion, obviously
    

    private var explosion:FlxEmitter; //explosion particles

    private var gamepad:FlxGamepad;

    private var state:PlayState;

    private var wave:Wave;

    private var nextWaveStart:Bool;

    public function new()
    {
        super(START_X, OUT_Y);
        loadGraphic(AssetPaths.Ship__png, true, 16, 16);
        setSize(8, 12);
        offset.set(4, 2);
        animation.add("zoom", [0, 1], 12);
        animation.add("idle", [2]);
        animation.add("left", [3]);
        animation.add("right", [4]);

        drag.x = DRAG; //these are pretty much self explanatory
        maxVelocity.x = SPEED;
        behavior = new FSM(start); //since the ship starts off the screen, it must fly in, and that's what the start state does
        notControlled = true;
        invulnerable = true;
        isFlyingOff = false;
        nextWaveStart = true;

        sndFly = FlxG.sound.load(AssetPaths.fly_in__wav, 0.3);
        
        sndExplode = FlxG.sound.load(AssetPaths.sfx_explode_2__wav, 0.3);
        
        sndFlyOut = FlxG.sound.load(AssetPaths.fly_up__wav, 0.5);
        

        explosion = new FlxEmitter(x, y, 20); //initializing explosion particles
        explosion.makeParticles(1, 1, FlxColor.WHITE, 20);
        explosion.lifespan.set(0.1, 1);
        state = cast FlxG.state;
        state.add(explosion); //and adding them to the game
        
        wave = new Wave();
    }

    override public function update(elapsed:Float):Void
    {
        behavior.update();
        gamepad = FlxG.gamepads.lastActive;
        super.update(elapsed);
    }

    private function move():Void
    {
        acceleration.x = 0; //moving left and right

        if (FlxG.keys.anyPressed([LEFT, A]) || (gamepad != null && gamepad.pressed.DPAD_LEFT))
        {
            acceleration.x -= ACCELERATION;
            animation.play("left");
        }
        else if (FlxG.keys.anyPressed([RIGHT, D]) || (gamepad != null && gamepad.pressed.DPAD_RIGHT))
        {
            acceleration.x += ACCELERATION;
            animation.play("right");
        }
        else if (gamepad != null)
        {
            acceleration.x = gamepad.analog.value.LEFT_STICK_X * ACCELERATION;
            if (gamepad.analog.value.LEFT_STICK_X > 0.3)
                animation.play("right");
            else if (gamepad.analog.value.LEFT_STICK_X < -0.3)
                animation.play("left");
            else
                animation.play("idle");
        }
        else
        {
            animation.play("idle");
        }
        
        if ((FlxG.keys.anyJustPressed([SPACE, Z, X, C]) || (gamepad != null && gamepad.anyJustPressed([A, B, X, Y]))) && !invulnerable) //firing is only possible if the ship is not currently being restored
		{
			var laser = state.playerBullets.recycle();
			if (laser != null)
			{
				laser.reset(x + 2, y - 6);
				laser.sndFire.play();
			}
		}
        if (x < 0) //making sure the ship does not exit the screen
            x = 0;
        if (x > FlxG.width - 16)
            x = FlxG.width - 16;
    }

    private function start():Void
    {
        animation.play("zoom");
        isFlyingOff = false;
        if (notControlled)
        {
            if (nextWaveStart)
            {
                wave.displayWaveNumber(Reg.currentWave);
                nextWaveStart = false;
            }
            //first it tweens to a position a little bit above the correct one, then the second tween bring she ship to the correct vertical position
            //also, the not controlled flag is set to false right thereafter, so the tweens are activated only once. Otherwise it keeps activating them
            //and I haven't found a more clever way to do it :(
            var flashing:FlxTween = FlxTween.tween(this, { alpha: 0 }, 0.2, { type: FlxTween.PINGPONG });
            sndFly.play();
            FlxTween.tween(this, {x: START_X, y: START_Y - 10}, 1, { onComplete :function (tween:FlxTween) 
            {
                FlxTween.tween(this, {y: START_Y}, 1, { onComplete: function (tween:FlxTween) 
                {
                    behavior.activeState = move;
                    flashing.cancel();
                    alpha = 1;
                    invulnerable = false;
                }, type:FlxTween.ONESHOT });
            }, type:FlxTween.ONESHOT });
            notControlled = false;
        }
    }

    private function stiff():Void
    {
        if(alive)
            kill();
    }

    public function gameOver():Void
    {
        behavior.activeState = stiff;
    }

    public function nextWave():Void
    {
        behavior.activeState = flyOff;
    }

    public function explode():Void
    {
        explosion.x = x + 8; //sets the explosion to happen where the ship is
        explosion.y = y + 8;
        explosion.start(true, 0.01, 0);
        sndExplode.play();
        velocity.x = 0; //restore ship parameters
        acceleration.x = 0;
        x = START_X;
        y = OUT_Y;
        notControlled = true;
        invulnerable = true;
        behavior.activeState = start; //and behaviour
    }

    private function flyOff():Void
    {
        invulnerable = true;
        notControlled = true;
        velocity.x = 0;
        acceleration.x = 0;
        if (!isFlyingOff)
        {
            sndFlyOut.play();
            animation.play("zoom");
            FlxTween.tween(this, { x: START_X, y: -20}, 1, { ease: FlxEase.quadIn, onComplete: function (tween:FlxTween)
            {
                y = OUT_Y;
                nextWaveStart = true;
                behavior.activeState = start;
            }});
            isFlyingOff = true;
        }
    }
}