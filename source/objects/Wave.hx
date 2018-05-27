package objects;

import flixel.text.FlxText;
import flixel.FlxG;
import states.PlayState;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;

class Wave
{
    private var W:FlxText;
    private var A:FlxText;
    private var V:FlxText;
    private var E:FlxText;
    private var waveNumber:FlxText;
    private var sndWave:FlxSound;

    private static inline var BASE_X:Int = 130;
    private static inline var TWEEN_TIME:Float = 0.13;
    
    public function new()
    {
        var state:PlayState = cast FlxG.state;
        W = new FlxText(0, 0, 0, "W", 9);
        A = new FlxText(0, 0, 0, "A", 9);
        V = new FlxText(0, 0, 0, "V", 9);
        E = new FlxText(0, 0, 0, "E", 9);
        waveNumber = new FlxText(0, 0, 0, " ", 9);
        state.add(W);
        state.add(A);
        state.add(V);
        state.add(E);
        state.add(waveNumber);

        sndWave = FlxG.sound.load(AssetPaths.emerge__wav, 0.5);

    }

    public function displayWaveNumber(currentWave:Int):Void
    {
        waveNumber.text = " " + currentWave;
        W.setPosition(-100, 100);
        A.setPosition(100, -100);
        V.setPosition(100, 400);
        E.setPosition(400, 100);
        waveNumber.setPosition(300, 300);
        FlxTween.tween(W, { x: BASE_X, y: 100}, TWEEN_TIME, { onComplete: function(tween:FlxTween)
        {
            sndWave.play();
            FlxTween.tween(A, { x: BASE_X + 10, y: 100}, TWEEN_TIME, {onComplete: function (tween:FlxTween)
            {
                sndWave.play();
                FlxTween.tween(V, { x: BASE_X + 18, y: 100}, TWEEN_TIME, {onComplete: function (tween:FlxTween)
                {
                    sndWave.play();
                    FlxTween.tween(E, { x: BASE_X + 28, y: 100}, TWEEN_TIME, { onComplete: function (tween:FlxTween)
                    {
                        sndWave.play();
                        FlxTween.tween(waveNumber, { x: BASE_X + 40, y: 100}, TWEEN_TIME, {onComplete: function (tween:FlxTween)
                        {
                            sndWave.play();
                            FlxTween.tween(W, {}, 1, { onComplete: tweenOut});
                        }});

                    }});

                }});

            }});

        }});
    }

    private function tweenOut(tween:FlxTween)
    {
        sndWave.play();
        FlxTween.tween(W, { x: -100, y: 100}, TWEEN_TIME, { onComplete: function(tween:FlxTween)
        {
            sndWave.play();
            FlxTween.tween(A, { x: 110, y: -100}, TWEEN_TIME, {onComplete: function (tween:FlxTween)
            {
                sndWave.play();
                FlxTween.tween(V, { x: 400, y: 100}, TWEEN_TIME, {onComplete: function (tween:FlxTween)
                {
                    sndWave.play();
                    FlxTween.tween(E, { x: 140, y: 400}, TWEEN_TIME, { onComplete: function (tween:FlxTween)
                    {
                        sndWave.play();
                        FlxTween.tween(waveNumber, { x: 300, y: 300}, TWEEN_TIME);

                    }});

                }});

            }});

        }});
    }
}