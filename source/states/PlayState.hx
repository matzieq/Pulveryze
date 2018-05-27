package states;

import flixel.FlxState;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;

import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.input.gamepad.FlxGamepad;

import objects.Ship;
import objects.Bullet;
import objects.Alien;
import objects.Stars;
import objects.Ufo;

import utils.Reg;

import flash.system.System;

class PlayState extends FlxState
{
	//objects
	public var ship:Ship;
	public var aliens:FlxTypedGroup<Alien>;
	public var stars:Stars;
	public var alienBullets:FlxTypedGroup<FlxSprite>;
	public var playerBullets:FlxTypedGroup<Bullet>;
	public var ufo:Ufo;

	//constants and derivatives
	private static inline var ALIEN_PER_ROW:Int = 12;
	private static inline var ROWS:Int = 4;
	private static inline var NUMBER_BULLETS:Int = 32;
	private static inline var PLAYER_BULLETS:Int = 3;
	private var alienNumber:Int = ALIEN_PER_ROW * ROWS;

	//text and data objects
	private var scoreText:FlxText; 
	private var gameOverText:FlxText;
	private var ufoText:FlxText; //to display score for killing ufo
	private var livesSprite:FlxSprite;

	// timers and flags
	private var gameOverTimer:Float;
	private var isGameOver:Bool;
	private var isGameOverVisible:Bool;
	private var nextWaveInitiated:Bool;
	private var paused:Bool = false;

	//and the gamepad
	public var gamepad:FlxGamepad;

	override public function create():Void
	{
		FlxG.mouse.visible = false;
		Reg.initialize(); //because weird things happen after reset
		//star field
		stars = new Stars(30, 2); 	//animated starfield with parallax, the first argument is the number of stars, the second - max star size in pixels
		add(stars);					//it generates that number of stars with random sizes in random positions and then moves them downwards. The larger stars move slower

		//bullets
		alienBullets = new FlxTypedGroup<FlxSprite>();
		playerBullets = new FlxTypedGroup<Bullet>();
		add(playerBullets);
		add(alienBullets);
		generateBullets(); //initializes  bullets

		//player ship
		ship = new Ship();
		add(ship);

		//aliens
		aliens = new FlxTypedGroup<Alien>();
		add(aliens);
		generateAliens(); //fills the alien group with aliens

		//large ufo
		ufo = new Ufo();
		add(ufo);

		//texts and other information
		scoreText = new FlxText (10, 2, 0, "Score: " + Reg.score, 9);
		add(scoreText);

		ufoText = new FlxText (-100, -100, 0, "", 7);
		add(ufoText);

		gameOverText = new FlxText(FlxG.width/2, FlxG.height/2, 0, "GAME OVER", 10);
		gameOverText.x -= gameOverText.width/2;
		add(gameOverText);
		gameOverText.visible = false;

		livesSprite = new FlxSprite(248, 2); 								//to display lives I use a single sprite with frames showing different numbers of ships
		livesSprite.loadGraphic(AssetPaths.lives__png, true, 72, 16); 		//the max number is 5, which corresponds to 6 lives
		livesSprite.animation.add("display", [0, 1, 2, 3, 4, 5], 0, false);
		livesSprite.animation.play("display", false, false, Reg.lives - 1); //it displays the specific frame with a correct number of ships
		add(livesSprite);

		//flags and timers
		isGameOver = false;		 	//used in several places to check whether the game is still on, and also to start the game over sequence
		isGameOverVisible = false; 	//used to start the countdown to game reset
		gameOverTimer = 0; 			//the aforementioned timer
		nextWaveInitiated = false;	//this is used to ensure that the aliens are reset only once after the end of a wave

		if (FlxG.sound.music == null) // don't restart the music if it's already playing
		{
			FlxG.sound.playMusic(AssetPaths.invadorz__wav, 1, true);
		}

		gamepad = FlxG.gamepads.lastActive;
		
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		gamepad = FlxG.gamepads.lastActive;

		if (!paused)
		{
			checkBulletsAndFire(); 	//handles alien firing
			checkNextWave();
			checkUfo();				//randomizes ufo
			checkGameOver(elapsed);	//passes in elapsed to use with the timer

			//collisions
			FlxG.overlap(playerBullets, aliens, alienHit);
			FlxG.overlap(alienBullets, ship, playerHit);
			FlxG.overlap(playerBullets, ufo, ufoHit);

			//quit
			// if(FlxG.keys.pressed.ESCAPE)
			// 	System.exit(0);
			super.update(elapsed);
		}
		
		//a little pause routine, cannot pause if the ship is currently being restored
		if (!ship.invulnerable && (FlxG.keys.justPressed.P || (gamepad != null && gamepad.justPressed.START)))
		{
			paused = !paused;
			FlxG.sound.muted = !FlxG.sound.muted;
		}
	}

