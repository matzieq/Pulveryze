package utils;

import flixel.util.FlxSave;
import flixel.FlxG;

class Reg //helper class to hold all variables for tracking progress and conduct operations on them
{
    private static var testing:Bool = false;
    public static var score:Int = 0;
    public static var highScore:Int = 0;
    public static var lives:Int = 3;

    public static var scoreToExtraLife:Int = 0;
	public static var nextLife:Int = 5000;

    public static var waveToWeirdBehavior:Int = 0;
	public static var nextWeirdBehavior:Int = 2;
	public static var currentWave:Int = 1;

    inline static private var SAVE_DATA:String = "PULVERYZE";

    static public var save:FlxSave;

    static public function initialize():Void
    {
            
        score = 0;
        //highScore = 0;
        lives = 3;

        scoreToExtraLife = 0;
	    nextLife = 5000;

        waveToWeirdBehavior = 0;

	    currentWave = 1;   
    }
    static public function saveScore():Void
    {
        //Reg.testing = true;
        save = new FlxSave();

        if (save.bind(SAVE_DATA))
        {
            if ((save.data.score == null) || (save.data.score < Reg.score))
                save.data.score = Reg.score;
            if (testing)
                save.data.score = 0;
        }
        save.flush();
    }

    static public function loadScore():Int
    {
        save = new FlxSave();

        if (save.bind(SAVE_DATA))
        {
            if ((save.data != null) && (save.data.score != null))
                highScore = save.data.score;
                return save.data.score;
        }
        return 0;
    }

    static public function calculateAlienY(row:Int, wave:Int):Int
	{
		return row * 18 + Std.int(Math.min(wave * 5 + 10, 50));
	}

    static public function chanceToFire(wave:Int, remainingAliens:Int):Int
	{
		return FlxG.random.int(0, Std.int(60 * remainingAliens / Std.int(Math.min(wave, 5))));
	}

    static public function calculateLivesToDisplay():Int
    {
        var livesToDisplay:Int;
        if (scoreToExtraLife >= nextLife)
		{
			scoreToExtraLife -= nextLife;
			lives++;
			nextLife += 1000;
		}

        if (lives > 5)
            livesToDisplay = 5;
        else if (lives < 1)
            livesToDisplay = 0;
        else
            livesToDisplay = lives - 1;

        return livesToDisplay;
    }
}