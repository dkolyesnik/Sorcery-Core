/**
 * Created by Dmitriy Kolesnik on 02.08.2016.
 */
package sorcery.core;

import sorcery.core.abstracts.Agenda;
import sorcery.core.abstracts.EntityName;
import sorcery.core.abstracts.FullName;
import sorcery.core.abstracts.Path;
import sorcery.core.interfaces.IAgendaChild;
import sorcery.core.interfaces.IAgendaManager;
import sorcery.core.interfaces.ICloneable;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.IEntity;
import sorcery.core.interfaces.IEntityChild;
import sorcery.core.interfaces.IEntityGroup;
import sorcery.core.interfaces.IEvent;
import sorcery.core.interfaces.IPool;
import sorcery.core.interfaces.IPoolable;
import haxecontracts.Contract;
import haxecontracts.HaxeContracts;

/**
 * class that represens  group of objects, groups have separate hierarchy
 */
@:access(sorcery.core.interfaces.IEntity)
class EntityGroup implements IEntityGroup implements IEntity implements HaxeContracts
{
	var _entitiesByName = new Map<String, IEntity>();
	var _wrappedEntity:IEntity;

	public var name(get, null) : String;
	public var fullName(get, never) : String;
	public var parentGroup(get, null) : IEntityGroup;
	public var group(get, null) : IEntityGroup;
	public var enabled(get, set) : Bool;
	public var agenda(get, never) : IAgendaManager;
	public var core(get, null):ICore;
	public var parent(get, null) : IEntity;

	public function new(entity:IEntity)
	{
		Contract.requires(entity != null);
		
		_wrappedEntity = entity;
		if (entity.name == null || entity.name == "")
		{
			trace("Warning: group must have a name");
			entity.setName(core.factory.generateName());
		}
		entity.addToGroup(this);
	}

	// ==============================================================================
	// IEntityGroup
	// ==============================================================================
	public function findEntity(p_name : String) : IEntity
	{
		Contract.requires(EntityName.validate(p_name) || (p_name == Path.ROOT && _wrappedEntity.name == Path.ROOT));
		
		return _entitiesByName[p_name];
	}

	@:allow(sorcery.core.interfaces.IEntity)
	function registerEntity(p_entity : IEntity) : Void
	{
		Contract.requires(p_entity != null, "Entity must not be null");
		Contract.requires((_wrappedEntity.name == Path.ROOT && p_entity == _wrappedEntity) || EntityName.validate(p_entity.name), "Invalid entity name");
		
		if (_entitiesByName.exists(p_entity.name))
		{
			core.error(Entity.DUPLICATED_CHILD_NAME_EXCEPTIOM);
		}
		
		_entitiesByName[p_entity.name] = p_entity;
	}

	@:allow(sorcery.core.interfaces.IEntity)
	function unregisterEntity(p_entity : IEntity) : Void
	{
		Contract.requires(p_entity != null && EntityName.validate(p_entity.name));
		
		_entitiesByName.remove(p_entity.name);
	}
	// ==============================================================================
	// IEntity
	// ==============================================================================
	public function isEntity():Bool
	{
		return true;
	}

	public function isWrapped():Bool
	{
		return false;
	}
	
	public function isGroup():Bool
	{
		return true;
	}
	
	public function asEntity():IEntity
	{
		return this;
	}
	
	public function onCachedByFullName():Void
	{
		_wrappedEntity.onCachedByFullName();
	}
	
	public function castTo<T>(cl:Class<T>):T
	{
		if (Std.is(this, cl))
			return cast this;
		else
			return null;
	}

	public function setName(p_name : String) : IEntityChild
	{
		Contract.requires(EntityName.validate(p_name));
		
		return _wrappedEntity.setName(p_name);
	}

	public function isActivated():Bool
	{
		return _wrappedEntity.isActivated();
	}

	function activate():Void
	{
		_wrappedEntity.activate();
	}
	
	function deactivate():Void
	{
		_wrappedEntity.deactivate();
	}
	
	function addToParent(p_parent : IEntity) : Void
	{
		_wrappedEntity.addToParent(p_parent);
	}

