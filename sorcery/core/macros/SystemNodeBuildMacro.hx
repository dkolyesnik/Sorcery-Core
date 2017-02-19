package sorcery.core.macros;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.FieldType;
import haxe.macro.Expr.Access;
using haxe.macro.ExprTools;
/**
 * ...
 * @author Dmitriy Kolyesnik
 */
#if macro
typedef PrepData = {
	varName:String,
	linkPath:String
}

class SystemNodeBuildMacro
{
	//TODO Найти поля помеченные как @:sorcery_prepare 
	// добавить создание для них ссылки, добавить получение из них в preapre и сохранить в помеченной переменной
	
	static var medataName = ":sorcery_prepare";
	static var createLinksFuncName = "_createLinks";
	static var prepareFuncName = "prepare";
	static var unprepareFuncName = "unprepare";
	static macro public function build():Array<Field>
	{
		var localClassName = Context.getLocalClass().get().name;
		var fieldsArray = Context.getBuildFields();
		var selectedData = new Array<PrepData>();
		
		log('Working with ${Context.getLocalClass().get().name}');
		var createLinksField:Field;
		var prepareField:Field;
		var unprepareField:Field;
		
		for ( field in fieldsArray)
		{
			var linkPath;
			if (field.meta != null)
			{
				for (meta in field.meta)
				{
					if (meta.name == medataName && meta.params != null && meta.params.length > 0)
					{
						linkPath = meta.params[0].getValue();
						log('field with meta is found, link path = $linkPath');
					}
				}
			}
			if (linkPath != null && linkPath != "")
			{
				switch(field.kind)
				{
					case FieldType.FVar(_,_):
						selectedData.push({
							varName:field.name,
							linkPath:linkPath
						});
						log('field ${field.name} is selected');
					case FieldType.FProp(_,_,_,_):
						selectedData.push({
							varName:field.name,
							linkPath:linkPath
						});
						log('field ${field.name} is selected');
					case FieldType.FFun(f):
						if (field.name == createLinksFuncName)
							createLinksField = field;
						else if (field.name == prepareFuncName)
							prepareField = field;
						else if (field.name == unprepareFuncName)
							unprepareField = field;
				}
			}
		}
		
		if (selectedData.length == 0)
		{
			log('no marked fields found');
			//we don't find any fields marked for this macros
			return fieldsArray;
		}
		//we selected the fields and methods
		var parentIsSystemNode = Context.getLocalClass().get().superClass.t.get().name == "SystemNode";
		//crating methods if not found and getting it's expressions
		var createLinksExpr:Array<Expr>;
		if (createLinksField == null)
		{
			log('$createLinksFuncName is not found, creating');
			if (parentIsSystemNode)
				createLinksExpr = [];
			else
				createLinksExpr = [macro {super.$createLinksFuncName();} ];
			createLinksField = {
				name:createLinksFuncName,
				access:[APrivate, AOverride],
				kind: FieldType.FFun({
					args:[],
					expr: {
						pos:Context.currentPos(),
						expr:ExprDef.EBlock(createLinksExpr)
					},
					ret: macro:Void
				}),
				pos:Context.currentPos()
			}
			fieldsArray.push(createLinksField);
		}
		else
		{
			log('$createLinksFuncName is found');
			createLinksExpr = getExprArray(createLinksField);
		}
		
		var prepareExprArray:Array<Expr>;
		var privatePrepareField:Field;
		if (prepareField != null)
		{
			privatePrepareField = prepareField;
			log('$prepareFuncName is found, convering it to private method');
			privatePrepareField.name = "_prepare" + localClassName;
			
			if (privatePrepareField.meta == null)
				privatePrepareField.meta = [];
				
			privatePrepareField.meta.push({
				name:":noCompletion",
				pos:Context.currentPos()
			});
			
			privatePrepareField.access.remove(Access.AOverride);
			privatePrepareField.access.remove(Access.APublic);
			privatePrepareField.access.push(Access.APrivate);
			
			prepareField = null;
		}
		log('creating $prepareFuncName');
		if(parentIsSystemNode)
			prepareExprArray = [macro var temp = true];
		else
			prepareExprArray = [macro var temp = super.$prepareFuncName()];
		//if (privatePrepareField != null)
		//{
			//var privatePrepareFieldName = privatePrepareField.name;
			//prepareExprArray.push(macro { temp = temp && this.$privatePrepareFieldName(); });
		//}
		prepareField = {
			name:prepareFuncName,
			access:[APublic, AOverride],
			kind:FieldType.FFun({
				args:[],
				expr: {expr: ExprDef.EBlock(prepareExprArray), pos:Context.currentPos()},
				ret: macro:Bool
			}),
			pos:Context.currentPos()
		}
		fieldsArray.push(prepareField);
		
			//log('$prepareFuncName is found');
			//prepareExprArray = getExprArray(prepareField);
		
		var unprepareExprArray:Array<Expr>;
		if (unprepareField == null)
		{
			log('$unprepareFuncName is not found, creating');
			if (parentIsSystemNode)
				unprepareExprArray = [];
			else
				unprepareExprArray = [macro { super.$unprepareFuncName(); }];
			unprepareField = {
				name:unprepareFuncName,
				access:[APublic, AOverride],
				kind:FieldType.FFun({
					args:[],
					expr: {expr: ExprDef.EBlock(unprepareExprArray), pos:Context.currentPos()},
					ret: macro: Void
				}),
				pos:Context.currentPos()
			}
			fieldsArray.push(unprepareField);
		}
		else
		{
			log('$unprepareFuncName is found');
			unprepareExprArray = getExprArray(unprepareField);
		}
		//modifying methods
		for (data in selectedData)
		{
			var varName = data.varName;
			var path = data.linkPath;
			log('working with data for $varName');
			
			//creating a link field
			var linkName = "__" + varName+"Link";
			fieldsArray.push({
				name: linkName,
				access:[APrivate],
				kind: FieldType.FVar(TPath({pack:["sorcery", "core", "interfaces"], name:"IEntityChildLink"})),
				pos:Context.currentPos(),
				meta:[{name:":noCompletion", pos:Context.currentPos()}]
			});
			if (path.charAt(0) == "-")
			{
				var pathVar = path.substr(1);
				createLinksExpr.push(macro { this.$linkName = createLink(this.$pathVar); });
			}
			else
				createLinksExpr.push(macro { this.$linkName = createLink($v{path}); });
				
			prepareExprArray.push(macro this.$varName = cast this.$linkName.findChild());
			prepareExprArray.push(macro temp = this.$varName != null && temp);
			
			unprepareExprArray.push(macro this.$varName = null);
		}
		prepareExprArray.push(macro return temp);
		
		return fieldsArray;
	}
	
	static function getExprArray(field:Field):Array<Expr>
	{
		switch(field.kind)
		{
			case FieldType.FFun(f):
				if (f.expr != null)
				{
					switch(f.expr.expr)
					{
						case EBlock(a):
							if (a == null)
								trace("ERROR: array in expr block is null");
							return a;
						default:
							trace("ERROR: expr in function in field "+field.name);
							return [];
					}
				}
				else
				{
					var array = new Array<Expr>();
					f.expr = {expr:EBlock(array), pos:Context.currentPos()};
					return array;
				}
			default: 
				trace("ERROR: wrong field "+field.name);
				return [];
		}
		return [];
	}
	
	static function log(msg:Dynamic)
	{
		//trace(msg);
	}
}
#end