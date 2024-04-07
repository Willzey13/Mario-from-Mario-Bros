package states.menu;

import data.Discord.DiscordClient;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import data.Highscore;
import data.Highscore.ScoreData;
import data.GameData.MusicBeatState;
import data.SongData;
import gameObjects.menu.AlphabetMenu;
import gameObjects.hud.HealthIcon;
import states.*;
import subStates.DeleteScoreSubState;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songList:Array<Array<Dynamic>> = [];
	
	function addWeek(songs:Array<String>, icons:Array<String>)
	{
		for(i in 0...songs.length)
		{
			var icon:String	= (icons.length - 1 >= i) ? icons[i] : icons[0];
			
			addSong(songs[i], icon, null);
		}
	}
	
	function addSong(name:String, icon:String, ?color:FlxColor)
	{
		if(color == null)
			color = HealthIcon.getColor(icon);
	
		songList.push([name, icon, color]);
	}

	static var curSelected:Int = 0;
	static var curDiff:Int = 1;

	var bg:FlxSprite;
	var bgTween:FlxTween;
	var grpItems:FlxGroup;

	var scoreCounter:ScoreCounter;
	var songCard:FlxSprite;

	override function create()
	{
		super.create();
		CoolUtil.playMusic("marioMenu");
		DiscordClient.changePresence("In Freeplay", null);

		bg = new FlxSprite().loadGraphic(Paths.image('menu/backgrounds/marioFreeplay'));
		bg.scale.set(1.2,1.2); bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		// mario
		addSong("redballed", "mario");
		
		grpItems = new FlxGroup();
		add(grpItems);

		for(i in 0...songList.length)
		{
			var label:String = songList[i][0];
			label = label.replace("-", " ");

			songCard = new FlxSprite();
			songCard.loadGraphic(Paths.image("cards/card-" + label));
			songCard.screenCenter();
			add(songCard);

			/*var item = new AlphabetMenu(0, songCard.y + 100, label, true);
			item.screenCenter(X);
			add(item);*/

			var icon = new HealthIcon();
			icon.setIcon(songList[i][1]);
			grpItems.add(icon);

			icon.x = 1136;
			icon.y = FlxG.height - icon.height - 28;
			//item.ID = i;
			icon.ID = i;
		}

		scoreCounter = new ScoreCounter();
		add(scoreCounter);

		var resetTxt = new FlxText(0, 0, 0, "PRESS RESET TO DELETE SONG SCORE");
		resetTxt.setFormat(Main.gFont, 28, 0xFFFFFFFF, LEFT);
		var resetBg = new FlxSprite().makeGraphic(
			Math.floor(FlxG.width * 1.5),
			Math.floor(resetTxt.height+ 8),
			0xFF000000
		);
		resetBg.alpha = 0.4;
		resetBg.screenCenter(X);
		resetBg.y = FlxG.height - resetBg.height;
		resetTxt.y = resetBg.y + 4;
		resetTxt.x = 28;
		add(resetBg);
		add(resetTxt);

		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if(Controls.justPressed("UI_UP"))
			changeSelection(-1);
		if(Controls.justPressed("UI_DOWN"))
			changeSelection(1);
		if(Controls.justPressed("UI_LEFT"))
			changeDiff(-1);
		if(Controls.justPressed("UI_RIGHT"))
			changeDiff(1);

		if(Controls.justPressed("RESET"))
			openSubState(new DeleteScoreSubState(songList[curSelected][0], CoolUtil.getDiffs()[curDiff]));

		if(DeleteScoreSubState.deletedScore)
		{
			DeleteScoreSubState.deletedScore = false;
			updateScoreCount();
		}

		if(Controls.justPressed("ACCEPT"))
		{
			try
			{
				var diff = CoolUtil.getDiffs()[curDiff];
				
				//trace('$diff');
				//trace('songs/${songList[curSelected][0]}/${songList[curSelected][0]}-${diff}');
				
				PlayState.playList = [];
				PlayState.SONG = SongData.loadFromJson(songList[curSelected][0], diff);
				//CoolUtil.playMusic();
				
				PlayState.songDiff = diff;
				
				//Main.switchState(new PlayState());
				Main.switchState(new LoadSongState());

				FlxTween.tween(songCard, {y: 2000}, 1, {ease: FlxEase.cubeInOut});
				FlxTween.tween(FlxG.camera, {zoom: 3}, 1, {ease: FlxEase.cubeInOut});
			}
			catch(e)
			{
				FlxG.sound.play(Paths.sound('menu/cancelMenu'));
			}
		}
		
		if(Controls.justPressed("BACK"))
		{
			FlxG.sound.play(Paths.sound('menu/cancelMenu'));
			Main.switchState(new MainMenuState());
		}
	}
	
	public function changeDiff(change:Int = 0)
	{
		curDiff += change;
		curDiff = FlxMath.wrap(curDiff, 0, CoolUtil.getDiffs().length - 1);
		
		updateScoreCount();
	}

	public function changeSelection(?change:Int = 0)
	{
		curSelected += change;
		curSelected = FlxMath.wrap(curSelected, 0, songList.length - 1);
		
		if(bgTween != null) bgTween.cancel();
		bgTween = FlxTween.color(bg, 0.4, bg.color, songList[curSelected][2]);

		if(change != 0)
			FlxG.sound.play(Paths.sound("menu/scrollMenu"));
		
		updateScoreCount();
	}
	
	public function updateScoreCount()
		scoreCounter.updateDisplay(songList[curSelected][0], CoolUtil.getDiffs()[curDiff]);
}
/*
*	instead of it being separate objects in FreeplayState
*	its just a bunch of stuff inside an FlxGroup
*/
class ScoreCounter extends FlxGroup
{
	public var bg:FlxSprite;

