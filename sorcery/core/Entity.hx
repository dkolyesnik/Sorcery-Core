/**
 * Created by Dmitriy Kolesnik on 02.08.2016.
 */
package sorcery.core;

import sorcery.core.BaseAgenda;
import sorcery.core.abstracts.Agenda;
import sorcery.core.abstracts.ComponentName;
import sorcery.core.abstracts.EntityName;
import sorcery.core.abstracts.FullName;
import sorcery.core.interfaces.IAgendaManager;
import sorcery.core.interfaces.ICloneable;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.IEntity;
import haxecontracts.Contract;
import haxecontracts.HaxeContracts;

import sorcery.core.interfaces.IEntityChild;
import sorcery.core.interfaces.IEntityGroup;
import sorcery.core.interfaces.IEvent;
import sorcery.core.interfaces.IPool;
import sorcery.core.interfaces.IPoolable;

using sorcery.core.tools.EntityTools;
using sorcery.core.utils.ArrayUtils;
/**
 * Basic object, can have children GameObjects and components
 */
@:allow(sorcery.core.interfaces.IEntityGroup)
@:access(sorcery.core.interfaces.IEntity)
@:access(sorcery.core.interfaces.IEntityChild)
@:access(sorcery.core.interfaces.IComponent)
class Entity extends sorcery.core.EntityChild implements IEntity implements IPoolable implements IAgendaManager implements HaxeContracts
{
	@:noCompletion
	inline static var DUPLICATED_CHILD_NAME_EXCEPTIOM = "Error adding child with dublicated names";
	
	public var group(get, null) : IEntityGroup;
	public var agenda(get, never) : IAgendaManager;
	@:isVar
	public var enabled(get, set) : Bool = true;

	var _pool : IPool;

	var _isDestroyed = false;

	//CHILDREN
	var _children : Array<IEntityChild>;
	var _childrenByName : Map<String, IEntityChild>;

	var _activeAgendas:Array<String>;

	public function new(p_core:ICore)
	{
		Contract.requires(p_core != null);
		Contract.ensures(core == p_core && _isActivated == _isAddedToRoot == _isDestroyed == false);

		super(p_core);
		_isDestroyed = false;
		_childrenByName = new Map();
		_children = [];
		_activeAgendas = [BaseAgenda.ALWAYS];
	}

	override public function setName(p_name:String):IEntityChild
	{
		Contract.requires(EntityName.validate(p_name));

		return super.setName(p_name);
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
		return enabled;
	}

	function set_enabled(value : Bool) : Bool
	{
		if (enabled == value)
		{
			return value;
		}

		enabled = value;

		return value;
	}

	function get_group():IEntityGroup
	{
		return group;
	}

