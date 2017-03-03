/**
 * Created by Dmitriy Kolesnik on 29.07.2016.
 */
package sorcery.core.interfaces;
import sorcery.core.interfaces.IAgendaChild;
import sorcery.core.interfaces.IAgendaManager;

@:allow(sorcery.core.interfaces.IEntityGroup)
interface IEntity extends IAgendaChild extends IEventSender extends IParent
{
	@:property
	var fullName(get, never) : String;
	@:property
	var group(get, null) : IEntityGroup;
	@:property
	var enabled(get, set) : Bool;
	@:property
	var agenda(get, never) : IAgendaManager;

	function isWrapped():Bool;
	function isGroup():Bool;
	
	private function onAddToGroup(p_group : IEntityGroup) : Void;
	private function onRemoveFromGroup() : Void;

	@:allow(sorcery.core.interfaces.IEntityChild.addAgenda)
	@:allow(sorcery.core.interfaces.IEntityChild.removeAgenda)
	private function updateChildrenAgendaState():Void;
}

