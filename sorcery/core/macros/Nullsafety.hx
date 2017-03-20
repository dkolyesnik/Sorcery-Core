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

	//TODO cleanup the code
	static var _varPref = "_s_";
	static var _flagName = _varPref + "flag";
	static var _resName = _varPref + "res";

	#if macro
	public static function unwrapExpr(expr:Expr, ar:Array<Expr>)
	{
		ar.push(expr);
		switch (expr.expr)
		{
			case ExprDef.EField(e, f):
				trace("EField");
				unwrapExpr(e, ar);
			case ExprDef.EArray(e1, e2):
				trace("EArray");
				unwrapExpr(e1, ar);
			case ExprDef.ECall(e, p):
				trace("ECall");
				unwrapExpr(e, ar);
			case ExprDef.EConst(c):
				trace("EConst");
			case ExprDef.EParenthesis(e):
				trace("EParenthesis");
			default:
				throw "Error: this type of expression is not supported";
		}
	}
	#end
	/**
	 * safeCall(expr)  => returns series of if checks and bool value, false if some check returned null
	 * safeCall((expr)) | safeCall(ident)-> if expr type is Void or not nullable, returns expr, if type is nullable return expr != null
	 * safeCall((expr)()) -> check if expr id not null and make a call, can be used for safe callbacks
	 * safeCall((exor).field.field) -> seri
	 * safeCall(id.field.field.func()) ->
	 * safeCall(id["dsaf"].field.call) - >
	 */

	macro public static function dd(value:Expr, defaultValue:Expr = null)
	{
		trace(Context.typeExpr(value).t);
		trace("--------------------------------");
		//TODO setup
		var defaultResValue = null;
		var needFlag;;
		var needResultVar;
		var isSafeCall = true;
		var type = Context.typeExpr(value).t;
		//-
		//IDEA - задать переменные к-е определяют действия в первом свиче, а затем вызывать парсинг,
		//переменные внешние и потому не надо будет передавать
		
		var exprArray = [];
		switch (value.expr)
		{
			case ExprDef.EBinop(op, e1, e2):
				trace("EBinop");
				defaultResValue = getTypeDefaultValueExpr(Context.typeExpr(e2).t);
				unwrapExpr(e2, exprArray);
			//TODO
			case ExprDef.EUnop(op, p, e):
				trace("EUnop");

				defaultResValue = getTypeDefaultValueExpr(Context.typeExpr(e).t);
				unwrapExpr(e, exprArray);
			//TODO
			case ExprDef.EVars(va):
				throw "Error: declare var outside before using it";
			default:
				defaultResValue = getTypeDefaultValueExpr(Context.typeExpr(value).t);
				unwrapExpr(value, exprArray);
		}
		exprArray.length > 0? exprArray.reverse():throw "Error: np expr";

		var varCounter = 0;
		function createVarName() return _varPref + Std.string(++varCounter);
		
		function createInitialExpr(nextIndex:Int, needToGoDeeper:Bool, callExpr:Expr)
		{
			var tAr = [];
			if (needFlag)
				tAr.push(macro var $_flagName = false);
			if (needResultVar)
				tAr.push(macro var $_resName = defaultResValue;
				
			var newVar = createVarName();
			tAr.push(macro var $newVar = $callExpr;
			var ife = new IfData();
			ife.econd = macro $i{newVar} != null;
			var eifAr = [];
			if (needToGoDeeper)
			{
				eifAr.push(parseExpr(nextIndex, newVar));
			}
			else
			{
				if (needResultVar)
					eifAr.push(macro $i{_resName} = $callExpr);
				else
					eifAr.push(macro $callExpr);
				if (needFlag)
					eifAr.push(macro $i{_flagName} = true);
				
				if (!isSafeCall)
				{
					if (needResultVar)
						if(defaultValue != null)
							ife.eelse = macro $i{_resName} = defaultValue;
					else
						ife.eelse = defaultValue == null ? defaultResValue : defaultValue;
				}
			}
			ife.eif = macro $b{eifAr};
			tAr.push(ife.toExpr(callExpr.pos);
			return macro $b{tAr};
		}
		function parseExpr(index:Int, prevVar:String = null):Expr
		{
			trace(index, prevVar);
			var expr = exprArray[index];
			switch (expr.expr)
			{
				case ExprDef.EField(e, f):
					trace("_EField");
					var nextExpr = index < exprArray.length - 1 ? exprArray[index + 1] : null;
					if (nextExpr != null)
					{
						switch (nextExpr.expr)
						{
							case ECall(e, p):

							default:
						}
					}
				case ExprDef.EArray(e1, e2):
				//TODO
				case ExprDef.EConst(CIdent(s)):
					trace("_EConst-CIdent");
					var nextExpr = index + 1 < exprArray.length ? exprArray[index + 1] : null;
					if (nextExpr == null)
					{
						if (isSafeCall)
							return macro $b {[expr, macro true]};
						else
							return expr;
					}
					else
					{
						var skipIf = false;
						var te = Context.typeExpr(expr);
						switch(te.expr)
						{
							case TConst(TThis) | TTypeExpr(_):
								//do not check this identifier 
								switch(nextExpr.expr)
								{
									case EField(e, f):
										if (index + 2 < exprArray.length)
										{
											var nextNextExpr = exprArray[index + 2];
											if (switch(nextNextExpr.expr)
											{
												case ECall(e, p):
													
												default:
											}
										}
										else
										{
											
										}
									default:
										throw "Error";
								}
							default:
								switch(nextExpr.expr)
								{
									case ECall(e, p):
										/*
										var _0 = iden();
										if(_0 != null)
										{
										
										}
										*/
									default:
										//create temp var and go on
								}
						}
						
					}
				case ExprDef.EParenthesis(e):
					trace("_EParenthesis");
					var nextExpr = index < exprArray.length - 1 ? exprArray[index + 1] : null;
					if (nextExpr == null)
					{
						if (isSafeCall)
							return macro $b {[expr, macro true]};
						else
							return expr;
					}
					else
					{
						switch (nextExpr.expr)
						{
							case ECall(e, p):
								if (isSafeCall)
								{
									/*
									var _flag = false;
									if(expr != null){
										expr();
										_flag = true;
									}
									_flag;
									*/
									var tempAr = [];
									tempAr.push(macro var $_flagName = false);

									var ifExpr = new IfData();
									ifExpr.econd = macro $expr != null;
									ifExpr.eif = macro $b {[macro $ {expr}(), macro $i {_flagName} = true]};
									tempAr.push(ifExpr.toExpr(expr.pos));

									tempAr.push(macro $i {_flagName});

									return macro $b {tempAr};
								}
								else
								{
									//safeGet
									/*
									if(expr != null)
										expr();
									else
										defaultValue;
									*/
									var ifExpr = new IfData();
									ifExpr.econd = macro $expr != null;
									ifExpr.eif = macro $ {expr}();
									ifExpr.eelse = defaultValue == null ? defaultResValue : defaultValue;

									return ifExpr.toExpr(expr.pos);
								}
							default:
								//create new temp var and if() and go on
								if (isSafeCall)
								{
									/*
									var _flag = false;
									var _0 = expr;
									if(_0 != null)
									{
										<= parseCode
									}
									_flag;
									 */
									var tempAr = [];
									var newVar = createVarName();
									tempAr.push(macro var $_flagName = false);
									tempAr.push(macro var $newVar = $defaultValue);

									var ife = new IfData();
									ife.econd = macro $i {newVar} != null;
									ife.eif = parseExpr(++index, newVar);
									tempAr.push(ife.toExpr(expr.pos));

									tempAr.push(macro $i {_flagName});

									return macro $b {tempAr};
								}
								else
								{
									//safeGet
									if (defaultValue == null)
									{
										/*
										var _res = defaultTypeValue;
										var _0 = expr;
										if(_0 != null)
										{
										<= parseCode
										}
										_res;
										*/
										var tempAr = [];
										tempAr.push(macro var $_resName = $defaultResValue);
										var newVar = createVarName();
										tempAr.push(macro var $newVar = $defaultValue);
										var ife = new IfData();
										ife.econd = macro $i {newVar} != null;
										ife.eif = parseExpr(++index, newVar);
										tempAr.push(ife.toExpr(expr.pos));
										tempAr.push(macro $i {_resName});
										return macro $b {tempAr};
									}
									else
									{
										/*
										var _flag = false;
										var _res = defaultTypeValue;
										var _0 = expr;
										if(_0 != null)
										{
										<= parseCode
										}
										if(!_flag)
											_res = defaultValue;
										_res;
										*/
										var tempAr = [];
										tempAr.push(macro var $_flagName = false);
										tempAr.push(macro var $_resName = $defaultResValue);
										var newVar = createVarName();
										tempAr.push(macro var $newVar = $defaultValue);
										var ife = new IfData();
										ife.econd = macro $i {newVar} != null;
										ife.eif = parseExpr(++index, newVar);
										tempAr.push(ife.toExpr(expr.pos));
										ife = new IfData();
										ife.econd = macro !$i {_flagName};
										ife.eif = macro $i {_resName} = $defaultValue;
										tempAr.push(ife.toExpr(expr.pos));
										tempAr.push(macro $i {_resName});
										return macro $b {tempAr};
									}
								}
						}
					}

				//if (index < exprArray.length-1)
				//{//if there are more expr ahead
				////create null check
				//var ifExpr = {econd:null, eif:null, eelse:null};
				//ifExpr.econd = macro $i{newVar} != null;
				//ifExpr.eif = parseExpr(++index, newVar);
				//tempAr.push({expr:EIf(ifExpr.econd, ifExpr.eif, ifExpr.eelse), pos:value.pos });
				//}
				//return macro $b {tempAr};
				default:
			}
			return null;
		}

		
		var result = parseExpr(0);

		return value;

		//trash
		//var t = Context.typeExpr(nextExpr).t;
		//switch (t)
		//{
		//case Type.TAbstract(_.get() => {name:"Int"}, _)
		//|TAbstract(_.get() => {name:"Float"}, _)
		//|TAbstract(_.get() => {name:"Bool"}, _)
		//|TAbstract(_.get() => {name:"Void"}, _):
//
		////if isSafeCall
//
		////if !isSafeCall - safeGet
		///*
		//var _res = defaultTypeVal;
		//if(expr != null){
		//expr();
		//_flag = true;
		//}
		//*/
		//default:
		////is nullable
		////if isSafeCall
		///*
		//var _flag = false;
		//if(expr != null) {
		//var _0 = expr();
		//if(_0 != null)
		//_flah = true;
		//}
		//_flag;
		//*/
		//return macro $expr != null;
//
		//}
	}


	
	macro public static function notNull(value:Expr)
	{
		return macro $value != null;
	}

	macro public static function sd(value:Expr)
	{
		//trace("EXP " + Context.getExpectedType());
		trace(value);

		var isVoidResult = true;
		var resultType = Context.typeExpr(value).t;

		var varCounter = 0;
		function createVarName()
		{
			return _varPref + Std.string(++varCounter);
		}

		function getIfExpr(expr:Expr, subExpr:Expr, prevVar:String)
		{
			var ifExpr = {econd:null, eif:null, eelse:null};
			switch (expr.expr)
			{
				case ExprDef.ECall(e, p):
					switch (e.expr)
					{
						case EField(ef, f):

						case EConst(CIdent(s)):

						default:
							throw "Error";
					}
				case ExprDef.EField(e, f):
					trace("57");
					var varName = createVarName();
					var ifExpr = {econd:null, eif:null, eelse:null};
					ifExpr.econd = macro $i {varName} != null;
					if (prevVar == null)
					{
						//this is the last if body and we do not  need to assigh last call value
						var exprAr = [macro $p {[varName, f]}, subExpr];
						ifExpr.eif = macro $b {exprAr};
						trace(ExprTools.toString(ifExpr.eif));
					}
					else
					{
						var exprAr = [ {expr:EBinop(OpAssign, macro $i{prevVar}, macro $p{[varName,f]}),pos:value.pos }, subExpr];
						ifExpr.eif = macro $b {exprAr};
					}
					return getIfExpr(e, {expr:EIf(ifExpr.econd, ifExpr.eif, ifExpr.eelse), pos:value.pos}, varName);
				default:
					trace("75");
					if (prevVar == null)
					{
						return macro $b {[expr, subExpr]};
					}
					else
					{
						var exprAr = [];
						exprAr.push(Context.parse('var $prevVar =', value.pos));
					}

			}

			//var ifExpr = {econd:null, eif:null, eelse:null};
			//ifExpr.econd = macro { 4 >  Math.random() * 5; };
			//ifExpr.eif = macro $b{[
			//Context.parse('${_flagName} = true' ,expr.pos),
			//expr
			//]};
			return macro $b {[ {expr:EIf(ifExpr.econd, ifExpr.eif, ifExpr.eelse), pos:expr.pos}]};
		}

		switch (value.expr)
		{
			case EConst(CInt(_) | CFloat(_) | CString(_) | CIdent("true" | "false" | "null")):
			//return value;
			//case ExprDef.EBinop(OpAssignOp(b), e1, e2):
			//return macro $b{[
			//{expr:EBinop(OpAssignOp(b), e1, getIfExpr(e2)), pos:value.pos}
			//]};
			//case ExprDef.EBinop(OpAssign, e1, e2):
			//return macro $b{[
			//{expr: EBinop(OpAssign, e1, getIfExpr(e2)), pos:value.pos}
			//]};
			//case ExprDef.EVars(va):
			//if (va.length > 1)
			//throw "don't work with multiple vars";
			//var v = va[0];
			//return macro $b{[
			//{expr:EVars([{name:v.name, type:v.type, expr:getIfExpr(v.expr)}]), pos:value.pos}
			//]};
			default:
				trace("107");
				var resultExpr = [];
				//resultExpr.push(Context.parse('var ${_flagName} = false', value.pos));
				resultExpr.push(
				{
					expr: EVars([{name:_flagName, type:null, expr:macro false}]),
					pos:value.pos
				});
				if (isVoidResult)
				{
					trace("115");
					resultExpr.push(getIfExpr(value, macro $i {_flagName} = true, null));
					resultExpr.push(macro $i {_flagName});
					//resultExpr.push(Context.parse('${_flagName}', value.pos));
				}
				else
				{
					trace("122");
					resultExpr.push(
					{
						expr:ExprDef.EVars([{name:_resName, type:null, expr:Context.parse(getTypeDefaultValue(resultType), value.pos)}]),
						pos:value.pos
					});
					resultExpr.push(getIfExpr(value, null, _resName));
					resultExpr.push(Context.parse('$_resName', value.pos));
				}
				trace(ExprTools.toString(macro $b {resultExpr}));
				return return macro $b {resultExpr};

		}

		return value;
	}

	#if macro

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
		if (defaultValue == null)
			defaultValue = macro null;

		var type;
		var isVarCreated = false;
		switch (value.expr)
		{
			case ExprDef.EVars(va):
				if (va.length > 1)
					throw "Can't work with several vars";
				var v = va[0];
				isVarCreated = true;

			case ExprDef.EBinop(OpAssignOp(_) | OpAssign, e1, e2):

			default:
		}

		if (type == null)
			type = Context.typeExpr(value).t;
		var actions = getStringActions(value);
		var defaultValueCode = ExprTools.toString(defaultValue);

		var code = "";
		var typeDefaultValue = getTypeDefaultValue(type);
		var isNull = typeDefaultValue == "null";
		if (isNull)
		{
			if (actions.length == 1)
			{
				code  = '\n { ';
				code += '\n var _opt_0 = ${actions[0]};';
				code += '\n if (${actions[0]} == null) _opt_0 = ${defaultValueCode};';
				code += '\n _opt_0;';
				code += '\n }';
				return Context.parse(code, value.pos);
			}
			else if (actions.length > 1)
			{
				var res = getIfElseCode(actions, verboseNull);
				var code = res.start + res.end;
				var resVar = res.resVar;
				code += '\n if($resVar == null) $resVar = $defaultValueCode ; \n $resVar; \n }';

				return Context.parse(code, value.pos);
			}
			else
				throw "Error";
		}
		else
		{
			if (actions.length == 1)
			{
				return value;
			}
			else if (actions.length > 1)
			{
				var res = getIfElseCode(actions, verboseNull, true, typeDefaultValue);
				var code = res.start + res.end;
				var resVar = res.resVar;
				var flagVar = res.flagVar;
				code += '\n if($flagVar) $resVar = $defaultValueCode ; \n $resVar;}';

				return Context.parse(code, value.pos);
			}
			else
				throw "Error";
		}
		return Context.parse("throw 'Error'", value.pos);
	}

	/**
	 * nullsafe chained calls
	 * if any call returns null it stops
	 * generate a number of (if != null) checks and local variables
	 * no anonymous objects, functions and so on, strictly typed
	 * wrapping part of the chain in parentheses will make it the fist
	 * if condition i.e. safeCall((a.b.c).d) will generate one check if(a.b.c != null)
	 * @param	value  -  call chain
	 * @param	verboseNull - if true adds else branches that trace the name of the call that returned null
	 */
	macro public static function safeCall(value:Expr, verboseNull:Bool = false)
	{
		var actions = getStringActions(value);

		//removing unnecessary parentheses
		//TODO revise this, in some cases like cast this may be wrong
		if (actions.length == 1)
			return Context.parseInlineString(actions[0], value.pos);
		var result = getIfElseCode(actions, verboseNull);
		var code = '\n { ${result.start} \n ${result.end} \n ${result.flagVar}; \n}';
		log(code);
		return Context.parse(code, value.pos);
	}

	static function findTopExpr(expr:TypedExpr):ModuleType
	{
		switch (expr.expr)
		{
			case TypedExprDef.TArray(a, e):
				log('TArray');
				return findTopExpr(a);
			case TypedExprDef.TField(e, fa):
				log('TField');
				return findTopExpr(e);
			case TypedExprDef.TTypeExpr(m):
				log('TTypeExpr');
				return m;
			case TypedExprDef.TCall(e, el):
				log('TCall');
				return findTopExpr(e);
			default:
		}
		return null;
	}

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

	static function getTypeDefaultValue(type:Type):String
	{
		switch (type)
		{
			case Type.TAbstract(_.get()=> {name:"Int"}, _):
				return "0";
			case Type.TAbstract(_.get() => {name:"Float"}, _):
				return "0.0";
			case Type.TAbstract(_.get() => {name:"Bool"}, _):
				return "false";
			default:
				return "null";
		}
	}

	#if macro
	static function getStringActions(value:Expr):Array<String>
	{
		log(Std.string(Context.typeof(value)));
		var te = Context.typeExpr(value);
		if (ExprTools.toString(value) == "@:this this")
			throw "Do not use this as static extension, une import static methods instead";
		var code = ExprTools.toString(value);
		log(code);
		var topModuleType = findTopExpr(te);
		var stClassName = "";
		if (topModuleType != null)
		{
			switch (topModuleType)
			{
				case ModuleType.TClassDecl(c):
					stClassName = c.get().name;
				case ModuleType.TEnumDecl(e):
					stClassName = e.get().name;
				case ModuleType.TTypeDecl(t):
					stClassName = t.get().name;
				case ModuleType.TAbstract(a):
					stClassName = a.get().name;
			}
		}

		var actions = [];

		function parseCode()
		{
			var a = "";
			var ci = 0;
			var c = "";
			function findNext(symbol, guard)
			{
				log("find " + symbol);
				ci++;
				while (ci < code.length)
				{
					c = code.charAt(ci);
					a += c;
					if (c == guard)
						findNext(symbol, guard);
					else if (c == symbol)
						break;
					ci++;
				}
			}
			while (ci < code.length)
			{
				c = code.charAt(ci);
				switch (c)
				{
					case "(":
						a += c;
						findNext(")", "(");
					case "[":
						a += c;
						findNext("]", "[");
					case "{":
						a += c;
						findNext("}", "{");
					case ".":
						actions.push(a);
						a = "";
					default:
						a += c;
				}
				ci++;
			}
			actions.push(a);
		}

		if (stClassName != "")
		{
			var a = "";
			var i = code.indexOf(stClassName);
			if (i >= 0)
			{
				a = code.substr(0, i);
				log("a " + a);
				code = code.substr(i + stClassName.length + 1);
				var nextPoint = code.indexOf(".");
				if (nextPoint > 0)
				{
					var fieldName = code.substring(0, code.indexOf("."));
					actions.push(a + stClassName + "." + fieldName);
					code = code.substr(nextPoint + 1);
					parseCode();
				}
				else
					actions.push(a + stClassName + "." + code);
			}
		}
		else
		{
			parseCode();
		}

		//do we need this? can it cause issues?
		for (i in 0...actions.length)
		{
			var a:String = actions[i];
			if (a.charAt(0) == "(" && a.charAt(a.length - 1) == ")")
			{
				a = a.substring(1, a.length - 1);
				actions[i] = a;
			}
		}

		return actions;
	}

	static function getIfElseCode(actions:Array<String>, verboseNull:Bool, varForTheLastCall = false, defaultVarValue = "null")
	{
		var i = 0;
		function genName() return '_opt_' + Std.string(i);
		var prevVar = genName();
		var nextVar;
		var code = "\n var _opt_flag = false;";
		if (varForTheLastCall)
			code += '\n var _opt_0res = $defaultVarValue ;';
		code += "\n var " + prevVar +" = " + actions[0] + ";" ;
		var closing = "";
		i = 1;
		while (i < actions.length-1)
		{
			nextVar = genName();
			log(actions[i]);
			code += '\n if($prevVar != null) {';
			code += '\n var $nextVar = ${prevVar}.${actions[i]};';
			if (verboseNull)
				closing = "\n } else {trace('"+prepareStr(actions[i-1])+" call returend null');}" + closing;
			else
				closing = "\n }" + closing;
			prevVar = nextVar;
			i++;
		}
		nextVar = genName();
		code += "\n if(" + prevVar + " != null) {";
		code += '\n _opt_flag = true;';
		if (varForTheLastCall)
			code += "\n _opt_0res = " + prevVar + "." + actions[i] + ";";
		else
			code += "\n " + prevVar + "." + actions[i] + ";";
		if (verboseNull)
			closing = "\n } else {trace('"+prepareStr(actions[i-1])+" call returend null');}" + closing;
		else
			closing = "\n }" + closing;

		return {start:code, end:closing, resVar:"_opt_0res", flagVar:"_opt_flag"};
	}
	static function prepareStr(str:String):String
	{
		var res = "";
		for (i in 0...str.length)
		{
			var c = str.charAt(i);
			if (c != "'" && c != '"' && c != "$" && c != '\\')
				res += c;
		}
		return res;
	}
	#end
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