	function removeFromParent() : Void
	{
		_wrappedEntity.removeFromParent();
	}
	
	function addToGroup(p_group : IEntityGroup) : Void
	{
		Contract.requires(p_group != null && !(parentGroup != null && parentGroup != p_group));
		
		if (parentGroup == p_group)
			return;
		
		parentGroup = p_group;
		parentGroup.registerEntity(this);
	}

	function removeFromGroup() : Void
	{
		Contract.ensures(parentGroup == null);
		
		if(parentGroup != null)
			parentGroup.unregisterEntity(this);
		parentGroup = null;
	}

	function addToRoot() : Void
	{
		addToGroup(parent.group);
		_wrappedEntity.addToRoot();
	}

	function removeFromRoot() : Void
	{
		_wrappedEntity.removeFromRoot();
		removeFromGroup();
	}

	public function destroy() : Void
	{
		_wrappedEntity.destroy();
	}

	public function isAddedToRoot() : Bool
	{
		return _wrappedEntity.isAddedToRoot();
	}
	
	public function iterator():Iterator<IEntityChild>
	{
		return _wrappedEntity.iterator();
	}

	public function addChild(child : IEntityChild) : IEntityChild
	{
		return _wrappedEntity.addChild(child);
	}

	public function removeChild(child : IEntityChild) : IEntityChild
	{
		return _wrappedEntity.removeChild(child);
	}
	
	public function removeAllChildren():Void
	{
		_wrappedEntity.removeAllChildren();
	}

	public function findChild(p_name : String) : IEntityChild
	{
		Contract.requires(p_name != null && p_name != "");
		
		return _wrappedEntity.findChild(p_name);
	}

	public function sendEvent(event:IEvent):Void
	{
		_wrappedEntity.sendEvent(event);
	}

	public function addAgenda(p_agenda:String):IEntityChild
	{
		Contract.requires(Agenda.validate(p_agenda));
		
		_wrappedEntity.addAgenda(p_agenda);
		
		return this;
	}

	public function removeAgenda(p_agenda:String):Void
	{
		Contract.requires(Agenda.validate(p_agenda));
		
		_wrappedEntity.removeAgenda(p_agenda);
	}

	public function hasAgenda(p_agenda:String):Bool
	{
		Contract.requires(Agenda.validate(p_agenda));
		
		return _wrappedEntity.hasAgenda(p_agenda);
	}
	
	function getUseByAgendaCount():Int
	{
		return _wrappedEntity.getUseByAgendaCount();
	}
	
	function resetUseByAgendaCount():Void
	{
		_wrappedEntity.resetUseByAgendaCount();
	}
	
	function activateByAgenda(p_agenda:Agenda):Bool
	{
		return _wrappedEntity.activateByAgenda(p_agenda);
	}
	
	function deactivateByAgends(p_agenda:Agenda):Bool
	{
		return _wrappedEntity.deactivateByAgends(p_agenda);
	}

	function onFocus() : Void
	{
		_wrappedEntity.onFocus();
	}

	function onLostFocus() : Void
	{
		_wrappedEntity.onLostFocus();
	}

	// ==============================================================================
	// Getters & Setters
	// ==============================================================================
	function get_name():String
	{
		return _wrappedEntity.name;
	}

	function get_fullName():String
	{
		Contract.ensures(Contract.result == null || FullName.validate(Contract.result));
		
		if (!_wrappedEntity.isAddedToRoot())
			return null;
		return parentGroup.fullName + "." + name;
	}

	function get_enabled():Bool
	{
		return _wrappedEntity.enabled;
	}

	function set_enabled(value:Bool):Bool
	{
		return _wrappedEntity.enabled = value;
	}

	function get_agenda():IAgendaManager
	{
		return _wrappedEntity.agenda;
	}

	function get_core():ICore
	{
		return _wrappedEntity.core;
	}

	function get_parent():IEntity
	{
		return _wrappedEntity.parent;
	}

	function get_group():IEntityGroup
	{
		return parentGroup;
	}

	function get_parentGroup():IEntityGroup
	{
		return parentGroup;
	}
}

