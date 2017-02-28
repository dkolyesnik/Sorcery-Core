package sorcery.core.macros;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Access;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.FieldType;
import haxe.macro.Expr.TypeParam;
using haxe.macro.ExprTools;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
/**
	mark static fields with event names with
	@:sorcery_single("funcName", ["_"]) if no args name will be generated based on field name
	or for pool
	@:sorcery_pool("getResetEvent", 1, ["_","subtype"]) 
	all params can be skiped, it's function name and pool size
	array complies to the array of args of the constructor, only in case when EventType param is current event class
	EventType supports either Event or current class by now
	p_type arg is skiped by default if array of args is not specified

**/  
 
#if macro
typedef SelectedSingleField = {field:Field, funcName:String}
typedef SelectedPoolField = {field:Field, funcName:String, size:Int}
class EventBuildMacro
{
	static var metadataSingleName = ":sorcery_single";
	static var metadataPoolName = ":sorcery_pool";
	
	

	public static macro function build():Array<Field>
	{
		var localClassName = Context.getLocalClass().get().name;
		var fields = Context.getBuildFields();
		log('EventBuildMacro   class = $localClassName');
		var singleFields:Array<SelectedSingleField> = [];
		var poolFields:Array<SelectedPoolField> = [];
		var constructor;
		
		function createFuncName(constName:String):String
		{
			return "get" + constToCamelCase(constName) +"Event";
		}
		
		for (f in fields)
		{
			if (f.name == "new")
				constructor = f;
			if (f.meta != null)
			{
				for (m in f.meta)
				{
					var funcName:String = "";
					log('	metadata = ${m.name}');
					if(m.name == metadataSingleName)
					{
						log('	metadata $metadataSingleName is found');
						if (m.params != null && m.params.length > 0)
						{
							if (checkExprIfString(m.params[0]))
								funcName = m.params[0].getValue();
							else 
								throw 'ERROR: $metadataSingleName requires string or zero params, class $localClassName';
						}
						else
						{
							funcName = createFuncName(f.name);
						}
						singleFields.push({
							field:f,
							funcName:funcName
						});
						log('	added to singleFields');
					}
					else if(m.name == metadataPoolName)
					{	
						log('	metadata 2 $metadataPoolName is found');
						var size:Int = -1;
						if (m.params == null || m.params.length == 0)
						{
							funcName = createFuncName(f.name);
						}
						else if(m.params.length <= 2)
						{
							for (p in m.params)
							{
								if (checkExprIfString(p))
									funcName = p.getValue();
								else if (checkExprIfInt(p))
									size = p.getValue();
							}
						}
						else throw 'ERROR: too many argunets in metadata $metadataPoolName of field ${f.name} in class $localClassName';
						
						poolFields.push({
							field:f,
							funcName:funcName,
							size:size
						});
						log('	added to poolFields');
						
					}
				}
			}
		}
		
		
		
		
		function createPrivateVarName(constName:String, postfix:String):String
		{
			return "__" + constToCamelCase(constName) + postfix;
		}
		log('	working on sigleton field');
		for (data in singleFields)
		{
			log('		field ${data.field.name}');
			//create private static field for event singleton
			var eventType = extractParamType(data.field);
			var eventTypeName = "";
			var eventTypePath;
			if (eventType != null)
			{
				switch(eventType){
					case ComplexType.TPath(tp):
						eventTypeName = tp.name;
						eventTypePath = tp;
					default:
				}
			}
			else
			{
				throw 'ERROR: type parameter is not found in field ${data.field.name} in build macros of class $localClassName';
			}
			
			log('			eventTypeName = $eventTypeName');
			if (eventTypeName == "Event" || eventTypeName == localClassName)
			{			
				//create private static field for event singleton
				var privateFieldName = createPrivateVarName(data.field.name, "Event");
				var eventField = {
					name:privateFieldName,
					access:[Access.APrivate, Access.AStatic],
					kind: FieldType.FVar(eventType),
					pos:Context.currentPos()
				}
				fields.push(eventField);
				log('			field $privateFieldName created');
				
				//create public static method for getting an event of this type
				var factoryMethodArgs:Array<FunctionArg> = [];
				if (eventTypeName == localClassName)
				{
					//TODO mask for arguments
					switch(constructor.kind){
						case FieldType.FFun(func):
							for (argument in func.args)
								if (argument.name != "p_type")
									factoryMethodArgs.push(argument);
						default: 
					}
				}
				
				log('			creating function ${data.funcName}');
				var pos = Context.currentPos();
				var eventFabricMethod = {
					name:data.funcName,
					access:[Access.APublic, Access.AStatic],
					kind:FieldType.FFun({
						args:factoryMethodArgs,
						ret: eventType,
						expr: {
							expr: ExprDef.EBlock([
									{ 
										pos:Context.currentPos(),
										expr:ExprDef.EIf(macro $i{privateFieldName} == null, 
										macro $i{privateFieldName} = $e{createNewEventExpresion(privateFieldName, eventTypePath, factoryMethodArgs, data.field.name, Context.currentPos())},
														null)
									},
									macro return $i{privateFieldName}
								]),
							pos:Context.currentPos()
						}
					}),
					pos:Context.currentPos()
				}
				fields.push(eventFabricMethod);
			}
			else
			{
				throw 'ERROR: wrong EventType param for a field marked with metadata $metadataSingleName in class $localClassName';
			}
		}
		
		log('	working on pool fields');
		for (data in poolFields)
		{
			log('		field ${data.field.name}');
			var eventType = extractParamType(data.field);
			var eventTypeName = "";
			var eventTypePath;
			if (eventType != null)
			{
				switch(eventType){
					case ComplexType.TPath(tp):
						eventTypeName = tp.name;
						eventTypePath = tp;
					default:
				}
			}
			else
			{
				throw 'ERROR: type parameter is not found in field ${data.field.name} in build macros of class $localClassName';
			}
			log('			eventTypeName = $eventTypeName');
			
			if (eventTypeName == "Event" || eventTypeName == localClassName)
			{
				//create private static field for events pool
				var privateFieldName = createPrivateVarName(data.field.name, "Pool");
				var arrayComplexType = macro: Array<Int>;
				switch(arrayComplexType)
				{
					case ComplexType.TPath(p):
						p.params[0] = TypeParam.TPType(eventType);
					default:
				}
				
				var eventField = {
					name:privateFieldName,
					access:[Access.APrivate, Access.AStatic],
					kind: FieldType.FVar(arrayComplexType, macro []),
					pos:Context.currentPos()
				}
				fields.push(eventField);
				log('			field $privateFieldName created');
				
				//create public static method for getting an event of this type from the pool
				var factoryMethodArgs:Array<FunctionArg> = [];
				if (eventTypeName == localClassName)
				{
					//TODO mask for arguments
					switch(constructor.kind){
						case FieldType.FFun(func):
							for (argument in func.args)
								if (argument.name != "p_type")
									factoryMethodArgs.push(argument);
						default: 
					}
				}
				
				log('			creating function ${data.funcName}');
				var pos = Context.currentPos();
				var tempVar = "e";
				var eventFabricMethod = {
					name:data.funcName,
					access:[Access.APublic, Access.AStatic],
					kind:FieldType.FFun({
						args:factoryMethodArgs,
						ret: eventType,
						expr: macro {
							var e;
							if ($i{privateFieldName}.length > 0)
							{
								e = $i{privateFieldName}.pop();
							}
							else
							{
								e = $e{createNewEventExpresion(privateFieldName, eventTypePath, factoryMethodArgs, data.field.name, Context.currentPos())};
							}
							return e;
						}
					}),
					pos:Context.currentPos()
				}
				fields.push(eventFabricMethod);
			}
			else
			{
				throw 'ERROR: wrong EventType param for a field marked with metadata $metadataSingleName in class $localClassName';
			}
		}
		
		return fields;
	}
	
