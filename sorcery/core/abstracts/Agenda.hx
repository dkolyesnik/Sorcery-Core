package sorcery.core.abstracts;

/**
 * ...
 * @author Dmitriy Kolyesnik
 */
abstract Agenda(String) from String to String
{
	inline public function new(value:String)
	{
		this = value;
	}
	
	public static function validate(value:String):Bool
	{
		return value != null && value != "";
	}
}