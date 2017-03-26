package sorcery.core.tests.buddy;
import flash.Lib;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFormat;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
class MyFlashReportPrinter
{
	static var tf:TextField;
	public static function init()
	{
		if (tf != null)
			return;
		tf = new TextField();
		tf.multiline = true;
		var tform = new TextFormat();
		tform.size = 30; 
		tf.setTextFormat(tform);
		var stage = Lib.current.stage;

		stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		stage.addEventListener(Event.RESIZE, function(_) {
			tf.width = stage.stageWidth;
			tf.height = stage.stageHeight;
		});
		tf.scaleX = tf.scaleY = 1.2;
		Lib.current.addChild(tf);
		stage.dispatchEvent(new Event(Event.RESIZE));
	}
	
	public static function print(s : String)
	{
		trace(s);
		if (tf == null) init();
		tf.htmlText += s;
	}

	public static function println(s : String)
	{
		trace(s);
		if (tf == null) init();
		tf.htmlText += s;
		//tf.htmlText += '<p>$s</p>';
	}
}