package sorcery.core;
import sorcery.core.BaseAgenda;
import sorcery.core.CoreNames;
import sorcery.core.abstracts.Agenda;
import sorcery.core.interfaces.IEntity;
import haxecontracts.Contract;
import haxecontracts.HaxeContracts;

import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.IEntityChild;

/**
 * ...
 * @author Dmitriy Kolyesnik
 */
class EntityChild implements IEntityChild implements HaxeContracts
{
	var _isActive = false;
	var _isActivatedByParent = false;
	var _isAddedToRoot = false;
	var _isFocused = false;
	var _agendas:Map<String, Bool>;
	
	private function new(p_core:ICore)
	{
		core = p_core;
	}

	/* INTERFACE bgcore.interfaces.IEntityChild */
	public var core(get, null):ICore;
	public var parent(get, null):IEntity;
	public var name(get, null):String;

	// ==============================================================================
	// GETTERS & SETTERS
	// ==============================================================================
	function get_core():ICore
	{
		return core;
	}

	function get_parent():IEntity
	{
		return parent;
	}

	function get_name():String
	{
		return name;
	}

	// ==============================================================================
	// METHODS
	// ==============================================================================
	public function isEntity():Bool
	{
		return false;
	}

	public function isActive():Bool
	{
		return _isActive;
	}
	
	public function isActivatedByParent():Bool
	{
		return _isActivatedByParent;
	}

	public function isFocused():Bool
	{
		return _isFocused;
	}

	public function isAddedToRoot() : Bool
	{
		return _isAddedToRoot;
	}

	public function setName(p_name:String):Void
	{
		Contract.requires(p_name != CoreNames.ROOT && p_name != "");
		Contract.requires( parent == null || name == p_name);
		
		if (parent == null)
		{
			name = p_name;
		}
	}

	public function destroy():Void
	{

	}

	public function hasAgenda(p_agenda:String):Bool
	{
		Contract.requires(Agenda.validate(p_agenda));
		
		if (_agendas == null)
			return p_agenda == BaseAgenda.ALWAYS;

		return _agendas.exists(p_agenda);
	}

	public function addAgenda(p_agenda:String):Void
	{
		Contract.requires(Agenda.validate(p_agenda));
		Contract.ensures(_agendas.exists(p_agenda));
		
		if (_agendas == null)
			_agendas = new Map();

		if (!_agendas.exists(p_agenda))
		{
			_agendas[p_agenda] = true;
			if (parent != null)
				parent.updateChildrenAgendaState();
		}
	}

	public function removeAgenda(p_agenda:String):Void
	{
		Contract.requires(Agenda.validate(p_agenda));
		Contract.ensures(_agendas == null || !_agendas.exists(p_agenda));
		
		if (_agendas != null && _agendas.remove(p_agenda))
		{
			if (parent != null)
				parent.updateChildrenAgendaState();
		}
	}

	function updateActiveState():Void
	{

	}
	
	function onActivatedByParent():Void
	{
		_isActivatedByParent = true;
	}
	
	function onDeactivatedByParent():Void
	{
		_isActivatedByParent = false;
	}

	function onAddedToParent(p_parent:IEntity):Void
	{
		Contract.requires(p_parent != null);
		
		parent = p_parent;
	}

	function onRemovedFromParent():Void
	{
		Contract.ensures(parent == null);
		
		parent = null;
	}

	function onAddedToRoot():Void
	{

	}

	function onRemovedFromRoot():Void
	{

	}

	function setFocus(focus:Bool):Void
	{
		Contract.ensures(focus == _isFocused);
		
		if (_isFocused == focus)
			return;
		_isFocused = focus;
		if (_isFocused)
			onFocus();
		else
			onLostFocus();
	}

	function onFocus():Void
	{

	}

	function onLostFocus():Void
	{

	}

}