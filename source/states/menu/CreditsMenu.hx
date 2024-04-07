package states.menu;

import subStates.OptionsSubState;
import data.Discord.DiscordClient;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import data.GameData.MusicBeatState;
import data.SongData;
import gameObjects.menu.AlphabetMenu;

class CreditsMenu extends MusicBeatState
{
	var grpItems:FlxGroup;
	var agangfds:Array<String> = ['rainathall', 'nikk', 'willzey', 've3h'];
	var cargos:Array<String> = ['Diretor', 'Musico', 'Programador', 'Artista'];
	var desc:Array<String> = ['fiz tudo', '???', 'oloko, mod de mario', '???'];

 	var descText:FlxText;
 	var char:FlxSprite;
 	var posbfText:FlxText;

	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite();
		bg.loadGraphic(Paths.image("menu/bg"));
		bg.screenCenter(X);
		add(bg);

		descText = new FlxText();
		descText.setFormat(Main.gFont, 18, 0xFFFFFFFF, LEFT);
		descText.text = desc[curSelected];
		descText.x = FlxG.height;
		add(descText);

		grpItems = new FlxGroup();
		add(grpItems);

		for(i in 0...agangfds.length)
		{
			var item = new AlphabetMenu(0, 0 + (i + 145), agangfds[i], true);
			item.ID = i;
			item.focusY = i - curSelected;
			grpItems.add(item);
		}

		char = new FlxSprite(616, 195);
		char.loadGraphic(Paths.image("credits/" + agangfds[curSelected]));
		char.updateHitbox();
		char.scale.set(0.7, 0.7);
		add(char);

		cargo = new FlxText();
		cargo.text = cargos[curSelected];
		cargo.setFormat(Main.gFont, 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		cargo.y = char.y - 5;
		cargo.x = char.x + 226;
		cargo.size = 46;
		add(cargo);

		changeOption(0);

		posbfText = new FlxText();
		posbfText.text = " ";
		posbfText.color = FlxColor.WHITE;
		posbfText.size = 24;
		//add(posbfText);
	}

	var cargo:FlxText;

	override function beatHit()
	{
		super.beatHit();

		FlxG.camera.zoom = 1.02;
		FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.circInOut});

		/*switch (FlxG.random.int(1, 1))
		{
			case 1:
				if(curBeat % 4 == 0)
				{
					FlxTween.tween(char, {y: char.y - 50}, 0.18, {ease: FlxEase.circOut, type: ONESHOT, onComplete: function (twn:FlxTween)
            		{
                		FlxTween.tween(char, {y: char.y + 50}, 0.18, {ease: FlxEase.circIn});
            		}});
            	}
		}*/
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(Controls.justPressed("BACK")){
			Main.switchState(new MainMenuState());
		}

		if (Controls.justPressed("DOWN"))
			changeOption(1);
		if (Controls.justPressed("UP"))
			changeOption(-1);

		/*if(FlxG.mouse.overlaps(char))
        {
        	trace("Position gay " + char.x + " " + char.y);
        	posbfText.text = char.x + " / " + char.y;
        	posbfText.x = char.x + 50;
        	posbfText.y = char.y + 50;
        	if(FlxG.mouse.pressed){
        		char.setPosition(FlxG.mouse.getPosition().x - char.width /2,
        		FlxG.mouse.getPosition().y - char.height /2);
        	}
        }*/
	}

	var curSelected:Int = 0;

	function changeOption(change:Int)
	{
		curSelected += change;
		curSelected = FlxMath.wrap(curSelected, 0, agangfds.length - 1);

		for(rawItem in grpItems.members)
		{
			if(Std.isOfType(rawItem, AlphabetMenu))
			{
				var item = cast(rawItem, AlphabetMenu);
				item.focusY = item.ID - curSelected;
			}
		}

		FlxTween.tween(char, {y: 145, alpha: 0}, 0.18, {ease: FlxEase.circOut, type: ONESHOT, onComplete: function (twn:FlxTween)
        {
            FlxTween.tween(char, {y: 195, alpha: 1}, 0.18, {ease: FlxEase.circIn});
        }});
		
		char.loadGraphic(Paths.image("credits/" + agangfds[curSelected]));
		cargo.text = cargos[curSelected];
	}
}
