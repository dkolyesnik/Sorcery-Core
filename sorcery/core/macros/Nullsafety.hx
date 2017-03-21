package sorcery.core.macros;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Type.FieldAccess;
import haxe.macro.Type.ModuleType;
import haxe.macro.Type.TConstant;
import haxe.macro.Type.TypedExpr;
import haxe.macro.Type.TypedExprDef;
import haxe.macro.TypedExprTools;
using haxe.macro.ExprTools;
/**
 * ...
 * @author Dmitriy Kolesnik
 */

class Nullsafety
{
	static function log(msg:String)
	{
		//trace(msg);
	}

	static var _varPref = "_s_";
	static var _flagName = _varPref + "flag";
	static var _resName = _varPref + "res";

	/**
	 * safeCall(expr)  => returns series of if checks and bool value, false if some check returned null
	 * safeCall((expr)) | safeCall(ident)-> if expr type is Void or not nullable, returns expr, if type is nullable return expr != null
	 * safeCall((expr)()) -> check if expr id not null and make a call, can be used for safe callbacks
	 * safeCall((exor).field.field) -> seri
	 * safeCall(id.field.field.func()) ->
	 * safeCall(id["dsaf"].field.call) - >
	 */

	/**
	 * nullsafe chained calls
	 * return true if last expression is executed, false otherwise
	 * return value of the last expression is not checked, it can be any type
	 * generate a number of (if != null) checks and local variables
	 * no anonymous objects, functions and so on, strictly typed
	 * wrapping part of the chain in parentheses will make it the fist check condition
	 * i.e. safeCall((a.b.c).d) will generate one check if(a.b.c != null)
	 * @param	value  -  call chain
	 */
	macro public static function safeCall(value:Expr)
	{
		log(value.toString());
		log("--------------------------------");

		if (ExprTools.toString(value) == "@:this this")
			throw "Do not use this as static extension, une import instead";

		var exprArray = [];
		switch (value.expr)
		{
			case EArray(e, _) | EField(e, _) | ECall(e, _):
				exprArray.push(value);
				unwrapExpr(e, exprArray);
			default:
				throw "Error: wrong expression";

		}
		if (exprArray.length == 0)
			throw "Error: need more expressions";

		var createVarName:Void->String;
		var parseExpr:Expr->String->Expr;
		var createNextTempVarAndIf:Expr->Expr;
		var createFinalIfBody:Expr->Expr;
		var varCounter = 0;
		createVarName = function() return _varPref + Std.string(++varCounter);

		createNextTempVarAndIf = function(exprCall:Expr)
		{
			var newVar = createVarName();
			return macro
			{
				var $newVar = $exprCall;
				if ($i{newVar} != null)
				{
					$ {parseExpr(exprArray.pop(), newVar)};
				}
			};
		};

		createFinalIfBody = function(exprCall:Expr)
		{
			return macro { $exprCall; $i{_flagName} = true;};
		};

		parseExpr = function(expr:Expr, prevVar:String)
		{
			switch (expr.expr)
			{
				case EField(e, f):
					if (exprArray.length > 0)
					{
						var nextExpr = exprArray[exprArray.length - 1];
						switch (nextExpr.expr)
						{
							case ECall(e, p):
								//if there is a call after field, do not check fiels alone
								exprArray.pop();
								var callExpr = {expr:ECall(macro $i{prevVar} .$f, p), pos:expr.pos};
								if (exprArray.length > 0)
									return createNextTempVarAndIf(callExpr);
								else
									return createFinalIfBody(callExpr);
							default:
								return createNextTempVarAndIf(macro $i {prevVar} .$f);

						}
					}
					else
						return createFinalIfBody(macro $i {prevVar} .$f);
				case ECall(e, p):
					//possible only after parentses or other call or array
					var callExpr = {expr:ECall(macro $i{prevVar}, p), pos:e.pos};
					if (exprArray.length > 0)
						return createNextTempVarAndIf(callExpr);
					else
						return createFinalIfBody(callExpr);
				case EArray(e1, e2):
					var callExpr = macro $i {prevVar} [$e2];
					if (exprArray.length > 0)
						return createNextTempVarAndIf(callExpr);
					else
						return createFinalIfBody(callExpr);
				default:
					throw "Error";
			}
		};
		var firstExpr = exprArray.pop();
		var firstCheckedExpr;
		switch (firstExpr.expr)
		{
			case EField(e, f):
				firstCheckedExpr = macro $i {f};
			case EParenthesis(e):
				firstCheckedExpr = e;
			case EConst(CIdent(s)):
				if (isIdentifierAThisOrTypeExpr(firstExpr))
				{
					if (exprArray.length > 0)
					{
						var nextExpr = exprArray.pop();
						switch (nextExpr.expr)
						{
							case EField(e, f):
								if (exprArray.length > 0)
								{
									var nextNextExpr = exprArray[exprArray.length-1];
									switch (nextNextExpr.expr)
									{
										case ECall(ec, p):
											exprArray.pop();
											firstCheckedExpr = {expr:ECall(macro $i{s} .$f, p), pos:ec.pos};
										default:
											firstCheckedExpr = macro $i {s} .$f;
									}
								}
								else
								{
									firstCheckedExpr = macro $i {s} .$f;
								}
							default:
								throw "Error";
						}
					}
					else
					{
						throw "Error";
					}
				}
				else
				{
					firstCheckedExpr = macro $i {s};
				}
			default:
				throw "Error";
		}
		if (exprArray.length == 0)
			return macro {$firstCheckedExpr; true; };

		return macro
		{
			var $_flagName = false;
			${createNextTempVarAndIf(firstCheckedExpr)};
			$i{_flagName};
		};
	}

