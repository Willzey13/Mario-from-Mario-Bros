package;

import flixel.FlxG;
import flixel.FlxSprite;
import states.menu.MainMenuState;
import flixel.graphics.FlxGraphic;
import data.GameData.MusicBeatState;
import states.*;

class Init extends MusicBeatState
{
	override function create()
	{
		super.create();
		SaveData.init();
				
		FlxG.fixedTimestep = false;
		FlxG.mouse.useSystemCursor = true;
		FlxG.mouse.visible = false;
		FlxGraphic.defaultPersist = true;
		
		for(i in 0...Paths.dumpExclusions.length)
			Paths.preloadGraphic(Paths.dumpExclusions[i].replace('.png', ''));

		if(FlxG.save.data.beenWarned == null)
			Main.switchState(new WarningState());
		else
			Main.switchState(new MainMenuState());
	}
}