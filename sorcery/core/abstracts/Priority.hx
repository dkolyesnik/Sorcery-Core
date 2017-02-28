package sorcery.core.abstracts;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
abstract Priority(Int) from Int to Int
{
	//these to for use inside API to be sure that something has ht highes and the lowest prioriy
	inline public static var LOWEST = MAX + 1;
	inline public static var HIGHEST = MIN - 1;
	
	inline public static var MIN = -30000000;
	inline public static var MAX = 30000000;
	
	inline public function new(value:Int)
	{
		this = value;
	}
	
	@:op(A > B) static function gt(a:Priority, b:Priority):Bool;

	@:op( A < B)
	public function less(value:Int):Bool
		return this < value;
	
	@:op(A == B)
	public function equal(value:Int):Bool
		return this == value;
		
	@:op(A >= B)
	public function moreOrEqual(value:Int):Bool
		return this >= value;
		
	@:op(A <= B)
	public function lessOrEqual(value:Int):Bool
		return this <= value;
	
	public static function validate(value:Int):Bool
	{
		return value >= HIGHEST && value <= LOWEST;
	}
}