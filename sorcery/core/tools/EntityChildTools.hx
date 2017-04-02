package sorcery.core.tools;
import sorcery.core.interfaces.IEntityChild;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
class EntityChildTools
{
	public static function castTo<T>(child:IEntityChild, cl:Class<T>):T
	{
		if (Std.is(child, cl))
			return cast child;
		else 
			return null;
	}
}