	macro public static function do_safe(value:Expr, callType:CallType )
	{
		log(value.toString());
		log("--------------------------------");

		if (ExprTools.toString(value) == "@:this this")
			throw "Do not use this as static extension, une import instead";

		var exprArray = [];
		switch (value.expr)
		{
			case EArray(e, _) | EField(e, _) | ECall(e, _):
				exprArray.push(value);
				unwrapExpr(e, exprArray);
			default:
				throw "Error: wrong expression";
		}
		if (exprArray.length == 0)
			throw "Error: need more expressions";

		var createVarName:Void->String;
		var parseExpr:Expr->String->Expr;
		var createNextTempVarAndIf:Expr->Expr;
		var createFinalIfBody:Expr->Expr;
		var varCounter = 0;
		createVarName = function() return _varPref + Std.string(++varCounter);

		createNextTempVarAndIf = function(exprCall:Expr)
		{
			var newVar = createVarName();
			return macro
			{
				var $newVar = $exprCall;
				if ($i{newVar} != null)
				{
					$ {parseExpr(exprArray.pop(), newVar)};
				}
			};
		};

		createFinalIfBody = function(exprCall:Expr)
		{
			switch (callType)
			{
				case SafeCall:
					return macro { $exprCall; $i{_flagName} = true; };
				case SafeGet(_, _=>null):
					return macro $i{_resName} = $exprCall;
				case SafeGet(_, _):
					return macro { $i{_resName} = $exprCall; $i{_flagName} = true;};
				case SafeGetNull(_ => null):
					return macro $i {_resName} = $exprCall;
				case SafeGetNull(dv):
					return macro { $i{_resName} = $exprCall; if ($i{_resName} == null) $i{_resName} = $dv;};
			}
		};

		parseExpr = function(expr:Expr, prevVar:String)
		{
			switch (expr.expr)
			{
				case EField(e, f):
					if (exprArray.length > 0)
					{
						var nextExpr = exprArray[exprArray.length - 1];
						switch (nextExpr.expr)
						{
							case ECall(e, p):
								//if there is a call after field, do not check fiels alone
								exprArray.pop();
								var callExpr = {expr:ECall(macro $i{prevVar} .$f, p), pos:expr.pos};
								if (exprArray.length > 0)
									return createNextTempVarAndIf(callExpr);
								else
									return createFinalIfBody(callExpr);
							default:
								return createNextTempVarAndIf(macro $i {prevVar} .$f);

						}
					}
					else
						return createFinalIfBody(macro $i {prevVar} .$f);
				case ECall(e, p):
					//possible only after parentses or other call or array
					var callExpr = {expr:ECall(macro $i{prevVar}, p), pos:e.pos};
					if (exprArray.length > 0)
						return createNextTempVarAndIf(callExpr);
					else
						return createFinalIfBody(callExpr);
				case EArray(e1, e2):
					var callExpr = macro $i {prevVar} [$e2];
					if (exprArray.length > 0)
						return createNextTempVarAndIf(callExpr);
					else
						return createFinalIfBody(callExpr);
				default:
					throw "Error";
			}
		};
		var firstExpr = exprArray.pop();
		var firstCheckedExpr;
		switch (firstExpr.expr)
		{
			case EField(e, f):
				firstCheckedExpr = macro $i {f};
			case EParenthesis(e):
				firstCheckedExpr = e;
			case EConst(CIdent(s)):
				if (isIdentifierAThisOrTypeExpr(firstExpr))
				{
					if (exprArray.length > 0)
					{
						var nextExpr = exprArray.pop();
						switch (nextExpr.expr)
						{
							case EField(e, f):
								if (exprArray.length > 0)
								{
									var nextNextExpr = exprArray[exprArray.length-1];
									switch (nextNextExpr.expr)
									{
										case ECall(ec, p):
											exprArray.pop();
											firstCheckedExpr = {expr:ECall(macro $i{s} .$f, p), pos:ec.pos};
										default:
											firstCheckedExpr = macro $i {s} .$f;
									}
								}
								else
								{
									firstCheckedExpr = macro $i {s} .$f;
								}
							default:
								throw "Error";
						}
					}
					else
					{
						throw "Error";
					}
				}
				else
				{
					firstCheckedExpr = macro $i {s};
				}
			default:
				throw "Error";
		}

		switch (callType)
		{
			case SafeCall:
				return macro {
					var $_flagName = false;
					${createNextTempVarAndIf(firstCheckedExpr)};
					$i{_flagName};
				};
			case SafeGet(dtv, _=>null):
				return macro {
					var $_resName = $dtv;
					${createNextTempVarAndIf(firstCheckedExpr)};
					$i{_resName};
				};
			case SafeGet(dtv, dv):
				return macro {
					var $_flagName = false;
					var $_resName = $dtv;
					${createNextTempVarAndIf(firstCheckedExpr)};
					if (!$i{_flagName})
						$i{_resName} = $dv;
				};
			case SafeGetNull(_):
				return macro {
					var $_resName = null;
					${createNextTempVarAndIf(firstCheckedExpr)};
					$i{_resName};
				};
		}
		
	}

