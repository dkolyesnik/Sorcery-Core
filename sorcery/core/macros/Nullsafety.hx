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
	
	/**
	 * nullsafe chained calls to get some value, 
	 * if any call returns null returns defaultValue
	 * generate a number of (if != null) checks and local variables
	 * no anonymous objects, functions and so on, strictly typed
	 * @param	value  -  chain to get a value
	 * @param	defaultValue  - default expression
	 * @param	verboseNull - if true adds else branches that trace the name of the call that returned null
	 */
	macro public static function safeGet(value:Expr, defaultValue:Expr, verboseNull:Bool = false)
	{
		var type = Context.typeExpr(defaultValue).t;
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
				var res = getIfElseCode(actions, verboseNull, true);
				var code = res.start + res.end;
				var resVar = res.resVar;
				code += '\n if($resVar == null) $resVar = $defaultValueCode ; \n $resVar;}';

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
				var res = getIfElseCode(actions, verboseNull, true, typeDefaultValue, true);
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
		var code = result.start + result.end;
		log(code);
		return Context.parse(code, value.pos);
	}

	//TODO remove unused cases
	static function findTopExpr(expr:TypedExpr):ModuleType
	{
		switch (expr.expr)
		{
			case TypedExprDef.TConst(c):
				log('TConst');
			case TypedExprDef.TLocal(v):
				log('TLocal ${v.name}');
			case TypedExprDef.TArray(a, e):
				log('TArray');
				return findTopExpr(a);
			case TypedExprDef.TBinop(op, e1, e2):
				log('TBinop');
			case TypedExprDef.TField(e, fa):
				log('TField');
				return findTopExpr(e);
			case TypedExprDef.TTypeExpr(m):
				log('TTypeExpr');
				return m;
			case TypedExprDef.TParenthesis(e):
				log('TParenthesis');
			case TypedExprDef.TObjectDecl(fields):
				log('TObjectDecl');
			case TypedExprDef.TArrayDecl(el):
				log('TArrayDecl');
			case TypedExprDef.TCall(e, el):
				log('TCall');
				return findTopExpr(e);
			case TypedExprDef.TNew(c, p, el):
				log('TNew');
			case TypedExprDef.TUnop(op, p, e):
				log('TUnop');
			case TypedExprDef.TFunction(f):
				log('TFunction');
			case TypedExprDef.TVar(v, e):
				log('TVar');
			case TypedExprDef.TBlock(el):
				log('TBlock');
			case TypedExprDef.TCast(e, m):
				log('TCast');

			default:
		}
		return null;
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
			trace(topModuleType);
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

	static function getIfElseCode(actions:Array<String>, verboseNull:Bool, varsForTheLastCall = false, defaultVarValue = "null", needFlag = false)
	{
		var i = 0;
		function genName() return '_opt_' + Std.string(i);
		var prevVar = genName();
		var nextVar;
		var code = "\n {";
		if (needFlag)
			code += "\n var _opt_flag = true;";
		if (varsForTheLastCall)
			code += '\n var _opt_0res = $defaultVarValue ;';
		code += "\n var " + prevVar +" = " + actions[0] + ";" ;
		var closing = "";
		if (varsForTheLastCall)
			closing = "";
		else
			closing = "\n }";
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
		if (needFlag)
			code += '\n _opt_flag = false;';
		if (varsForTheLastCall)
			code += "\n _opt_0res = " + prevVar + "." + actions[i] + ";";
		else
			code += "\n " + prevVar + "." + actions[i] + ";";
		if (verboseNull)
			closing = "\n } else {trace('"+prepareStr(actions[i-1])+" call returend null');}" + closing;
		else
			closing = "\n }" + closing;

		//trace(code + closing);
		return {start:code, end:closing, resVar:"_opt_0res", flagVar:"_opt_flag"};
	}
	static function prepareStr(str:String):String
	{
		var parts = str.split("'");
		function combine()
		{
			str = "";
			for (p in parts)
				str += p;
		}
		combine();
		parts = str.split('"');
		combine();
		parts = str.split("$");
		combine();
		parts = str.split('\\');
		combine();
		return str;
	}
	#end
}