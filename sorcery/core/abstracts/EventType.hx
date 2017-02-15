package sorcery.core.abstracts;

/**
 * ...
 * @author Dmitriy Kolyesnik
 */
abstract EventType<T>(String) to String
{
	inline public function new(s:String)
	{
		this = s;
	}
	
	public static function validate(value:String):Bool
	{
		return value != null && value != "";
	}
}