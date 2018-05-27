package states;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.input.gamepad.FlxGamepad;
import utils.Reg;
import flash.system.System;



class MenuState extends FlxState
{
    private var title:FlxSprite;
    private var bang:FlxSound;
    private var flyOut:FlxSound;
    private var prompt:FlxText;
    private var credits:FlxText;
    private var highScoreText:FlxText;
    private var ship:FlxSprite;
    private var isGameStarting:Bool;
    private var canStart:Bool;
    private var gamepad:FlxGamepad;
    private var creditsTimer:Float = 0;

    //private var highScore:Int = 0;
    

    override public function create():Void
    {
        FlxG.mouse.visible = false;
        Reg.score = 0;
        Reg.highScore = Reg.loadScore();
        isGameStarting = false;
        canStart = false;
        title = new FlxSprite(FlxG.width/2 - 33, FlxG.height/2 - 50);
        title.loadGraphic(AssetPaths.title__png, false, 66, 32);
        add(title);

        bang = FlxG.sound.load(AssetPaths.bang__wav, 0.5, false);
        flyOut = FlxG.sound.load(AssetPaths.fly_up__wav, 0.5, false);

        title.scale.x = 10;
        title.scale.y = 5;
        FlxTween.tween(title.scale, { x: 2, y: 1 }, 1, { ease: FlxEase.quadIn, onComplete: superTurboFx });

        prompt = new FlxText(FlxG.width/2, 300, 0, "PRESS FIRE TO START", 6);
        prompt.x -= prompt.width/2;
        add(prompt);
        prompt.visible = false;

        credits = new FlxText(FlxG.width/2, 160, 0, "GFX, SND, MUS & PRG BY MATZIEQ", 6);
        credits.x -= credits.width/2;
        credits.color = 0xBBBBBB;
        add(credits);
        credits.alpha = 0;

        highScoreText = new FlxText(FlxG.width/2, 20, 0, "BEST: " + Reg.highScore, 7);
        highScoreText.x -= highScoreText.width/2;
        add(highScoreText);
        highScoreText.visible = false;

        ship = new FlxSprite(150, prompt.y);
        ship.loadGraphic(AssetPaths.Ship__png, true, 16, 16);
        ship.animation.add("idle", [2]);
        ship.animation.add("zoom", [0, 1], 12);
        add(ship);
        ship.visible = false;
        super.create();
    }

    override public function update(elapsed:Float):Void
    {
        gamepad = FlxG.gamepads.lastActive;
        if (!isGameStarting && canStart && (FlxG.keys.anyPressed([SPACE, Z, X, C]) || (gamepad != null && gamepad.anyPressed([A, B, X, Y]))))
        {
            isGameStarting = true;
            ship.animation.play("zoom");
            flyOut.play();
            FlxTween.tween(ship, {y: -30}, 1.5, {ease: FlxEase.quadIn, onComplete: function(tween:FlxTween)
            {
                FlxG.switchState(new PlayState());
            }});
        }
        creditsTimer += elapsed;
        if (creditsTimer > 2.5 && credits.alpha == 0)
        {
            FlxTween.tween(credits, {alpha: 1}, 0.4);
            highScoreText.visible = true;
        }
        // if(FlxG.keys.pressed.ESCAPE)
		// 	System.exit(0);
        // super.update(elapsed);
    }

    public function superTurboFx(tween:FlxTween):Void
    {
        FlxG.camera.flash();
        FlxG.camera.shake(0.1, 1);
        bang.play();
        prompt.visible = true;
        ship.animation.play("idle");
        FlxTween.tween(prompt, { y: 100 }, 1.5, { ease: FlxEase.quadOut });
        ship.visible = true;
        ship.animation.play("zoom");
        FlxTween.tween(ship, { y: 130}, 1.5, {ease: FlxEase.quadOut, onComplete: function(tween:FlxTween)
        {
            ship.animation.play("idle");
            canStart = true;
        } });
        FlxTween.tween(prompt, { alpha: 0 }, 0.2, {type: FlxTween.PINGPONG});
    }
}