	override function get_fullName():FullName
	{
		if (_isAddedToRoot)
			return group.fullName + "." + name;
		else
			return null;
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
	
	public function iterator():Iterator<IEntityChild>
	{
		return _children.iterator();
	}

	public function addChild(child : IEntityChild) : IEntityChild
	{
		Contract.requires(child != null);
		Contract.ensures(EntityTools.checkWhetherChildCanBeAdded(this, child));
		Contract.ensures(_children.indexOf(child) >= 0);
		Contract.ensures(child.parent == this);

		//adding as not active child
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
		child.addToParent(this);

		//update useByAgendaCound
		for (agendaName in _activeAgendas)
			child.activateByAgenda(agendaName);

		if (child.getUseByAgendaCount() > 0)
		{
			_addChildToHierarchy(child);
			//adding to root if this entity is added to root and child is used by agenda
			if (_isAddedToRoot)
			{
				child.addToRoot();

				child.activate();

				if (child.hasAgenda(getCurrentAgenda()))
					child.onFocus();
			}
		}
		return child;
	}

	function _addChildToHierarchy(child:IEntityChild):Void
	{
		if (child.isEntity())
		{
			var entity:IEntity = cast child;
			if (_childrenByName.exists(child.name))
			{
				core.error(DUPLICATED_CHILD_NAME_EXCEPTIOM);
				return;
			}
			_childrenByName[child.name] = child;

			if (group != null)
				entity.addToGroup(group);
		}
		else
		{
			if (child.name != null)
			{
				if (_childrenByName.exists(child.name))
				{
					core.error(DUPLICATED_CHILD_NAME_EXCEPTIOM);
					return;
				}
				_childrenByName[child.name] = child;
			}
		}

	}

	public function removeChild(child : IEntityChild) : IEntityChild
	{
		Contract.requires(child != null);
		Contract.ensures(_children.indexOf(child) == -1);
		Contract.ensures(child.parent == null && child.isActivated() == false && child.isAddedToRoot() == false);

		if (child.parent == this)
		{
			var childEntity:IEntity;
			if (child.isEntity())
			{
				//get wrapper if entity is wrapped in a group
				childEntity = cast child;
				if (childEntity.isWrapped())
					childEntity = cast childEntity.group;
				child = childEntity;
			}
			if (_isAddedToRoot)
			{
				if (child.isAddedToRoot())
				{
					if (child.isActivated())
					{
						if (child.hasAgenda(getCurrentAgenda()))
							child.onLostFocus();
						child.deactivate();
					}
					child.removeFromRoot();
				}
			}
			_removeChildFromHierarchy(child);
			child.removeFromParent();
			_children.remove(child);
		}

		return child;
	}

	function _removeChildFromHierarchy(child:IEntityChild)
	{
		if (child.name != null && _childrenByName.exists(child.name) && _childrenByName[child.name] == child)
		{
			_childrenByName.remove(child.name);
			if (child.isEntity())
			{
				var childEntity:IEntity = cast child;
				if (childEntity != null)
					childEntity.removeFromGroup();
			}
		}
	}
	
	public function removeAllChildren():Void{
		//OPT
		while (_children.length > 0)
		{
			removeChild(_children.last());
		}
	}

	public function findChild(p_name:String):IEntityChild
	{
		Contract.requires(ComponentName.validate(p_name) || EntityName.validate(p_name));

		return _childrenByName[p_name];
	}

	public function sendEvent(event : IEvent) : Void
	{
		Contract.requires(event != null);

		if (_isAddedToRoot)
			core.notificator.sendEvent(event, fullName);
	}

	// ==============================================================================
	// IEntityChild
	// ==============================================================================
	override public function isEntity():Bool
	{
		return true;
	}
	
	override public function asEntity():IEntity
	{
		return this;
	}
	
	override function activate():Void
	{
		//TODO optimize
		//TODO should it call lost focus for children without current agenda?
		//TODO should it call onActivate before or after children activation?
		_isActivated = true;
		var focusedChildren = [];
		var curAgenda = getCurrentAgenda();
		for (child in _children)
		{
			if (child.isAddedToRoot())
			{
				child.activate();
				if (child.hasAgenda(curAgenda))
					focusedChildren.push(child);
			}
		}
		for (child in focusedChildren)
			child.onFocus();
	}

	override function deactivate():Void
	{
		//TODO optimize
		//TODO should it call lost focus for children without current agenda?
		//TODO should it call onDeactivate before or after children deactivation?
		for (child in _children)
			if (child.hasAgenda(getCurrentAgenda()))
				child.onLostFocus();

		for (child in _children)
			if (child.isActivated())
				child.deactivate();
		_isActivated = false;
	}

	override function addToRoot():Void
	{
		Contract.ensures(_isAddedToRoot == true);

		_isAddedToRoot = true;

		for (child in _children)
			if (child.getUseByAgendaCount() > 0)
				child.addToRoot();
	}

	override function removeFromRoot():Void
	{
		Contract.ensures(_isAddedToRoot == false);

		for (child in _children)
			if (child.isAddedToRoot())
				child.removeFromRoot();

		if(_isCachedByFullName)
			core.root.clearCachedChild(fullName);
			
		_isAddedToRoot = false;

		if (!isWrapped())
			removeFromGroup();
	}

	function addToGroup(p_group : IEntityGroup) : Void
	{
		Contract.requires(p_group != null && !(group != null && group != p_group));
		Contract.ensures(group == p_group && group.findEntity(name) == this);

		if (group == p_group)
			return;

		group = p_group;
		group.registerEntity(this);

		var childEntity:IEntity;
		for (child in _children)
		{
			if (child.isEntity() && child.getUseByAgendaCount() > 0)
			{
				childEntity = cast child;
				childEntity.addToGroup(group);
			}
		}
	}

	function removeFromGroup() : Void
	{
		Contract.ensures(group == null);

		if (group != null)
		{
			var childEntity:IEntity;
			for (child in _children)
			{
				if (child.isEntity() && child.getUseByAgendaCount() > 0)
				{
					childEntity = cast child;
					childEntity.removeFromGroup();
				}
			}
			group.unregisterEntity(this);
			group = null;
		}
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

	public function isAgendaActive(p_agenda:String):Bool
	{
		return _activeAgendas.indexOf(p_agenda) >= 0;
	}

	public function swap(p_agenda : Agenda) : IAgendaManager
	{
		Contract.requires(Agenda.validate(p_agenda));
		Contract.ensures(getCurrentAgenda() == p_agenda && _activeAgendas.length == 2);

		hideAll();
		show(p_agenda);
		return this;
	}

	public function show(p_agenda : String) : IAgendaManager
	{
		Contract.requires(Agenda.validate(p_agenda));
		Contract.ensures(getCurrentAgenda() == p_agenda);

		if (p_agenda == getCurrentAgenda())
			return this;

		//TODO optimize

		var prevAgenda = getCurrentAgenda();
		var newAgenda = p_agenda;

		//lost focus
		if (_isAddedToRoot && _isActivated)
		{
			for (child in _children)
			{
				if (child.hasAgenda(prevAgenda) && !child.hasAgenda(newAgenda))
					child.onLostFocus();
			}
		}

		if (_activeAgendas.remove(newAgenda))
		{
			//this agend was already active
			_activeAgendas.push(newAgenda);
			if (_isAddedToRoot && _isActivated)
				for (child in _children)
					if (child.hasAgenda(newAgenda))
						child.onFocus();
		}
		else
		{
			//agenda was not active
			_activeAgendas.push(newAgenda);

			if (_isAddedToRoot)
			{
				var selected = [];
				for (child in _children)
				{
					if (child.activateByAgenda(newAgenda))
					{
						_addChildToHierarchy(child);
						selected.push(child);
					}
				}
				for (child in selected)
					child.addToRoot();
				if (_isActivated)
				{
					for (child in selected)
						child.activate();

					for (child in _children)
						if (child.hasAgenda(newAgenda))
							child.onFocus();
				}
			}
			else
			{
				for (child in _children)
					if (child.activateByAgenda(newAgenda))
						_addChildToHierarchy(child);
			}
		}
		return this;
	}

	public function hide(?p_agenda : String) : IAgendaManager
	{
		//TODO NEW
		Contract.requires(p_agenda == null || Agenda.validate(p_agenda));
		Contract.ensures(p_agenda != BaseAgenda.ALWAYS && getCurrentAgenda() != p_agenda);

		if (p_agenda == null)
			p_agenda = getCurrentAgenda();
		else if (_activeAgendas.indexOf(p_agenda) < 0)
			return this;

		// you can't hide ALWAYS agenda
		if (p_agenda != BaseAgenda.ALWAYS)
		{
			if (_isAddedToRoot)
			{
				var isFocusedAgenda = p_agenda == getCurrentAgenda();
				var selected:Array<IEntityChild> = [];
				if (_isActivated)
				{
					for (child in _children)
					{
						if (isFocusedAgenda && child.hasAgenda(p_agenda))
							child.onLostFocus();

						if (child.deactivateByAgends(p_agenda))
							selected.push(child);
					}
					for (child in selected)
						child.deactivate();

					for (child in selected)
						child.removeFromRoot();
				}
				else
				{
					for (child in _children)
					{
						if (child.deactivateByAgends(p_agenda))
						{
							child.removeFromRoot();
							selected.push(child);
						}
					}
				}

				for (child in selected)
					_removeChildFromHierarchy(child);

				_activeAgendas.remove(p_agenda);

				if (_isActivated && isFocusedAgenda)
				{
					var curAgenda = getCurrentAgenda();
					//need to focus another agenda
					for (child in _children)
						if (child.hasAgenda(curAgenda))
							child.onFocus();
				}
			}
			else
			{
				for (child in _children)
					if (child.deactivateByAgends(p_agenda))
						_removeChildFromHierarchy(child);

				_activeAgendas.remove(p_agenda);
			}
		}
		return this;
	}

	/**
	 * hide all agendas except p_agenda if not null
	 * @param	p_agenda
	 */
	public function hideAll(?p_agenda : String):IAgendaManager
	{
		Contract.ensures(getCurrentAgenda() == BaseAgenda.ALWAYS);

		var hasExceptAgenda = !(p_agenda == null || p_agenda == BaseAgenda.ALWAYS || _activeAgendas.indexOf(p_agenda) < 0);

		if (_isAddedToRoot)
		{
			var selected = [];
			if (_isActivated)
			{
				var curAgenda = getCurrentAgenda();
				for (child in _children)
					if (child.hasAgenda(curAgenda))
						child.onLostFocus();

				for (child in _children)
				{
					child.resetUseByAgendaCount();
					child.activateByAgenda(BaseAgenda.ALWAYS);
					if (hasExceptAgenda)
						child.activateByAgenda(p_agenda);

					if (child.getUseByAgendaCount() == 0)
					{
						if (child.isAddedToRoot())
						{
							if (child.isActivated())
								child.deactivate();
							selected.push(child);
						}
					}
				}

				for (child in selected)
					child.removeFromRoot();
			}
			else
			{
				for (child in _children)
				{
					child.resetUseByAgendaCount();
					child.activateByAgenda(BaseAgenda.ALWAYS);
					if (hasExceptAgenda)
						child.activateByAgenda(p_agenda);
					if (child.getUseByAgendaCount() == 0)
					{
						if (child.isAddedToRoot())
							child.removeFromRoot();

						selected.push(child);
					}
				}
			}

			for (child in selected)
				_removeChildFromHierarchy(child);

			while (_activeAgendas.length > 1)
				_activeAgendas.pop();
			if (hasExceptAgenda)
				_activeAgendas.push(p_agenda);

			for (child in _children)
				if (hasExceptAgenda && child.hasAgenda(p_agenda) || child.hasAgenda(BaseAgenda.ALWAYS))
					child.onFocus();
		}
		else
		{
			//Entity is not added to root, so only remove from hierarchy
			for (child in _children)
			{
				if (child.getUseByAgendaCount() > 0)
				{
					child.resetUseByAgendaCount();
					child.activateByAgenda(BaseAgenda.ALWAYS);
					if (hasExceptAgenda)
						child.activateByAgenda(p_agenda);
					if (child.getUseByAgendaCount() == 0)
						_removeChildFromHierarchy(child);
				}
			}
		}
		return this;
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

