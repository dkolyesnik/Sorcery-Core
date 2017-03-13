package sorcery.core.abstracts;
import sorcery.core.interfaces.IEntity;
import sorcery.core.CoreNames;

/**
 * ...
 * @author Dmitriy Kolyesnik
 */
abstract Path(String) from String to String
{
	inline public static var TO_PARENT = "@";
	inline public static var TO_GROUP = ".";
	inline public static var TO_COMPONENT = ":";
	
	inline static var SEARCH_ENTITY_IN_PARENT = "^[@]*(" + EntityName.EREG + ")?$";
	inline static var SEARCH_COMP_IN_PARENT = "^[@]*\\:" + ComponentName.EREG + "$";
	inline static var SEARCH_IN_GROUP = "^[\\.]*(\\." + EntityName.EREG + ")*(\\:" + ComponentName.EREG + ")?$";
	
	//static var ereg = ~/^[\w-\.]{2,}@[\w-\.]{2,}\.[a-z]{2,6}$/i;
	inline public function new(s:String)
	{
		this = s;
	}

	public static function validate(value:String):Bool
	{
		function check(ereg:String):Bool{
			return new EReg(ereg, "i").match(value);
		}
		return  value != null &&
				(FullName.validate(value) 
				|| check(SEARCH_ENTITY_IN_PARENT)
				|| check(SEARCH_COMP_IN_PARENT)
				|| check(SEARCH_IN_GROUP)
				);
	}
	
	public function toFullName(entity:IEntity):String
	{
		/* @ is link to parent entity
		 * we have several options
		 * 1) full path it will look like
		 * 		#.game.fiels.player.$component
		 * 		#.game.fiels.player:component
		 *    this whole string is the fullName of the entity
		 * 	  = we simply return full string as full name
		 * 2) reletive path it will look like
		 * 		.player - search entity by name in current group
		 *      .:comp - serach child in current group
		 *    	    = owner.group.fullName + this
		 *      ..player:comp  - go up and owner.group.fullName + (this without dots) 
		 *     this meens that we should go down the root by two groups (each dot marks group) from current owner's paretn
		 * 	   so this would be parent group of the parent group of the component's parent
		 *     = we iterate throu string and going up by the group for each dot
		 *       and then when we found not a dot we add founded group's full name to the rest of the string
		 *       if we found root when there are more dots, then path is wrong
		 * 3) reletive path by parents ie parent of the parent and so on
		 *     @@@@@
		 *     each @ meens up one target
		 *     @ - current entity
		 *     @@ - parent of the current entity
		 *        and so on
		 *        can specify child name, but not the path
		 *     @@:some or @@@some - right
		 *     @some.child  - WRONG
		 * 	   . - group
		 *
		 *
		 * */
		if (this.length == 0)
			return entity.fullName;

		switch (this.charAt(0))
		{
			case ":": return entity.fullName + this;
			case CoreNames.ROOT: return this;
			case TO_GROUP: return resolveGroupPath(this, entity);
			case TO_PARENT: return resolveParentsPath(this, entity);
			default: return entity.group.fullName + "." + this;
		}
	}
	
	static function resolveParentsPath(s:String, entity:IEntity):String
	{
		var parent = entity;
		for (i in 1...s.length)
		{
			var c = s.charAt(i);
			if (c == TO_PARENT)
			{
				if (parent.name == CoreNames.ROOT)
					return null;
				parent = parent.parent;
			}
			else if(c == TO_COMPONENT)
			{
				return parent.fullName + s.substr(i);
			}
			else
			{
				return parent.group.fullName + s.substr(i);
			}
		}
		return parent.fullName;
	}
	
	static function resolveGroupPath(s:String, entity:IEntity):String
	{
		var group = entity.group;
		for (i in 1...s.length)
		{
			var c = s.charAt(i);
			if (c == TO_GROUP)
			{
				if (group.name == CoreNames.ROOT)
					return null;
				group = group.parentGroup;
			}
			//else if (c == TO_COMPONENT)
			//{
				//return group.fullName + s.substr(i);
			//}
			else
			{
				return group.fullName + s.substr(i);
			}
		}
		return null;
	}
}

