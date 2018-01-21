package sorcery.core.links.resolvers;
import haxecontracts.Contract;
import haxecontracts.HaxeContracts;
import sorcery.core.interfaces.IEntity;

import sorcery.core.abstracts.FullName;
import sorcery.core.interfaces.ILinkResolver;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
class GroupLinkResolver implements ILinkResolver implements HaxeContracts{
	
	var _next:ILinkResolver;

	public function new(next:ILinkResolver) {
		_next = next;
	}
	
	
	/* INTERFACE sorcery.core.interfaces.ILinkResolver */
	
	public function resolve(entity:IEntity):FullName {
		Contract.requires(entity != null && entity.isAddedToRoot());
	
		return _next == null ? entity.group.fullName : _next.resolve(cast entity.group);
	}
	
}