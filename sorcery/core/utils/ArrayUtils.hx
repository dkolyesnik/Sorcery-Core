package sorcery.core.utils;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
class ArrayUtils
{

	inline public static function last<T>(array:Array<T>):T
	{
		return array[array.length - 1];
	}
	
	inline public static function first<T>(array:Array<T>):T
	{
		return array[0];
	}

	inline public static function nullsafePush<T>(array:Array<T>, el:T):Void
	{
		if (el != null)
			array.push(el);
	}
	
	inline public static function inverseCopy<T>(array:Array<T>):Array<T>
	{
		var ar = array.copy();
		ar.reverse();
		return ar;
	}
}