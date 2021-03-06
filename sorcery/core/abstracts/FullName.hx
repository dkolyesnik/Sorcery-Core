package sorcery.core.abstracts;
import sorcery.core.abstracts.Path;

/**
 * ...
 * @author Dmitriy Kolyesnik
 */
abstract FullName(String) from String to String
{
	//var str = "^#(\\.[A-Z0-9]+)*(\\.\\$[A-Z][A-Z0-9]*)?$";
	inline public static var EREG = Path.ROOT+"(\\."+EntityName.EREG + ")*(\\:"+ComponentName.EREG+")?";

	inline public static var UNDEFINED:FullName = null;

	inline public function new(value:String)
	{
		this = value;
	}
	
	public static function validate(value:String):Bool
	{
		return value != null && new EReg("^"+EREG+"$","i").match(value);
	}
}