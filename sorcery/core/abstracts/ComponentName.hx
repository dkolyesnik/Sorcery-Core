package sorcery.core.abstracts;

/**
 * ...
 * @author Dmitriy Kolyesnik
 */
abstract ComponentName(String) from String to String
{
	inline public static var PREFIX = "$";
	inline public static var EREG = "\\$[A-Z][A-Z0-9]*";
	
	public function new(value:String)
	{
		this = value;
	}
	
	public static inline function validate(value:String):Bool
	{
		return value != null && new EReg("^" + EREG + "$", "i").match(value);
	}
}