	private function checkUfo()
	{
		if (!ufo.alive && !ship.invulnerable && !isGameOver && FlxG.random.int(0, 200) == 1) //random chance of ufo appearing
			ufo.setUp();
	}

	private function ufoHit(bullet:Bullet, ufo:Ufo):Void
	{
		var reward = FlxG.random.int(1, 3) * 100;		//the ufo is worth 100-300 points
		ufoText.alpha = 1;
		ufoText.text = "" + reward;
		ufoText.setPosition(ufo.x, ufo.y);
		ufo.die();
		bullet.kill();
		FlxTween.tween(ufoText, {alpha: 0}, 1);
		Reg.score += reward;
		Reg.scoreToExtraLife += reward;

		livesSprite.animation.play("display", false, false, Reg.calculateLivesToDisplay()); //display the correct number of lives
		scoreText.text = "Score: " + Reg.score;
	}

	private function checkNextWave():Void
	{
		if (alienNumber == 0 && !nextWaveInitiated) //if the player destroyed all aliens, restore them and increase difficulty
		{
			alienNumber = ALIEN_PER_ROW * ROWS;
			nextWaveInitiated = true;
			Reg.currentWave++;
			ufo.die();
			for(bullet in alienBullets)
				bullet.kill();
			restoreAliens();
			Reg.waveToWeirdBehavior++;									//after a few rounds
			if (Reg.waveToWeirdBehavior >= Reg.nextWeirdBehavior)		
			{
				Reg.waveToWeirdBehavior -= Reg.nextWeirdBehavior;		//start counting again
				for (alien in aliens)
				{
					alien.weirdBehaviour++;								//and the aliens start having additional quirks
				}
			}
		}
	}

	private function checkGameOver(elapsed:Float):Void
	{
		if (isGameOver && !gameOverText.visible) //first we wait a few seconds to display 'GAME OVER'
		{
			gameOverTimer += elapsed;	
			if (gameOverTimer >= 2.5)
			{
				gameOverTimer = 0;
				gameOverText.visible = true;
				Reg.saveScore();
				if (Reg.score > Reg.highScore)
					FlxTween.tween(scoreText, { alpha: 0.5}, 0.1, { type: FlxTween.PINGPONG });	//if the player got a high score, the score value will be flashing
			}		
		}
		else if (isGameOver && gameOverText.visible) //then we wait another couple of seconds to reset the game
		{
			gameOverTimer += elapsed;
			if (gameOverTimer >= 2)
			{
				FlxG.resetGame();
			}
		}	
	}

