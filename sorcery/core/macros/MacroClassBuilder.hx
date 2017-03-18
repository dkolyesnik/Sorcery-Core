package sorcery.core.macros;
import haxe.macro.Context;
import haxe.macro.Expr.Access;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.FieldType;
import haxe.macro.Type.ClassField;
import haxe.macro.Type.ClassType;
using sorcery.core.macros.MacroHelperTools;
/**
 * ...
 * @author Dmitriy Kolesnik
 */
#if macro
class MacroClassBuilder
{
	public var localClass(default, null):ClassType;
	var fieldsSnapshot:Array<Field>;
	public var superClass(get, null):ClassType;
	//@:isVar
	//public var constructor(get, set):Field;
	public var fields:Array<Field>;
	public var fieldsMap(get, null):Map<String, Field>;
	public var superFieldsMap(get, null):Map<String, ClassField>;
	
	var _verbose:Null<Bool>;
	
	public function new(?verbose) 
	{
		_verbose = verbose;
		localClass = Context.getLocalClass().get();
		fields = Context.getBuildFields();
		fieldsSnapshot = fields.copy();
	}
	
	public function doStuff(actions:Array<Field->Void>)
	{
		for (a in actions)
		{
			for (f in fieldsSnapshot)
			{
				a(f);
			}
		}
	}
	
	public function addField(field:Field, front = false)
	{
		if (superClass != null)
			if (superFieldsMap.exists(field.name))
				if (field.access == null || field.access.indexOf(Access.AOverride) < 0)
						throw 'Error method';
				
		if (front)
			fields.unshift(field);
		else
			fields.push(field);
	}
	
	public function export(?verboseExport):Array<Field>
	{
		return fields;
	}
	
	public function getFieldByName(string:String, create:Bool = false):Field
	{
		if (fieldsMap.exists(string))
			return fieldsMap[string];
		else if (create)
			return {
				name:string,
				access:[],
				kind: null ,
				pos:null,
				meta: []
			};
		else
			return null;
	}
	
	function get_superClass():ClassType 
	{
		if (superClass == null && localClass.superClass != null)
		{
			superClass = localClass.superClass.t.get();
		}
		return superClass;
	}
	
	//function get_constructor():Field 
	//{
		//if (constructor == null && !_searchedForConstructor)
		//{
			//_searchedForConstructor = true;
			//constructor = fieldsMap.exists("new") ? fieldsMap["new"] : null;
			//if (constructor != null)
				//_constructorWasFound = true;
			//
		//}
		//return constructor;
	//}
	//
	//function set_constructor(const:Field):Field 
	//{
		//if (const.name != "new")
		//{
			//throw "This is not a constructor";
		//}
		//if (_verbose && _constructorWasFound)
			//_log('${localClass.name} original constructor is replaced');
		//
		//return constructor = value;
	//}
	
	inline function _log(msg)
	{
		if(_verbose)
			trace(msg);
	}
	
	function get_superFieldsMap():Map<String, ClassField> 
	{
		if (superFieldsMap == null)
		{
			superFieldsMap = new Map();
			var superCl = localClass.superClass;
			while (superCl != null)
			{
				var cl = superCl.t.get();
				for (f in cl.fields.get())
					if (!superFieldsMap.exists(f.name))
						superFieldsMap[f.name] = f;
				superCl = cl.superClass;
			}
		}
		return superFieldsMap;
	}
	
	function get_fieldsMap():Map<String, Field>
	{
		if (fieldsMap == null)
		{
			fieldsMap = new Map();
			for (f in fieldsSnapshot)
				fieldsMap[f.name] = f;
		}
		return fieldsMap;
	}
}
#end