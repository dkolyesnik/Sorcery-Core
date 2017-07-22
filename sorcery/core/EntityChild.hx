package sorcery.core;
import sorcery.core.BaseAgenda;
import sorcery.core.abstracts.Agenda;
import sorcery.core.abstracts.FullName;
import sorcery.core.abstracts.Path;
import sorcery.core.interfaces.IEntity;
import haxecontracts.Contract;
import haxecontracts.HaxeContracts;
import sorcery.core.macros.interfaces.IInjectArguments;

import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.IEntityChild;

/**
 * ...
 * @author Dmitriy Kolyesnik
 */
class EntityChild implements IEntityChild implements HaxeContracts implements IInjectArguments
{
	//var _isActivatedByParent = false;
	var _isActivated = false;
	var _isAddedToRoot = false;
	var _isFocused = false;
	var _isCachedByFullName = false;
	var _agendas:Map<String, Bool>;
	var _useByAgendaCount = 0;
	
	private function new(p_core:ICore)
	{
		core = p_core;
	}

	/* INTERFACE bgcore.interfaces.IEntityChild */
	public var core(get, null):ICore;
	public var parent(get, null):IEntity;
	public var name(get, null):String;
	/**
	 * full name of the entity, unique identifier with consists of the groups's full name plus entity name
	 * it looks like #.group1.group2.name
	 * if entity is not added to root it's full name is null (? maybe it would be better to use something else ?)
	 */
	public var fullName(get, never) : FullName;

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
	
	function get_fullName():FullName
	{
		if (_isAddedToRoot)
			return parent.fullName + ":" + name;
		else
			return null;
	}

	// ==============================================================================
	// METHODS
	// ==============================================================================
	public function isEntity():Bool
	{
		return false;
	}

	public function isActivated():Bool
	{
		return _isActivated;
	}

	public function isAddedToRoot() : Bool
	{
		return _isAddedToRoot;
	}
	
	@:noCompletion
	public function onCachedByFullName():Void
	{
		_isCachedByFullName = true;
	}
	
	public function asEntity():IEntity
	{
		return null;
	}
	
	//public function castTo<T>(cl:Class<T>):T
	//{
		//if (Std.is(this, cl))
			//return cast this;
		//else	
			//return null;
	//}

	public function setName(p_name:String):IEntityChild
	{
		Contract.requires(p_name != Path.ROOT && p_name != "");
		Contract.requires( parent == null || name == p_name);
		
		if (parent == null)
		{
			name = p_name;
		}
		
		return this;
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

	public function addAgenda(p_agenda:String):IEntityChild
	{
		//TODO adding agenda when added to parent
		Contract.requires(Agenda.validate(p_agenda));
		Contract.ensures(_agendas.exists(p_agenda));
		
		if (parent == null)
		{
			if (_agendas == null)
			_agendas = new Map();

			if (!_agendas.exists(p_agenda))
			{
				_agendas[p_agenda] = true;
			}
		}
		
		return this;
	}

	public function removeAgenda(p_agenda:String):Void
	{
		//TODO removing agenda when added to parent
		Contract.requires(Agenda.validate(p_agenda));
		Contract.ensures(_agendas == null || !_agendas.exists(p_agenda));
		
		if (parent == null)
		{
			if (_agendas != null) 
			{
				_agendas.remove(p_agenda);
			}
		}
	}
	
	function getUseByAgendaCount():Int
	{
		return _useByAgendaCount;
	}
	
	function resetUseByAgendaCount():Void
	{
		_useByAgendaCount = 0;
	}
	
	/**
	 * called when agenda is activated, check if it need to increase use count
	 * @return true if has agenda and use count is increased
	 */
	function activateByAgenda(p_agenda:Agenda):Bool
	{
		Contract.requires(Agenda.validate(p_agenda));
		
		if (_agendas == null)
		{
			if (p_agenda == BaseAgenda.ALWAYS)
			{
				_useByAgendaCount++;
				return true;
			}
			else
			{
				return false;
			}
		}
		
		if (_agendas.exists(p_agenda))
		{
			_useByAgendaCount++;
			return true;
		}
		else
			return false;
	}
	
	/**
	 * called when agenda is deactivated, decrease use count if has this agenda
	 * @return true if use count is decreased to 0 and we need to deactivate child
	 */
	function deactivateByAgends(p_agenda:Agenda):Bool
	{
		Contract.requires(Agenda.validate(p_agenda));
		
		if (_agendas == null)
		{
			if (p_agenda == BaseAgenda.ALWAYS)
			{
				_useByAgendaCount--;
				return true;
			}
			else
			{
				return false;
			}
		}
		
		if (_agendas.exists(p_agenda))
		{
			_useByAgendaCount--;
			return _useByAgendaCount == 0;
		}	
		else
			return false;
	}
	
	@:noCompletion
	function activate():Void
	{
		_isActivated = true;
	}
	@:noCompletion
	function deactivate():Void
	{
		_isActivated = false;
	}
	@:noCompletion
	function addToParent(p_parent:IEntity):Void
	{
		Contract.requires(p_parent != null);
		
		parent = p_parent;
	}
	@:noCompletion
	function removeFromParent():Void
	{
		Contract.ensures(parent == null);
		
		_useByAgendaCount = 0;
		parent = null;
	}
	
	@:noCompletion
	function addToRoot():Void
	{
		_isAddedToRoot = true;
	}
	@:noCompletion
	function removeFromRoot():Void
	{
		_isAddedToRoot = false;
	}
	
	
	//function onActivatedByParent():Void
	//{
		//_isActivatedByParent = true;
	//}
	//
	//function onDeactivatedByParent():Void
	//{
		//_isActivatedByParent = false;
	//}
	@:noCompletion
	function onFocus():Void
	{

	}
	@:noCompletion
	function onLostFocus():Void
	{

	}

}