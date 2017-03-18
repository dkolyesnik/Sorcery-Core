package sorcery.core.macros;
import haxe.macro.Expr.Field;
import haxe.macro.Expr;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
class MacroHelperTools
{
	public static function isMethod(f:Field):Bool
	{
		switch(f.kind)
		{
			case FieldType.FFun(_): return true;
			default: return false;
		}
	}
	
	public static function isVarOrProp(f:Field):Bool
	{
		switch(f.kind)
		{
			case FieldType.FVar(_, _):	return true;
			case  FieldType.FProp(_, _, _, _):	return true;
			default: return false;
		}
	}
	
}
