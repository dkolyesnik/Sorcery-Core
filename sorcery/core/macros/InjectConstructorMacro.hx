package sorcery.core.macros;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.FieldKind;
import sorcery.core.macros.MacroClassBuilder;
using sorcery.core.macros.MacroHelperTools;
import sorcery.core.macros.Nullsafety.*;
/**
 * ...
 * @author Dmitriy Kolesnik
 */
#if macro
class InjectConstructorMacro
{
	public static var metaName = ":injectArguments";
		
	public static macro function simpleInjectArguments():Array<Field>
	{
		var builder = new MacroClassBuilder();
		var constructor = builder.getFieldByName("new");
		
		function inject()
		{
			switch(constructor.kind)
			{
				case FieldType.FFun(f):
					var inits = [];
					for (a in f.args)
					{
						var ff = builder.getFieldByName(a.name);
						if (ff != null && ff.isVarOrProp())
						{
							var name = a.name;
							inits.push(macro this.$name = $i{name});
						}
					}
					var expr = macro $b {inits};
					f.expr = if (f.expr == null) expr else macro { $expr; ${f.expr}; };
				default:
			}
		}
		
		if (constructor != null)
		{
			if (constructor.meta != null)
				for (m in constructor.meta)
					if (m.name == metaName)
						inject();
		}
		
		return builder.export();
	}
	

	public static function buildInjectAndCreate():Array<Field>
	{
		var builder = new MacroClassBuilder();
		
		var constructor = builder.fieldsMap.exists("new") ? builder.fieldsMap["new"] : null;
		if (constructor == null)
			return builder.export();
		var inits = [];
		switch(constructor.kind)
		{
			case FieldType.FFun(f):
				for (arg in f.args)
				{
					if (arg.type == null)
						throw new Error("Injection macro requires explicit constructor argument types", constructor.pos);
					var name = arg.name;
					inits.push(macro this.$name = $i{name});
					builder.addField({
						name:name,
						access:[Access.APublic],
						kind:FieldType.FVar(arg.type),
						pos:Context.currentPos(),
						meta: []
					});
				}
				var expr = macro $b {inits};
				f.expr = if (f.expr == null) expr else macro { $expr; ${f.expr}; };
			default:
		}
		if (constructor.access == null) constructor.access = [];
		constructor.access.remove(Access.APrivate);
		constructor.access.remove(Access.APublic);
		constructor.access.push(Access.APublic);
		return builder.export();
	}

}
#end