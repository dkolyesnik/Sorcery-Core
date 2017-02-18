package sorcery.core;
import sorcery.core.Behavior;
import sorcery.core.interfaces.IEntity;
import sorcery.core.macros.SystemNodeBuildMacro;
import sorcery.core.misc.NodeIterator;
import sorcery.core.misc.NodeList;

import sorcery.core.abstracts.Path;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.IEntityChildLink;
import sorcery.core.interfaces.ISystemNode;

/**
 * ...
 * @author Dmitriy Kolyesnik
 */
	
@:allow(sorcery.core.misc.NodeList)
@:allow(sorcery.core.misc.NodeIterator)
@:autoBuild(sorcery.core.macros.SystemNodeBuildMacro.build())
class SystemNode extends Behavior implements ISystemNode
{
	public var nodeName(get, null):String;
	
	var list(get, null):NodeList;
	var next(get, null):ISystemNode;
	var prev(get, null):ISystemNode;
	
	public function new(p_core:ICore) 
	{
		super(p_core);
		_createLinks();
	}
	
	public function some():Bool
	{
		return false;
	}
	
	public function prepare():Bool
	{
		//override to prepare node for work in system, get components from links, for example
		return true;
	}
	
	public function unprepare():Void
	{
		//override to undo all preparetion, like releasing components and so on
	}
	
	override function onActivate():Void 
	{
		super.onActivate();
		core.root.addNode(this);
	}
	
	override function onDeactivate():Void 
	{
		core.root.removeNode(this);
		super.onDeactivate();
	}
	
	function _createLinks():Void
	{
		
	}
	
	function get_next():ISystemNode
	{
		return next;
	}
	
	function get_prev():ISystemNode
	{
		return prev;
	}
	
	function get_list():NodeList
	{
		return list;
	}
	
	function get_nodeName():String
	{
		return nodeName;
	}
	
}