/**
 * Created by Dmitriy Kolesnik on 02.08.2016.
 */
package sorcery.core;

import sorcery.core.BaseAgenda;
import sorcery.core.abstracts.Agenda;
import sorcery.core.abstracts.ComponentName;
import sorcery.core.abstracts.EntityName;
import sorcery.core.abstracts.FullName;
import sorcery.core.interfaces.IAgendaChild;
import sorcery.core.interfaces.IAgendaManager;
import sorcery.core.interfaces.ICloneable;
import sorcery.core.interfaces.IComponent;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.IEntity;
import haxecontracts.Contract;
import haxecontracts.HaxeContracts;

import sorcery.core.interfaces.IEntityChild;
import sorcery.core.interfaces.IEntityGroup;
import sorcery.core.interfaces.IEvent;
import sorcery.core.interfaces.INotificator;
import sorcery.core.interfaces.IPool;
import sorcery.core.interfaces.IPoolable;

using sorcery.core.tools.EntityTools;

/**
 * Basic object, can have children GameObjects and components
 */
@:allow(sorcery.core.interfaces.IEntityGroup)
@:access(sorcery.core.interfaces.IEntity)
@:access(sorcery.core.interfaces.IComponent)
class Entity extends sorcery.core.EntityChild implements IEntity implements IPoolable implements IAgendaManager implements HaxeContracts
{
	/**
	 * full name of the entity, unique identifier with consists of the groups's full name plus entity name
	 * it looks like #.group1.group2.name
	 * if entity is not added to root it's full name is null (? maybe it would be better to use something else ?)
	 */
	@:property
	public var fullName(get, never) : String;
	@:property
	public var group(get, null) : IEntityGroup;
	@:property
	public var agenda(get, never) : IAgendaManager;
	@:property
	public var enabled(get, set) : Bool;
	var _enabled = true;
	
	var _pool : IPool;

	var _isDestroyed = false;

	//CHILDREN
	var _children : Array<IEntityChild>;
	var _childrenByName : Map<String, IEntityChild>;

	var _activeAgendas:Array<String>;

	public function new(p_core:ICore)
	{
		Contract.requires(p_core != null);
		Contract.ensures(core == p_core && _isActivatedByParent == _isActive == _isAddedToRoot == _isFocused == _isDestroyed == false);

		super(p_core);
		_isDestroyed = false;
		_childrenByName = new Map();
		_children = [];
		_activeAgendas = [BaseAgenda.ALWAYS];
	}

	override public function setName(p_name:String):Void 
	{
		Contract.requires(EntityName.validate(p_name));
		
		super.setName(p_name);
	}
	
	// ==============================================================================
	// GETTERS & SETTERS
	// ==============================================================================
	function get_agenda() : IAgendaManager
	{
		return this;
	}

	function get_enabled():Bool
	{
		return _enabled;
	}

	function set_enabled(value : Bool) : Bool
	{
		if (_enabled == value)
		{
			return value;
		}

		_enabled = value;

		updateActiveState();
		return value;
	}

	function get_group():IEntityGroup
	{
		return group;
	}

	function get_fullName():String
	{
		Contract.ensures(Contract.result == null || FullName.validate(Contract.result));
		
		if (!isAddedToRoot())
			return null;
		if (name != CoreNames.ROOT)
			return group.fullName + "." + name;
		else
			return CoreNames.ROOT;
		
	}

	// ==============================================================================
	// METHODS
	// ==============================================================================
	public function isWrapped():Bool
	{
		return group != null ? group.name == name : false;
	}
	
	public function isGroup():Bool
	{
		return false;
	}
	
	override public function destroy() : Void
	{
		Contract.ensures(_children.length == 0);

		while (_children.length > 0)
		{
			_children.shift().destroy();
		}
		_childrenByName = new Map();

		if (_pool != null)
		{
			_pool.putBackObject(this);
		}
	}

	//CHILDREN

	public function addChild(child : IEntityChild) : IEntityChild
	{
		Contract.requires(child != null);
		Contract.ensures(EntityTools.checkWhetherChildCanBeAdded(this, child));
		Contract.ensures(_children.indexOf(child) >= 0);
		Contract.ensures(child.parent == this);
		
		if (child.isEntity())
		{
			var entity:IEntity = cast child;
			if (entity.name == null || entity.name == "")
			{
				entity.setName(core.factory.generateName());
			}
			if (entity.isWrapped())
				child = cast entity.group;
		}

		if (child.parent != null)
		{
			if (child.parent == this)
			{
				return child;
			}
			else
			{
				child.parent.removeChild(child);
			}
		}
		_children.push(child);
		child.onAddedToParent(this);
		updateChildrenAgendaState();
		return child;
	}