	static function createNewEventExpresion(prFieldName:String, eventTP:TypePath, arguments:Array<FunctionArg>, constName:String, pos:Position):Expr
	{
		var params:Array<Expr> = [macro $i{constName} ];
		for (farg in arguments)
		{
			params.push(macro $i{farg.name});
		}
		return {
			expr: ExprDef.ENew(eventTP, params),
			pos:Context.currentPos()
		}
	}
	
	static function constToCamelCase(str:String):String
	{
		var result = "";
		var words = str.toLowerCase().split("_");
		for (w in words)
		{
			result += w.charAt(0).toUpperCase() + w.substr(1);
		}
		return result;
	}
	
	static function checkExprIfString(expr:Expr):Bool
	{
		return switch(expr.expr)
		{
			case ExprDef.EConst(c):
				switch(c)
				{
					case Constant.CString(_):
						return true;
					default:
						return false;
				}
			default: 
				false;
		}
	}
	
	static function checkExprIfInt(expr:Expr):Bool
	{
		return switch(expr.expr)
		{
			case ExprDef.EConst(c):
				switch(c)
				{
					case Constant.CInt(_):
						return true;
					default:
						return false;
				}
			default: 
				false;
		}
	}
	
	static function extractParamType(field:Field):ComplexType
	{
		//log('-- extracting param type');
		var type:ComplexType;
		var expr:Null<Expr>;
		switch(field.kind){
			case FieldType.FVar(t,e):
				type = t;
				expr = e;
			case FieldType.FProp(_, _, t, e):
				type = t;
				expr = e;
			default:
				type = null;
				expr = null;
		}
		if (type == null && expr != null)
		{
			//log('	extracting param type from expresion');
			switch(expr.expr)
			{
				case ExprDef.ENew(t, _):
					if (t.params != null && t.params.length > 0)
						switch(t.params[0])
						{
							case TPType(t):
								return t;
							default:
						}
				default:
			}
		}
					
		if (type != null)
		{
			//log('	field type is not null');
			switch(type)
			{
				case ComplexType.TPath(p):
					if (p.params != null && p.params.length > 0)
					{
						switch(p.params[0]){
							case TypeParam.TPType(t):
								return t;
							case TypeParam.TPExpr(e):
							default:
						}
					}
				default:
			}
		}
		return null;
	}
	
	static function checkExprIfArray(expr:Expr):Bool
	{
		//TODO
		return false;
	}
	
	static function log(msg:Dynamic)
	{
		trace(msg);
	}
}
#end