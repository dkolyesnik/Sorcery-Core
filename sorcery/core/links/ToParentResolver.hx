package sorcery.core.links;

import sorcery.core.interfaces.IEntity;
import sorcery.core.links.LinkResolver;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
class ToParentResolver extends LinkResolver{

	public function new() {
		super();
		
	}

	override public function resolveToEntity(entity:IEntity):IEntity {
		return entity.parent;
	}
	
}