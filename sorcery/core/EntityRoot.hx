/**
 * Created by Dmitriy Kolesnik on 03.08.2016.
 */
package sorcery.core;

import sorcery.core.abstracts.Path;
import sorcery.core.abstracts.EntityName;
import sorcery.core.abstracts.FullName;
import sorcery.core.interfaces.IComponent;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.IEntity;
import sorcery.core.interfaces.IEntityChild;
import sorcery.core.interfaces.IEntityGroup;
import sorcery.core.interfaces.IEntityRoot;
import sorcery.core.interfaces.IEvent;
import sorcery.core.interfaces.INodeIterator;
import sorcery.core.interfaces.ISystem;
import sorcery.core.interfaces.ISystemNode;
import sorcery.core.misc.NodeList;
import haxecontracts.Contract;
import haxecontracts.HaxeContracts;
import sorcery.core.abstracts.Path.*;
import sorcery.macros.Nullsafety.*;

class EntityRoot extends EntityGroup implements IEntityRoot implements HaxeContracts
{
	var childrenByFullName = new Map<FullName, IEntityChild>();
	var nodesByName = new Map<String, NodeList>();
	
	
	public function new(p_core:ICore)
	{
		Contract.requires(p_core != null);
		Contract.ensures(name == ROOT);
		
		_wrappedEntity = new EntityForRoot(p_core);
		_wrappedEntity.setName(ROOT);
		super(_wrappedEntity);
	}
	
	//TODO move nodes to Core
	public function getNodes(nodeName:String):NodeList
	{
		return _findOrCreateNodeList(nodeName);
	}
	
	public function addNode(node:ISystemNode):Void
	{
		var nodes = _findOrCreateNodeList(node.nodeName);
		nodes.add(node);
	}
	
	function _findOrCreateNodeList(nodeName:String):NodeList
	{
		var nodes = nodesByName[nodeName];
		if (nodes == null)
		{
			nodes = new NodeList();
			nodesByName[nodeName] = nodes;
		}
		return nodes;
	}
	
	public function removeNode(node:ISystemNode):Void
	{
		var nodes = nodesByName[node.nodeName];
		if (nodes != null)
		{
			nodes.remove(node);
		}
	}
	
	public function findChildByFullName(p_name:FullName):IEntityChild
	{
		Contract.requires(FullName.validate(p_name));
		
		var child = childrenByFullName[p_name];
		if (child != null)
		{
			//TODO mark as cached maybe?
			return child;
		}
		else
		{
			child = _findChildByFullName(p_name);
			if (child != null)
			{
				childrenByFullName[p_name] = child;
				child.onCachedByFullName();
				return child;
			}
		}
		return null;
	}

	function _findChildByFullName(p_name:FullName):IEntityChild
	{
		if (p_name == FullName.UNDEFINED || p_name == "")
			return null;
		if (p_name == ROOT)
			return this;

		//TODO optimize
		//var groupsAr = p_name.split(".");
		var entityName = "";
		var entity:IEntity;
		var gr:IEntityGroup = this;
		var n:String = p_name;
		if (n.charAt(1) == TO_COMPONENT)
			return findChild(n.substr(2));
			
		for (i in 2...n.length)
		{
			var c = n.charAt(i);
			if (c == TO_GROUP)
			{
				entity = gr.findEntity(entityName);
				if (entity == null)
					return null;
				if (entity.isGroup())
					gr = cast entity;
				else
					return entity;
				entityName = "";
			}
			else if (c == TO_COMPONENT)
			{
				entity = gr.findEntity(entityName);
				return safeGet(entity.findChild(n.substr(i + 1)));
			}
			else
			{
				entityName += c;
			}
		}
		
		return gr.findEntity(entityName);
	}

	public function clearCachedChild(p_name:FullName):Void
	{
		Contract.requires(p_name != null && p_name != "");
		Contract.ensures(!childrenByFullName.exists(p_name));
		
		childrenByFullName.remove(p_name);
	}

	override function get_group():IEntityGroup 
	{
		return this;
	}
	
	override function get_fullName():FullName
	{
		return ROOT;
	}
}

private class EntityForRoot extends Entity
{
	public function new(p_core:ICore)
	{
		super(p_core);
		_isAddedToRoot = true;
		name = ROOT;
	}

	override public function setName(p_name:String):IEntityChild
	{
		return this;
	}

	override function set_enabled(value:Bool):Bool
	{
		return true;
	}

	override function get_enabled():Bool
	{
		return false;
	}

	override function get_fullName():String
	{
		return name;
	}

}
