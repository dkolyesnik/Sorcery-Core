package sorcery.core.abstracts;
import sorcery.core.interfaces.IEntityChild;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
abstract FrameworkObjName<T>(String) to String
{
	inline public function new(s:String)
	{
		this = s;
	}
	
	public static function validate(value:String):Bool
	{
		return EntityName.validate(value) || ComponentName.validate(value);
	}
}