	public function removeChild(child : IEntityChild) : IEntityChild
	{
		Contract.requires(child != null);
		Contract.requires(child.parent == this);
		Contract.ensures(_children.indexOf(child) == -1);
		Contract.ensures(child.parent == null && child.isActivatedByParent() == false && child.isActive() == false && child.isAddedToRoot() == false);
		
		
		if (child.parent != this)
			return child;
			
		if (child.isEntity())
		{
			//get wrapper if entity is wrapped in a group
			var ent:IEntity = cast child;
			if (ent.isWrapped())
				ent = cast ent.group;
			child = ent;
		}
		_deactivateChild(child);
		child.onRemovedFromParent();
		if (_children.remove(child))
		{
			updateChildrenAgendaState();
			return child;
		}
		return child;
	}

	public function findChild(p_name:String):IEntityChild
	{
		Contract.requires(ComponentName.validate(p_name) || EntityName.validate(p_name));
 		
		return _childrenByName[p_name];
	}

	public function sendEvent(event : IEvent) : Void
	{
		Contract.requires(event != null);
		
		if (!isActive())
			return;

		core.notificator.sendEvent(event, fullName);
	}
	
	// ==============================================================================
	// IEntityChild
	// ==============================================================================
	override public function isEntity():Bool
	{
		return true;
	}
	
	override function updateActiveState() : Void
	{
		var isMustBeActive : Bool = enabled && isAddedToRoot() && _isActivatedByParent && parent.isActive();
		if (_isActive == isMustBeActive)
		{
			return;
		}

		_isActive = isMustBeActive;

		if (_children != null)
		{
			var i : Int = 0;
			var len : Int = _children.length;
			while (i < len)
			{
				_children[i].updateActiveState();
				i++;
			}
		}
	}
	
	override function onActivatedByParent():Void
	{
		_isActivatedByParent = true;
		if (parent.group != null && !isWrapped())
			onAddToGroup(parent.group);
		if (parent.isAddedToRoot())
			onAddedToRoot();
	}
	
	override function onDeactivatedByParent():Void
	{
		_isActivatedByParent = false;
		if (isAddedToRoot())
			onRemovedFromRoot();
		if (parent.group != null && parent.group == group)
			onRemoveFromGroup();
	}

	override function onAddedToRoot() : Void
	{
		Contract.ensures(_isAddedToRoot == true);
		
		if (isAddedToRoot())
			return;

		_isAddedToRoot = true;
		updateActiveState();
		var i : Int = 0;
		var len : Int = _children.length;
		while (i < len)
		{
			_children[i].onAddedToRoot();
			i++;
		}
	}

	override function onRemovedFromRoot() : Void
	{
		Contract.ensures(_isAddedToRoot == false);
		
		if (!isAddedToRoot())
			return;
			
		
		var i : Int = 0;
		var len : Int = _children.length;
		while (i < len)
		{
			_children[i].onRemovedFromRoot();
			i++;
		}
		core.root.clearCachedChild(fullName);
		_isAddedToRoot = false;
	}

	function onAddToGroup(p_group : IEntityGroup) : Void
	{
		Contract.requires(p_group != null && !(group != null && group != p_group));
		Contract.ensures(group == p_group && group.findEntity(name) == this);
		
		if (group == p_group)
			return;
		
		group = p_group;
		group.registerEntity(this);
		for (child in _children)
		{
			if (child.isEntity())
			{
				var ent:IEntity = cast child;
				ent.onAddToGroup(p_group);
			}
		}
	}

	function onRemoveFromGroup() : Void
	{
		Contract.ensures(group == null);
		
		for (child in _children)
		{
			if (child.isEntity())
			{
				var ent:IEntity = cast child;
				ent.onRemoveFromGroup();
			}
		}
		group.unregisterEntity(this);
		group = null;
	}

	// ==============================================================================
	// IAgendaManager
	// ==============================================================================
	public function getCurrentAgenda():String
	{
		return _activeAgendas[_activeAgendas.length - 1];
	}

	public function getActiveAgendas():Array<String>
	{
		return _activeAgendas.copy();
	}

