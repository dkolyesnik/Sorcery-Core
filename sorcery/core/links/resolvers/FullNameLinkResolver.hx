package sorcery.core.links.resolvers;

import haxecontracts.Contract;
import haxecontracts.HaxeContracts;
import sorcery.core.abstracts.FullName;
import sorcery.core.interfaces.IEntity;
import sorcery.core.interfaces.ILinkResolver;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
class FullNameLinkResolver implements ILinkResolver implements HaxeContracts{

	var _fullName:FullName;

	public function new(fullName:String) {
		_fullName = fullName;
	}
	
	/* INTERFACE sorcery.core.interfaces.ILinkResolver */
	
	public function resolve(entity:IEntity):FullName {
		Contract.requires(entity != null && entity.isAddedToRoot());
		
		return _fullName;
	}
}