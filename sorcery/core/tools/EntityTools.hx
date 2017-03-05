package sorcery.core.tools;
import sorcery.core.interfaces.IEntity;
import sorcery.core.interfaces.IEntityChild;
import sorcery.core.CoreNames;

/**
 * ...
 * @author Dmitriy Kolyesnik
 */
class EntityTools
{
	/**
	 * find first child with name childName searching in parents up to root
	 */
	public static function findChildInParents(entity:IEntity, childName):IEntityChild
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
	
	public static function checkWhetherChildCanBeAdded(entity:IEntity, child:IEntityChild):Bool
	{
		if (child.name == CoreNames.ROOT)
		{
			trace("Error: can't add root as a child");
			return false;
		}
		
		if (child.isEntity())
		{
			var parent = entity.parent;
			while (parent != null && parent.name != CoreNames.ROOT)
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

}