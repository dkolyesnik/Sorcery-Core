package sorcery.core.links.resolvers;

import haxecontracts.Contract;
import haxecontracts.HaxeContracts;
import sorcery.core.abstracts.FullName;
import sorcery.core.abstracts.ComponentName;
import sorcery.core.interfaces.IEntity;
import sorcery.core.interfaces.ILinkResolver;
 import sorcery.macros.Nullsafety.*;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
class ComponentLinkResolver implements ILinkResolver implements HaxeContracts{

	var _componentName:ComponentName;

	public function new(componentName:ComponentName) {
		_componentName = componentName;
	}

	/* INTERFACE sorcery.core.interfaces.ILinkResolver */
	
	public function resolve(entity:IEntity):FullName {
		Contract.requires(entity != null && entity.isAddedToRoot());
	
		return safeGet((entity.findChild(_componentName)).fullName, FullName.UNDEFINED);
	}
}