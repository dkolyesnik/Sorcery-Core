package sorcery.core.macros;
import haxe.macro.Context;
import haxe.macro.Expr;
import sorcery.core.interfaces.IEvent;
import sorcery.core.macros.MacroClassBuilder;
using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using Lambda;
/**
 * ...
 * @author Dmitriy Kolesnik
 */

#if macro
class CommandBuildMacro
{
	static var metaName = ":sorcery_inject";
	static var prepareName = "__s_prepare";
	static var unprepareName = "__s_unprepare";
	static var createLinksName = "_createLinks";
	static var clearLinkName = "_returnLinks";
	
	macro public static function build():Array<Field>
	{
		var builder = new MacroClassBuilder();
		//select fiels with metadata
		var selected = [];
		builder.fields.foreach(function(f:Field){
			switch(f.kind)
			{
				case FFun(_): 
				case FVar(t,_) | FProp(_,_,t,_):
					if (f.meta != null && f.meta.length > 0){
					for (m in f.meta){
						if (m.name == metaName){
							selected.push({f:f, m:m, t:t});
							break;
						}
					}
				}
			}
			return true;
		});
		var prepareExpr = [];
		var unprepareExpr = [];
		var createLinksExpr = [];
		var clearLinksExpr = [];
		//create expressions for functions and fields for links
		if (selected.length > 0)
		{
			prepareExpr.push(macro var fl = true);
			for (sf in selected){
				var f:Field = sf.f;
				var m:MetadataEntry = sf.m;
				var t:ComplexType = sf.t;
				if (m.params == null || m.params.length == 0)
					throw 'Error: not enough metadata params for field $f in class ${builder.localClass.name}';
					
				var path = m.params[0].getValue();
				var required = m.params.length == 2 ? m.params[1] : macro false;
				var linkFieldName = "__link_" + f.name;
				builder.addField({
					name: linkFieldName,
					access:[Access.APrivate],
					kind:FieldType.FVar(TPath({pack:["sorcery","core","interfaces"], name:"IEntityChildLink"})),
					pos:Context.currentPos(),
					meta: [{
						name:":noCompletion",
						params:[],
						pos:Context.currentPos()
					}]
				});
				var className = switch(t) {case TPath(p):p.name; default:throw 'Error: field ${f.name} must be a class type in class ${builder.localClass.name}'; };
				
				prepareExpr.push(macro {
					$i{f.name} =  $i{linkFieldName}.findAs($i{className});
					if ($required && $i{f.name} == null)
						fl = false;
					
				});
				unprepareExpr.push(macro $i{f.name} = null);
				createLinksExpr.push(macro  $i{linkFieldName} = _manager.getLink($v{path}) );
				clearLinksExpr.push(macro _manager.returnLink($i{linkFieldName}));
				clearLinksExpr.push(macro $i{linkFieldName} = null );
				
			}
			prepareExpr.push(macro fl);
			
			//var prepareField = {
				//name:prepareName,
				//access:[Access.APrivate],
				//kind:FieldType.FFun({
					//args:[],
					//ret:macro:Bool,
					//expr: macro $b{prepareExpr}
				//}) ,
				//pos:Context.currentPos(),
				//meta: [{
						//name:":noCompletion",
						//params:[],
						//pos:Context.currentPos()
					//}]
			//}
			//var unprepareField  = {
				//name:unprepareName,
				//access:[Access.APrivate],
				//kind:FieldType.FFun({
					//args:[],
					//ret:macro:Void,
					//expr: macro $b{unprepareExpr}
				//}) ,
				//pos:Context.currentPos(),
				//meta: [{
						//name:":noCompletion",
						//params:[],
						//pos:Context.currentPos()
					//}]
			//}
			var createLinksField = {
				name:createLinksName,
				access:[Access.APrivate, AOverride],
				kind:FieldType.FFun({
					args:[],
					ret:macro:Void,
					expr: macro $b{createLinksExpr}
				}) ,
				pos:Context.currentPos(),
				meta: [{
						name:":noCompletion",
						params:[],
						pos:Context.currentPos()
					}]
			}
			var clearLinksField = {
				name: clearLinkName,
				access:[Access.APrivate, AOverride],
				kind:FieldType.FFun({
					args:[],
					ret:macro:Void,
					expr: macro $b{clearLinksExpr}
				}) ,
				pos:Context.currentPos(),
				meta: []
			}
			
			builder.addField(createLinksField);
			builder.addField(clearLinksField);
			builder.addField({
						name:'activate',
						access:[Access.APublic, AOverride],
						kind:FieldType.FFun({
							args:[{
								name:'event',
								opt:false,
								type: macro: sorcery.core.interfaces.IEvent,
								value: null,
								meta: []
							}],
							ret:macro:Void,
							expr: macro {
								if ($b{ prepareExpr })
									execute(cast event);
								$b{ unprepareExpr };
							}
						}) ,
						pos:Context.currentPos(),
						meta: []
				});
		}
		trace(ExprTools.toString(macro $b{unprepareExpr}));
		return builder.export();
	}
	
}
#end