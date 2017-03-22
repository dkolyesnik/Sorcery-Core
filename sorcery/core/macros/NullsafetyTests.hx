package sorcery.core.macros;
import haxe.unit.TestCase;
import sorcery.macros.Nullsafety.*;
import sorcery.core.macros.NullsafetyTests.B;
import thx.Assert.*;
/**
 * ...
 * @author Dmitriy Kolesnik
 */
class NullsafetyTests extends TestCase
{
	static var stA:A;
	static var ar:Array<A>;
	var a:A;
	public var fCallAsserted = false;
	var s = {a:{c:"10", i:5, f:function() return "f" }, b:10 };
	var s1 = {a:{c:"10", i:5, f:function() return "f" }, b:10 };
	var aWithBnull:A;
	public function new()
	{
		super();
	}

	override public function setup():Void
	{
		a = new A(this);
		stA = new A(this);
		
		fCallAsserted = false;
		s1.a = null;
		aWithBnull = new A(this);
		aWithBnull.b = null;
		ar = [new A(this), aWithBnull];
	}
	
	public function testSafeCall()
	{
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

		assertTrue(safeCall(localA.b.i));
		assertTrue( safeCall((localA.b.f)()) );
		assertTrue(safeCall(localA.b.f()));
		assertTrue(safeCall(s.a.f()));
		assertFalse(safeCall(s1.a.f()));
		assertTrue(safeCall(ar[0].b.f()));
	}
	
	public function testSafeGet()
	{
		var localA = new A(this);

		var x = safeGet(localA.b.fl);
		assertEquals(x, localA.b.fl);
		
		x = safeGet(aWithBnull.b.fl);
		assertEquals(x, 0);
		
		assertEquals(50.0, safeGet(aWithBnull.b.fl, 50.0));
		assertEquals(100, safeGet(NullsafetyTests.stA.b.i));
		assertEquals(100, safeGet((NullsafetyTests.stA).b.i));
		
		var bb = safeGet(aWithBnull.b);
		assertEquals(bb, null);

		bb = null;
		bb = safeGet(this.a.b);
		assertEquals(bb, a.b);

		var aar = [aWithBnull];
		assertEquals(null, safeGet(aar[0].b.str));

		assertEquals(safeGet(s.a.i, 0), 5);
		assertEquals(safeGet(ar[0].b.str), "someStr");
		assertEquals(safeGet(ar[1].b.str), null);
		
		assertEquals(safeGet(s1.a.c, "1"),"1");
		assertEquals(safeGet(s1.a.c.charAt(0), "1"), "1");

		assertEquals(safeGet(s.a.i, 0), 5);

		assertEquals(safeGet(s1.a.c,"s"),"s");
		assertEquals(safeGet(s1.a.i, 0),0);

	}
}

class A
{
	public var b:B;
	public function new(tc:NullsafetyTests)
	{
		b = new B(tc);
	}
}

class B
{
	public var str = "someStr";
	public var i = 100;
	public var fl = 100.0;
	public var d:Dynamic;
	public function f()
	{
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