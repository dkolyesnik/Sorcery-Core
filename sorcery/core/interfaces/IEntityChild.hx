/**
 * Created by Dmitriy Kolesnik on 26.08.2016.
 */
package sorcery.core.interfaces;
import sorcery.core.interfaces.ICore;

@:allow(sorcery.core.interfaces.IEntity)
@:allow(sorcery.core.interfaces.IEntityChildLink)
interface IEntityChild
{
	var core(get, null):ICore;
	var parent(get, null) : IEntity;
	var name(get, null) : String;
	
	function isEntity():Bool;
	function isActive() : Bool;
	function isFocused():Bool;
	function isActivatedByParent():Bool;
	function isAddedToRoot() : Bool;

	function setName(p_name : String) : IEntityChild;

	function destroy() : Void;

	function hasAgenda(p_agenda:String):Bool;
	function addAgenda(p_agenda:String):Void;
	function removeAgenda(p_agenda:String):Void;

	private function updateActiveState() : Void;

	private function onActivatedByParent():Void;
	private function onDeactivatedByParent():Void;
	
	private function onAddedToParent(p_parent : IEntity) : Void;
	private function onRemovedFromParent() : Void;

	private function onAddedToRoot() : Void;
	private function onRemovedFromRoot() : Void;

	private function setFocus(focus:Bool):Void;
	private function onFocus() : Void;  // called when we switch back to some agenda like onFocus in Screen and ScreenManager
	private function onLostFocus() : Void;  // called when we activate different agenda and this child is not a part of it
}

