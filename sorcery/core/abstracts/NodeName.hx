package;
import sorcery.macros.Nullsafety.*;
/**
 * ...
 * @author Dmitriy Kolesnik
 */
abstract NodeName(String) from String to String {
	
	inline public function new(value:String)
	{
		this = value;
	}
	
	public static function validate(value:String):Bool
	{
		return value != null && value != "";
	}
}