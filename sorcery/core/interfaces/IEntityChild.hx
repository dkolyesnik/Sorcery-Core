/**
 * Created by Dmitriy Kolesnik on 26.08.2016.
 */
package sorcery.core.interfaces;
import sorcery.core.interfaces.ICore;

@:allow(sorcery.core.interfaces.IEntity)
@:allow(sorcery.core.interfaces.IEntityChildLink)
interface IEntityChild extends IAgendaChild
{
	var core(get, null):ICore;
	var parent(get, null) : IEntity;
	var name(get, null) : String;
	
	function isEntity():Bool;
	function isActivated():Bool;
	function isAddedToRoot() : Bool;
	
	@:noCompletion
	function onCachedByFullName():Void;
	
	function asEntity():IEntity;

	function setName(p_name : String) : IEntityChild;
	function castTo<T>(cl:Class<T>):T;

	function destroy() : Void;

	function hasAgenda(p_agenda:String):Bool;
	function addAgenda(p_agenda:String):IEntityChild;
	function removeAgenda(p_agenda:String):Void;

	//private function updateActiveState() : Void;

	//private function onActivatedByParent():Void;
	//private function onDeactivatedByParent():Void;
	private function activate():Void;
	private function deactivate():Void;
	
	private function addToParent(p_parent:IEntity):Void;
	private function removeFromParent():Void;
	
	private function addToRoot():Void;
	private function removeFromRoot():Void;
	
	private function onFocus():Void;
	private function onLostFocus():Void;
}

