package sorcery.core.abstracts;
import sorcery.core.interfaces.IEvent;

/**
 * ...
 * @author Dmitriy Kolyesnik
 */
abstract EventType<T:IEvent>(String) to String
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