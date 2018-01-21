package sorcery.core.links.resolvers;

import haxecontracts.Contract;
import haxecontracts.HaxeContracts;
import sorcery.core.abstracts.FullName;
import sorcery.core.abstracts.Path;
import sorcery.core.interfaces.IEntity;
import sorcery.core.interfaces.ILinkResolver;
import sorcery.macros.Nullsafety.*;
/**
 * ...
 * @author Dmitriy Kolesnik
 */
class ParentResolver implements ILinkResolver implements HaxeContracts{

	var _next:ILinkResolver;

	public function new(next:ILinkResolver) {
		_next = next;
	}

	/* INTERFACE sorcery.core.interfaces.ILinkResolver */
	
	public function resolve(entity:IEntity):FullName {
		Contract.requires(entity != null && entity.isAddedToRoot());
		
		if(entity.name != Path.ROOT) {
			var nextEntity = entity.parent;
			if(nextEntity != null){
				if(_next == null){
					return nextEntity.fullName;
				} else {
					return _next.resolve(nextEntity);
				}
			}
		}
		return FullName.UNDEFINED;
	}
		
}