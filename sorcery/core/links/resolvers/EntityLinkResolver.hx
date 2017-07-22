package sorcery.core.links.resolvers;
import haxecontracts.Contract;
import haxecontracts.HaxeContracts;
import sorcery.core.abstracts.EntityName;
import sorcery.core.interfaces.IEntity;

import sorcery.core.abstracts.FullName;
import sorcery.core.interfaces.ILinkResolver;
import sorcery.macros.Nullsafety.*;
/**
 * ...
 * @author Dmitriy Kolesnik
 */
class EntityLinkResolver implements ILinkResolver implements HaxeContracts{

	var _next:ILinkResolver;
	var _entityName:EntityName;

	public function new(entityName:EntityName, next:ILinkResolver) {
		_next = next;
		_entityName = entityName;
	}
	
	
	/* INTERFACE sorcery.core.interfaces.ILinkResolver */
	
	public function resolve(entity:IEntity):FullName {
		Contract.requires(entity != null && entity.isAddedToRoot());
		
		var nextEntity = entity.group.findEntity(_entityName);
		if(nextEntity != null){
			if(_next != null){
				return _next.resolve(nextEntity);
			}else{
				return nextEntity.fullName;
			}
		}
		return FullName.UNDEFINED;
	}
	
}