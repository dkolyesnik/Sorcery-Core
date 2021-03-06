package sorcery.core.tools;
import sorcery.core.Event;
import sorcery.core.abstracts.FullName;
import sorcery.core.abstracts.Path;
import sorcery.core.interfaces.IEntity;
import sorcery.core.interfaces.IEntityChild;
import sorcery.core.interfaces.IEntityRoot;
import sorcery.core.interfaces.IComponent;
import sorcery.macros.Nullsafety.*;
using sorcery.core.tools.EntityChildTools;
/**
 * ...
 * @author Dmitriy Kolyesnik
 */
class EntityTools
{
	/**
	 * find first child with name childName searching in parents up to root
	 */
	public static function findChildInParents(entity:IEntity, childName:String):IEntityChild
	{
		var par = entity.parent;
		if (par != null)
		{
			var child = par.findChild(childName);
			if (child != null)
				return child;
			par = par.parent;
		}
		return null;
	}
	
	public static function findChildAs<T>(entity:IEntity, childName:String, cl:Class<T>):T
	{
		return safeGet(entity.findChild(childName).castTo(cl));
	}
	
	public static function removeChildByName(entity:IEntity, childName:String):IEntityChild
	{
		var child = entity.findChild(childName);
		return child != null ? entity.removeChild(child) : null;
	}
	
	public static function removeFromParent(child:IEntityChild):Void
	{
		safeCall(child.parent.removeChild(child));
	}
	
	public static function checkWhetherChildCanBeAdded(entity:IEntity, child:IEntityChild):Bool
	{
		if (child.name == Path.ROOT)
		{
			trace("Error: can't add root as a child");
			return false;
		}
		
		if (child.isEntity())
		{
			var parent = entity.parent;
			while (parent != null && parent.name != Path.ROOT)
			{
				if (parent == child)
				{
					trace("child is one of the parents of the entity");
					return false;
				}
				parent = parent.parent;
			}
		}
		
		return true;
		//TODO check for adding to oun children
	}
	
	public static function addChildT<T:IEntityChild>(entity:IEntity, child:T):T
	{
		entity.addChild(child);
		return child;
	}
	
	public static function addChildren(entity:IEntity, children:Array<IEntityChild>):IEntity
	{
		if (entity != null){
			for (child in children)
				entity.addChild(child);
		}
		return entity;
	}

	public static function replace(entity:IEntity, child:IEntityChild):IEntityChild
	{
		if (child.isEntity() || entity.group == null)
		{
			var prevChild = entity.findChild(child.name);
			if (prevChild != null)
			{
				entity.removeChild(prevChild);
			}
			entity.addChild(child);
			return prevChild;
		}
		else
		{
			var prefEntity = entity.group.findEntity(child.name);
			if (prefEntity != null)
			{
				if (prefEntity.parent == entity)
				{
					entity.removeChild(prefEntity);
				}
				else
				{
					trace("Replace Error: can't replace entity from different parent");
					return child;
				}
			}
			entity.addChild(child);
			return prefEntity;
		}
	}

	inline public static function sendEventTo(entity:IEntity, e:Event, targetFullName:FullName):Void
	{
		safeCall((entity.core.root.findChildByFullName(targetFullName)).asEntity().sendEvent(e));
	}
}