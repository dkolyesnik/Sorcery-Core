/**
 * Created by Dmitriy Kolesnik on 29.07.2016.
 */
package sorcery.core.interfaces;
import sorcery.core.interfaces.IAgendaChild;
import sorcery.core.interfaces.IAgendaManager;

@:allow(sorcery.core.interfaces.IEntityGroup)
interface IEntity extends IAgendaChild extends IEventSender
{
	var fullName(get, never) : String;
	var group(get, null) : IEntityGroup;
	var enabled(get, set) : Bool;
	var agenda(get, never) : IAgendaManager;

	function isWrapped():Bool;
	
	/**
	 * add child to an Entity
	 * @param child is any object implementing IEntityChild interface, basicly it is either IEntity or IComponent
	 * @return child 
	 */
	function addChild(child : IEntityChild) : IEntityChild;
	function removeChild(child : IEntityChild) : IEntityChild;
	function findChild(p_name : String) : IEntityChild;

	private function onAddToGroup(p_group : IEntityGroup) : Void;
	private function onRemoveFromGroup() : Void;

	@:allow(sorcery.core.interfaces.IEntityChild.addAgenda)
	@:allow(sorcery.core.interfaces.IEntityChild.removeAgenda)
	private function updateChildrenAgendaState():Void;
}

