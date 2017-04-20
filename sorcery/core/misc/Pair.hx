package sorcery.core.misc;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
class Pair<T,V>
{
	public var a:T;
	public var b:V;
	
	inline public function new(a:T, b:V) 
	{
		this.a = a;
		this.b = b;
	}
	
}