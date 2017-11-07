package sorcery.core.abstracts;
import sorcery.core.interfaces.IEntity;
import sorcery.core.interfaces.ILinkResolver;
import sorcery.core.links.resolvers.ComponentLinkResolver;
import sorcery.core.links.resolvers.FullNameLinkResolver;
import sorcery.core.links.resolvers.EntityLinkResolver;
import sorcery.core.links.resolvers.GroupLinkResolver;
import sorcery.core.links.resolvers.ParentResolver;

/**
 * ...
 * @author Dmitriy Kolyesnik
 */
abstract Path(String) from String to String
{
	inline static public var ROOT = '#';
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

	/* we have several options
	* 1) full path it will look like
	* 		#.game.fiels.player:component
	*    this whole string is the fullName of the entity
	* 	  = we simply return full string as full name
	* 2) reletive path it will look like
	* 		player - search entity by name in current group
	*      :comp - search child in current entity, equal to entity.findChild("comp")
	*  	player:comp = entity.group.findEntity("player").findChild("comp")
	*      .player:comp  - this would be equal to entity.group.group.findEntity("player").findChild("comp")
	*  	
	* 3) reletive path by parents ie parent of the parent and so on
	*     each @ meens up one parent 
	*     @ - the parent of the current entity
	*     @@:some equal to entity.parent.parent.findChild("some")
	*     @@some equal to entity.parent.parent.group.findEntity("some") 
	*     @.:comp = entity.parent.group.asEntity().findChild("comp")
	*
	* */
	public function toResolver():ILinkResolver {
		if (this.charAt(0) == ROOT)
			return new FullNameLinkResolver(this);
		else
			return createResolver(this);
	}
	
	static function createResolver(s:String):ILinkResolver{
		var name = "";
		for (i in 0...s.length)
		{
			var c = s.charAt(i);
			if (c == TO_GROUP)
			{
				if(name.length > 0)
					return new EntityLinkResolver(name, new GroupLinkResolver(createResolver(s.substr(i+1)) ));	
				else
					return new GroupLinkResolver(createResolver(s.substr(i+1)));
			} else if(c == TO_COMPONENT) {
				if(name.length > 0)
					return new EntityLinkResolver(name, new ComponentLinkResolver(s.substr(i+1)));
				else
					return new ComponentLinkResolver(s.substr(i+1));
			} else if(c == TO_PARENT) {
				if(name.length > 0)
					return new EntityLinkResolver(name, new ParentResolver(createResolver(s.substr(i+1))));
				else
					return new ParentResolver(createResolver(s.substr(i+1)));

			} else {
				name += c;
			}
		}
		return null;
	}
	
	static function createGroupResolver(s:String):GroupLinkResolver{
		var group = entity.group;
		for (i in 1...s.length)
		{
			var c = s.charAt(i);
			if (c == TO_GROUP)
			{
				if (group.name == ROOT)
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
	
	public function toFullName(entity:IEntity):String
	{
		if (this.length == 0)
			return entity.fullName;

		switch (this.charAt(0))
		{
			case TO_COMPONENT: return entity.fullName + this;
			case ROOT: return this;
			case TO_GROUP: return resolveGroupPath(this, entity);
			case TO_PARENT: return resolveParentsPath(this, entity);
			default: return entity.group.fullName + TO_GROUP + this;
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
				if (parent.name == ROOT)
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
				if (group.name == ROOT)
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

