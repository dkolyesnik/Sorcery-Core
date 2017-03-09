/**
 * Created by Dmitriy Kolesnik on 03.08.2016.
 */
package sorcery.core;

import sorcery.core.abstracts.Path;
import sorcery.core.CoreNames;
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

class EntityRoot extends EntityGroup implements IEntityRoot implements HaxeContracts
{
	var childrenByFullName = new Map<String,IEntityChild>();
	var nodesByName = new Map<String, NodeList>();
	
	
	public function new(p_core:ICore)
	{
		Contract.requires(p_core != null);
		Contract.ensures(name == CoreNames.ROOT);
		
		_wrappedEntity = new EntityForRoot(p_core);
		_wrappedEntity.setName(CoreNames.ROOT);
		super(_wrappedEntity);
	}
	
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
	
	public function findChildByFullName(p_name:String):IEntityChild
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
				return child;
			}
		}
		return null;
	}

	function _findChildByFullName(p_name:String):IEntityChild
	{
		if (p_name == null || p_name == "")
			return null;
		if (p_name == CoreNames.ROOT)
			return this;

		//TODO optimize
		//var groupsAr = p_name.split(".");
		var entityName = "";
		var entity:IEntity;
		var gr:IEntityGroup = this;
		if (p_name.charAt(1) == Path.TO_COMPONENT)
			return findChild(p_name.substr(2));
			
		for (i in 2...p_name.length)
		{
			var c = p_name.charAt(i);
			if (c == Path.TO_GROUP)
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
			else if (c == Path.TO_COMPONENT)
			{
				entity = gr.findEntity(entityName);
				return entity.findChild(p_name.substr(i + 1));
			}
			else
			{
				entityName += c;
			}
			//if (groupsAr.length > 0)
			//{
				//var entity:IEntity =  this;
				//var gr:IEntityGroup;
				////for (i in 1...groupsAr.length)
				////{
					////var childName = groupsAr[i];
					////if (childName.charAt(0) == "$")
					////{
						////return entity.findChild(childName);
					////}
					////else
					////{
						////if (entity == null || !(entity is IEntityGroup))
							////return null;
						////gr = cast entity;
						////entity = gr.findEntity(childName);
					////}
				////}
				//return entity;
			//}
		}
		
		return gr.findEntity(entityName);
	}

	public function clearCachedChild(p_name:String):Void
	{
		Contract.requires(p_name != null && p_name != "");
		Contract.ensures(!childrenByFullName.exists(p_name));
		
		childrenByFullName.remove(p_name);
	}

	override function get_group():IEntityGroup 
	{
		return this;
	}
	
	override function get_fullName():String 
	{
		return CoreNames.ROOT;
	}
}

private class EntityForRoot extends Entity
{
	public function new(p_core:ICore)
	{
		super(p_core);
		_isAddedToRoot = true;
		name = CoreNames.ROOT;
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
