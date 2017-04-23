package sorcery.core.misc;

import sorcery.core.interfaces.INodeIterator;
import sorcery.core.interfaces.ISystemNode;
import haxecontracts.Contract;

/**
 * ...
 * @author Dmitriy Kolyesnik
 */

@:allow(sorcery.core.misc.NodeList)
@:generic
class PrepearingNodeIterator<T:ISystemNode> extends NodeIterator<T>
{
	public function new() 
	{
		super();
	}	
	
	override public function getFirstNode():T 
	{
		current = list != null ? cast list.head : null;
		_findNext();
		return cast current;
	}
	
	override public function start():Void 
	{
		current = getFirstNode();
		_skipIteration = true;
	}
	
	override public function finish():Void 
	{
		if (current != null)
			current.unprepare();
		current = null;
	}
	
	override public function hasNext():Bool 
	{
		if (!_skipIteration)
		{
			current = current != null ? cast current.next : null;
			_findNext();
		}
		else
		{
			_skipIteration = false;
		}
		return current != null;
	}
	
	override function onRemoved(node:ISystemNode):Void 
	{
		Contract.requires(node != null);
		
		if (node == current)
		{
			current.unprepare();
			current = cast current.next;
			_findNext();
			_skipIteration = true;
		}
	}
	
	 function _findNext():Void 
	{
		while (current != null && !current.prepare())
		{
			current.unprepare();
			current = cast current.next;
		}
	}
}