	/*
	var name = safeGet2((core.root).getChilf().getPos(), new Point());
	var name;
	var _0 = core.root;
	var _fl = false;
	var _res = defTypeVal;
	if(_0 != null){
		var _1 = _0.getChilf();
		if(_1 != null){
			_res = _1.getPos();
			_fl = true;
		}
	}
	if(!_fl)
		_res = defExpr;
	_res;

	if(safeGet2(core.root.isAdded(), false))

	*/

	#if macro
	public static function unwrapExpr(expr:Expr, ar:Array<Expr>)
	{
		ar.push(expr);
		switch (expr.expr)
		{
			case EField(e, _) | EArray(e,_) | ECall(e,_):
				unwrapExpr(e, ar);
			case EConst(_)|EParenthesis(_):
			default:
				throw "Error: this type of expression is not supported";
		}
	}

	static function isIdentifierAThisOrTypeExpr(expr:Expr) :Bool
	{
		var te = Context.typeExpr(expr);
		return switch (te.expr)
		{
			case TConst(TThis) | TTypeExpr(_):
				true;
			default:
				false;
		}
	}
	#end

	/**
	 * nullsafe chained calls to get some value,
	 * if any call returns null returns defaultValue
	 * generate a number of (if != null) checks and local variables
	 * no anonymous objects, functions and so on, strictly typed
	 * in case of assignment in assighn call chain value or defaulVelue to a variable
	 * and returns true/false
	 * @param	value  -  chain to get a value
	 * @param	defaultValue  - default expression
	 * @param	verboseNull - if true adds else branches that trace the name of the call that returned null
	 */
	macro public static function safeGet(value:Expr, defaultValue:Expr = null, verboseNull:Bool = false)
	{
		return null;
	}

	//static function findTopExpr(expr:TypedExpr):ModuleType
	//{
	//switch (expr.expr)
	//{
	//case TypedExprDef.TArray(a, e):
	//log('TArray');
	//return findTopExpr(a);
	//case TypedExprDef.TField(e, fa):
	//log('TField');
	//return findTopExpr(e);
	//case TypedExprDef.TTypeExpr(m):
	//log('TTypeExpr');
	//return m;
	//case TypedExprDef.TCall(e, el):
	//log('TCall');
	//return findTopExpr(e);
	//default:
	//}
	//return null;
	//}

	static function getTypeDefaultValueExpr(type:Type):Expr
	{
		return switch (type)
		{
			case Type.TAbstract(_.get()=> {name:"Int"}, _):
				macro 0;
			case Type.TAbstract(_.get() => {name:"Float"}, _):
				macro 0.0;
			case Type.TAbstract(_.get() => {name:"Bool"}, _):
				macro false;
			default:
				macro null;
		}
	}

	//static function getTypeDefaultValue(type:Type):String
	//{
	//switch (type)
	//{
	//case Type.TAbstract(_.get()=> {name:"Int"}, _):
	//return "0";
	//case Type.TAbstract(_.get() => {name:"Float"}, _):
	//return "0.0";
	//case Type.TAbstract(_.get() => {name:"Bool"}, _):
	//return "false";
	//default:
	//return "null";
	//}
	//}