	public function swap(p_agenda : Agenda) : Void
	{
		Contract.requires(Agenda.validate(p_agenda));
		Contract.ensures(getCurrentAgenda() == p_agenda && _activeAgendas.length == 2);
		
		_hideAll();
		show(p_agenda);
	}

	public function show(p_agenda : String) : Void
	{
		Contract.requires(Agenda.validate(p_agenda));
		Contract.ensures(getCurrentAgenda() == p_agenda); 
		
		if (p_agenda == getCurrentAgenda())
			return;
		_activeAgendas.remove(p_agenda);
		_activeAgendas.push(p_agenda);
		updateChildrenAgendaState();
	}

	public function hide(?p_agenda : String) : Void
	{
		Contract.requires(p_agenda == null || Agenda.validate(p_agenda));
		Contract.ensures(p_agenda != BaseAgenda.ALWAYS && getCurrentAgenda() != p_agenda);
		
		if (p_agenda == null)
			p_agenda = getCurrentAgenda();
		if (p_agenda == BaseAgenda.ALWAYS)
			return;
		_activeAgendas.remove(p_agenda);

		updateChildrenAgendaState();
	}

	public function hideAll():Void
	{
		Contract.ensures(getCurrentAgenda() == BaseAgenda.ALWAYS);
		
		_hideAll();
		updateChildrenAgendaState();
	}

	function _hideAll():Void
	{
		while (_activeAgendas.length > 1)
			_activeAgendas.pop();
	}

	function updateChildrenAgendaState():Void
	{
		var nameToChildForActivation = new Map<String, IEntityChild>();
		for (child in _children)
		{
			if (_checkIfChildMustBeActive(child))
				_addToMapToActivateLater(nameToChildForActivation, child);
			else
				_deactivateChild(child);
		}
		for (child in nameToChildForActivation)
		{
			_activateChild(child);
		}
	}

	function _activateChild(child:IEntityChild):Void
	{
		if (!child.isActivatedByParent())
		{
			if (child.isEntity())
			{
				var entity:IEntity = cast child;
				if (group != null && group.findEntity(entity.name) != null)
				{
					trace("Error adding entity with dublicated names, entity is destroyed");
					return;
				}
				_childrenByName[child.name] = child;
			}
			else
			{
				if (child.name != null)
				{
					if (_childrenByName.exists(child.name))
					{
						trace("Error adding component with dublicated names, component is destroyed");
						child.destroy();
						return;
					}
					_childrenByName[child.name] = child;
				}
			}
			child.onActivatedByParent();
		}
		//check if it must be focused
		if (child.hasAgenda(getCurrentAgenda()) && !child.isFocused())
		{
			child.setFocus(true);
		}

		return;
	}

	function _deactivateChild(child:IEntityChild) :Void
	{
		if (child.parent == null)
			return;

		if (child.isFocused())
			child.setFocus(false);

		if (child.name != null && _childrenByName.exists(child.name) && _childrenByName[child.name] == child)
			_childrenByName.remove(child.name);

		child.onDeactivatedByParent();
	}

	function _addToMapToActivateLater(map:Map<String, IEntityChild>, child:IEntityChild):Void
	{
		if (child.name == null)
		{
			_activateChild(child);
			return;
		}

		var childInMap = map[child.name];
		if (childInMap == null)
		{
			map[child.name] = child;
			return;
		}
		else
		{
			var i = _activeAgendas.length - 1;
			while (i >= 0)
			{
				var activeAgenda = _activeAgendas[i];
				if (child.hasAgenda(activeAgenda))
				{
					if (childInMap.hasAgenda(activeAgenda))
					{
						trace("Error: two childs with the same name in one agenda");
						return;
					}
					else
					{
						_deactivateChild(childInMap);
						map[child.name] = child;
						return;
					}
				}
				else
				{
					if (childInMap.hasAgenda(activeAgenda))
					{
						_deactivateChild(child);
						return;
					}
				}
			}
			_deactivateChild(child);
		}

	}

	function _checkIfChildMustBeActive(child:IEntityChild):Bool
	{
		for (activeAgenda in _activeAgendas)
		{
			if (child.hasAgenda(activeAgenda))
			{
				return true;
			}
		}
		return false;
	}

	// ==============================================================================
	// IPoolable
	// ==============================================================================
	public function setup(pool : IPool) : Void
	{
		_pool = pool;
		_isDestroyed = false;
	}

	public function clean() : Void
	{
		_isDestroyed = true;
	}

	public function clone() : ICloneable
	{
		return new Entity(core);
	}
}

