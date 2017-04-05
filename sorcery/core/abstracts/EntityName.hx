package sorcery.core.abstracts;

/**
 * ...
 * @author Dmitriy Kolyesnik
 */
abstract EntityName(String) from String to String
{
	inline public static var EREG = "[A-Z_0-9]+";
	
	inline public function new(value:String)
	{
		this = value;
	}
	
	public static function validate(value:String):Bool
	{
		return value != null 
			&& new EReg("^" + EREG + "$", "i").match(value);
	}
}