package sorcery.core.tools;
import sorcery.core.abstracts.Agenda;
import sorcery.core.interfaces.IEntity;
import sorcery.core.interfaces.IEntityChild;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
class AgendaTools
{
	inline public static function addToAgenda(entity:IEntity, agenda:Agenda, child:IEntityChild)
	{
		if (child.parent != null) 
		{
			if(child.parent != entity)
				throw "Error: can't change agenda if child has parent, TODO";
			entity.removeChild(child);
		}
		child.addAgenda(agenda);
		entity.addChild(child);
	}

	public static function addChildrenToAgenda(entity:IEntity, agenda:Agenda, children:Array<IEntityChild>)
	{
		for (child in children)
		{
			addToAgenda(entity, agenda, child);
		}
	}
}