	private function checkBulletsAndFire():Void
	{
		for (bullet in alienBullets) //if the bullets are off the screen, kill them
		{
			if (bullet.y > FlxG.height)
				bullet.kill();
		}
		for (alien in aliens) //random chance of each alien firing a bullet
		{
			if (alien.alive && !ship.invulnerable && Reg.chanceToFire(Reg.currentWave, alienNumber) == 1) //it gives me kinda sorta forEachAlive
			{
				alien.fire();
			}

			if(alien.y > 144 && ship.alive) //and if aliens reach the bottom of the screen, they win right away and it's game over
			{
				for (alien in aliens)
				{
					alien.aliensWin();
				}
				ship.explode();
				ship.gameOver();
				isGameOver = true;
				FlxG.sound.playMusic(AssetPaths.invadorzGameOver__wav, 1, false);
				break;
			}
		}

	}

	public function alienHit(bullet:Bullet, alien:Alien):Void
	{
		alien.die();
		bullet.kill();
		alienNumber--;
		for (alien in aliens) //aliens get faster for each one killed
		{
			alien.setSpeed(Reg.currentWave, alienNumber);
		}
		Reg.score += alien.alienType * 10 + 10; //score depends on the type of alien
		Reg.scoreToExtraLife += alien.alienType * 10 + 10; //score depends on the type of alien
	
		livesSprite.animation.play("display", false, false, Reg.calculateLivesToDisplay()); //display the correct number of lives
		scoreText.text = "Score: " + Reg.score;
	}

	public function playerHit(bullet:FlxSprite, ship:Ship):Void
	{
		if(!ship.invulnerable) //if the ship isn't currently being restored
		{
			bullet.kill();
			bullet.y = -100;
			bullet.x = -100;
			Reg.lives--;
			ship.explode();
			if (Reg.lives > 0)	
				livesSprite.animation.play("display", false, false, Reg.calculateLivesToDisplay()); //display the correct number of lives
			else
			{
				ship.gameOver();
				ufo.die();
				for (alien in aliens) 
					alien.aliensWin();
				FlxG.sound.playMusic(AssetPaths.invadorzGameOver__wav, 1, false);
				isGameOver = true;
			}
		}
	}

	private function generateAliens():Void
	{
		for (i in 0...ROWS)
		{
			for (j in 0...ALIEN_PER_ROW)
			{
				var alien = new Alien(j * 18 + 18, Reg.calculateAlienY(i, Reg.currentWave), this, i + 1); //the higher the difficulty, the lower the aliens start on the screen
				alien.setSpeed(Reg.currentWave, alienNumber);
				aliens.add(alien);
			}
		}
	}

	private function restoreAliens():Void
	{
		ship.nextWave();
		FlxTween.tween(ship, {}, 1, { onComplete: function(tween:FlxTween)
		{
		
			aliens.forEach(function(alien)
			{
				alien.kill(); //kill all aliens just in case, because I had some bugs otherwise
			});
			for (i in 0...ROWS)
			{
				for (j in 0...ALIEN_PER_ROW)
				{
					var alien = aliens.recycle(); //pick the first available one
					alien.reset(j * 18 + 18, -100); //reset position
					
					FlxTween.tween(alien, { y: Reg.calculateAlienY(i, Reg.currentWave) }, FlxG.random.float(0.2, 1)); //reset position
					alien.movementDirection = 1; //all move to the right at first
					alien.flipX = false; //and face right
					alien.animation.play("idle", true); //the animation must start from the beginning, so force is set to true
					alien.setSpeed(Reg.currentWave, alienNumber);
				}
			}
			nextWaveInitiated = false;
		}});
	}

	public function generateBullets():Void
	{
		for (i in 0...NUMBER_BULLETS)
		{
			var alienBullet = new FlxSprite(-100, -100); //bullets are initialized off the screen
			alienBullet.loadGraphic(AssetPaths.bullet__png, true, 8, 8);
			alienBullet.animation.add("idle", [0, 1], 6, true);
			
			alienBullet.exists = false; //and they are inactive at first
			alienBullets.add(alienBullet);

		}
		for (i in 0...PLAYER_BULLETS)
		{
			var bullet = new Bullet(-100, -100);
			bullet.kill();
			playerBullets.add(bullet);
		}
	}
}