	public var text:FlxText;
	public var diffTxt:FlxText;

	public var realValues:ScoreData;
	public var lerpValues:ScoreData;

	public function new()
	{
		super();
		bg = new FlxSprite().makeGraphic(32, 32, 0xFF000000);
		bg.alpha = 0.4;
		add(bg);
		
		var txtSize:Int = 28; // 36

		text = new FlxText(0, 0, 0, "");
		text.setFormat(Main.gFont, txtSize, 0xFFFFFFFF, LEFT);
		//text.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		add(text);
		
		diffTxt = new FlxText(0,0,0,"< DURO >");
		diffTxt.setFormat(Main.gFont, txtSize, 0xFFFFFFFF, LEFT);
		add(diffTxt);

		realValues = {score: 0, accuracy: 0, misses: 0};
		lerpValues = {score: 0, accuracy: 0, misses: 0};
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		text.text = "";

		text.text +=   "HIGHSCORE: " + Math.floor(lerpValues.score);
		text.text += "\nACCURACY:  " +(Math.floor(lerpValues.accuracy * 100) / 100) + "%";
		text.text += "\nMISSES:    " + Math.floor(lerpValues.misses);

		lerpValues.score 	= FlxMath.lerp(lerpValues.score, 	realValues.score, 	 elapsed * 8);
		lerpValues.accuracy = FlxMath.lerp(lerpValues.accuracy, realValues.accuracy, elapsed * 8);
		lerpValues.misses 	= FlxMath.lerp(lerpValues.misses, 	realValues.misses, 	 elapsed * 8);

		if(Math.abs(lerpValues.score - realValues.score) <= 10)
			lerpValues.score = realValues.score;
		if(Math.abs(lerpValues.accuracy - realValues.accuracy) <= 0.4)
			lerpValues.accuracy = realValues.accuracy;
		if(Math.abs(lerpValues.misses - realValues.misses) <= 0.4)
			lerpValues.misses = realValues.misses;

		bg.scale.x = ((text.width + 8) / 32);
		bg.scale.y = ((text.height + diffTxt.height + 8) / 32);
		bg.updateHitbox();

		//bg.y = 0;
		bg.x = FlxG.width - bg.width;

		text.x = FlxG.width - text.width - 4;
		text.y = 4;
		
		diffTxt.x = bg.x + bg.width / 4 - diffTxt.width / 80;
		diffTxt.y = text.y + text.height + 4;
	}

	public function updateDisplay(song:String, diff:String)
	{
		realValues = Highscore.getScore('${song}-${diff}');
		diffTxt.text = '< ${diff.toUpperCase()} >';
		update(0);
	}
}