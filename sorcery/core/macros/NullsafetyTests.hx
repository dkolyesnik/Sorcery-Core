package sorcery.core.macros;
import haxe.unit.TestCase;
import sorcery.core.macros.Nullsafety.*;
import sorcery.core.macros.NullsafetyTests.B;
import thx.Assert.*;
/**
 * ...
 * @author Dmitriy Kolesnik
 */
class NullsafetyTests
{
	static var stA:A;
	static var ar:Array<A>;
	var a:A;
	public var fCallAsserted = false;
	
	public function new() 
	{
	}
	
	
	public function setup():Void 
	{
		a = new A(this);
		stA = new A(this);
		ar = [new A(this)];
		fCallAsserted = false;
	}
	
	public function testSafeCall() {
		setup();
		var localA = new A(this);
		
		
		trace("Function call starting from static field");
		{
			fCallAsserted = false;
			var isCalled = safeCall(stA.b.f());
			
			isTrue(isCalled);
			isTrue(fCallAsserted);
		}
		
		//TODO 
		//trace("Null function call starting from static field");
		//{
			//var isCalled = safeCall(stA.b.fEmpty());
			//
			//isFalse(isCalled);
		//}
		
		trace("start from local ident");
		isTrue(safeCall(localA.b.i));
		isTrue(safeCall((localA.b).f));
		isTrue(safeCall(localA.b.f()));
		
		
	}
	
	public function testSafeGet()
	{
		setup();
		var localA = new A(this);
		var aWithBnull = new A(this);
		aWithBnull.b = null;
		
		var x = safeGet(localA.b.fl);
		equals(x, localA.b.fl);
		x = safeGet(aWithBnull.b.fl);
		equals(x, 0);
		equals(50, safeGet(aWithBnull.b.fl, 50));
		equals(100, safeGet(NullsafetyTests.stA.b.i));
		equals(100, safeGet((NullsafetyTests.stA).b.i));
		var bb = safeGet(aWithBnull.b);
		equals(bb, null);
		
		bb = null;
		bb = safeGet(this.a.b);
		equals(bb, a.b);
		
		var aar = [aWithBnull];
		equals(null, safeGet(aar[0].b.str));
	}
}

class A
{
	public var b:B;
	public function new(tc:NullsafetyTests){
		b = new B(tc);
	}
}


class B
{
	public var str = "someStr";
	public var i = 100;
	public var fl = 100.0;
	public var d:Dynamic;
	public function f(){
		tc.fCallAsserted = true;
	}
	
	public function getB():B
	{
		return this;
	}
	
	public var fEmpty:Void->Void = null;
	
	var tc:NullsafetyTests;
	public function new(tc:NullsafetyTests)
	{
		this.tc = tc;
	}
}