package sorcery.core;

import sorcery.core.HandlerData;
import sorcery.core.abstracts.EventType;
import sorcery.core.interfaces.IEntityChildLink;
import sorcery.core.interfaces.IEvent;
import haxe.Constraints.Function;
import haxecontracts.Contract;
import haxecontracts.HaxeContracts;

/**
 * ...
 * @author Dmitriy Kolyesnik
 */
@:generic
class TypedHandlerData<T:IEvent> extends HandlerData implements HaxeContracts
{
	var _handler:T->Void;
	
	public function new(p_type : EventType<T>, p_targetLink : IEntityChildLink, p_handler : T->Void, p_priority : Int = 0)
	{
		Contract.requires(EventType.validate(p_type) && p_targetLink != null && p_handler != null);
		
		super(p_type, p_targetLink, p_priority);
		_handler = p_handler;
	}

	override public function activate(event:IEvent):Void
	{
		_handler(cast event);
	}
}