	//#if macro
	//static function getStringActions(value:Expr):Array<String>
	//{
	//log(Std.string(Context.typeof(value)));
	//var te = Context.typeExpr(value);
	//if (ExprTools.toString(value) == "@:this this")
	//throw "Do not use this as static extension, une import static methods instead";
	//var code = ExprTools.toString(value);
	//log(code);
	//var topModuleType = findTopExpr(te);
	//var stClassName = "";
	//if (topModuleType != null)
	//{
	//switch (topModuleType)
	//{
	//case ModuleType.TClassDecl(c):
	//stClassName = c.get().name;
	//case ModuleType.TEnumDecl(e):
	//stClassName = e.get().name;
	//case ModuleType.TTypeDecl(t):
	//stClassName = t.get().name;
	//case ModuleType.TAbstract(a):
	//stClassName = a.get().name;
	//}
	//}
//
	//var actions = [];
//
	//function parseCode()
	//{
	//var a = "";
	//var ci = 0;
	//var c = "";
	//function findNext(symbol, guard)
	//{
	//log("find " + symbol);
	//ci++;
	//while (ci < code.length)
	//{
	//c = code.charAt(ci);
	//a += c;
	//if (c == guard)
	//findNext(symbol, guard);
	//else if (c == symbol)
	//break;
	//ci++;
	//}
	//}
	//while (ci < code.length)
	//{
	//c = code.charAt(ci);
	//switch (c)
	//{
	//case "(":
	//a += c;
	//findNext(")", "(");
	//case "[":
	//a += c;
	//findNext("]", "[");
	//case "{":
	//a += c;
	//findNext("}", "{");
	//case ".":
	//actions.push(a);
	//a = "";
	//default:
	//a += c;
	//}
	//ci++;
	//}
	//actions.push(a);
	//}
//
	//if (stClassName != "")
	//{
	//var a = "";
	//var i = code.indexOf(stClassName);
	//if (i >= 0)
	//{
	//a = code.substr(0, i);
	//log("a " + a);
	//code = code.substr(i + stClassName.length + 1);
	//var nextPoint = code.indexOf(".");
	//if (nextPoint > 0)
	//{
	//var fieldName = code.substring(0, code.indexOf("."));
	//actions.push(a + stClassName + "." + fieldName);
	//code = code.substr(nextPoint + 1);
	//parseCode();
	//}
	//else
	//actions.push(a + stClassName + "." + code);
	//}
	//}
	//else
	//{
	//parseCode();
	//}
//
	////do we need this? can it cause issues?
	//for (i in 0...actions.length)
	//{
	//var a:String = actions[i];
	//if (a.charAt(0) == "(" && a.charAt(a.length - 1) == ")")
	//{
	//a = a.substring(1, a.length - 1);
	//actions[i] = a;
	//}
	//}
//
	//return actions;
	//}

	//static function getIfElseCode(actions:Array<String>, verboseNull:Bool, varForTheLastCall = false, defaultVarValue = "null")
	//{
	//var i = 0;
	//function genName() return '_opt_' + Std.string(i);
	//var prevVar = genName();
	//var nextVar;
	//var code = "\n var _opt_flag = false;";
	//if (varForTheLastCall)
	//code += '\n var _opt_0res = $defaultVarValue ;';
	//code += "\n var " + prevVar +" = " + actions[0] + ";" ;
	//var closing = "";
	//i = 1;
	//while (i < actions.length-1)
	//{
	//nextVar = genName();
	//log(actions[i]);
	//code += '\n if($prevVar != null) {';
	//code += '\n var $nextVar = ${prevVar}.${actions[i]};';
	//if (verboseNull)
	//closing = "\n } else {trace('"+prepareStr(actions[i-1])+" call returend null');}" + closing;
	//else
	//closing = "\n }" + closing;
	//prevVar = nextVar;
	//i++;
	//}
	//nextVar = genName();
	//code += "\n if(" + prevVar + " != null) {";
	//code += '\n _opt_flag = true;';
	//if (varForTheLastCall)
	//code += "\n _opt_0res = " + prevVar + "." + actions[i] + ";";
	//else
	//code += "\n " + prevVar + "." + actions[i] + ";";
	//if (verboseNull)
	//closing = "\n } else {trace('"+prepareStr(actions[i-1])+" call returend null');}" + closing;
	//else
	//closing = "\n }" + closing;
//
	//return {start:code, end:closing, resVar:"_opt_0res", flagVar:"_opt_flag"};
	//}
	//static function prepareStr(str:String):String
	//{
	//var res = "";
	//for (i in 0...str.length)
	//{
	//var c = str.charAt(i);
	//if (c != "'" && c != '"' && c != "$" && c != '\\')
	//res += c;
	//}
	//return res;
	//}
	//#end
}

private enum CallType
{
	SafeCall;
	SafeGet(defTypeValue:Expr, defValue:Expr);
	SafeGetNull(defValue:Expr);
}

@:publicFields
class IfData
{
	var eif:Expr = null;
	var econd:Expr = null;
	var eelse:Expr = null;
	public function new() {}
	inline  function toExpr(pos):Expr
	{
		return {expr:EIf(econd, eif, eelse), pos:pos};
	}
}
