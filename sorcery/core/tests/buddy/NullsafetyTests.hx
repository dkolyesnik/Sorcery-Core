package sorcery.core.tests.buddy;
import buddy.SingleSuite;
using buddy.Should;
import sorcery.macros.Nullsafety.*;
/**
 * ...
 * @author Dmitriy Kolesnik
 */
class NullsafetyTests extends SingleSuite
{

	public function new() 
	{
		describe("Testing safeCall, safeGet and safeBOp, it is trying to call a long chain of calls " +
				"returnes true if the last call is done, false if any of the chained calls returned null", {
			
			describe("Chain call on the fiels of class instance, that must succeed",
			{
				var a = new A();
				
				it("Should be able to call a.b.f()", {
					var result = safeCall(a.b.f());
					result.should.be(true);
				});
				
				it("Should really call a last field or method if it returned true",{
					var result = false;
					var callResult = {res:0};
					result = safeCall(a.b.fTestCall(callResult));
					result.should.be(true);
					callResult.res.should.be(1);
				});
				
				it("Should allow to wrap some initial part in parentses to make that part a first check", {
					safeCall((a.b).fl).should.be(true);
				});
				
				it("Should allow check if function is not null using parentses", {
					safeCall((a.b.fEmpty)()).should.be(false);
				});
				
				it("Should be able to call a field", {
					var result = safeCall(a.b.fl);
					result.should.be(true);
				});
				
				var a1 = new A();
				a1.b.str = null;
				it("Should return true if the last call returned null", {
					var result = safeCall(a1.b.str);
					result.should.be(true);
				});
				
				var aWithNull = new A();
				aWithNull.b = null;
				
				it("Should return false if any of the chaied calls, except last, returnes null", {
					var result = safeCall(aWithNull.b.i);
					result.should.be(false);
				});
				
				describe("SafeBOp should work with binop expressions, check right expr and return true if binop is executed", {
					it("Should work with =", {
						var r = 10;
						var f = safeBOp(r = a.b.i); //a.b.i == 100
						r.should.be(100);
						f.should.be(true);
					});
					
					it("Should work with +=", {
						var r = 10;
						var f = safeBOp(r += a.b.i);
						r.should.be(110);
						f.should.be(true);
					});
					
					it("Should not execute binop if there is a null in chain calls of the right expr", {
						var r = 10;
						var f = safeBOp(r = aWithNull.b.i);
						r.should.be(10);
						f.should.be(false);
					});
				});
				
				it("Should work with typedefs", {
					
				});
				
				it("Should work with nested abstracts", {
					
				});
				
				it("Should work with anonymous structures", {
					
				});
				
				
			});
		});
	}
	
}

private class A
{
	public var b:B;
	public function new()
	{
		b = new B();
	}
}

private class B
{
	public var str = "someStr";
	public var i = 100;
	public var fl = 100.0;
	public var d:Dynamic;
	public function f()
	{
		return i;
	}
	
	public function fTestCall(res:FCallResult)
	{
		res.res = 1;
	}

	public function getB():B
	{
		return this;
	}

	public var fEmpty:Void->Void = null;

	public function new()
	{
	}
}
typedef FCallResult = {res:Int};