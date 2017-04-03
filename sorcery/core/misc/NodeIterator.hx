package sorcery.core.misc;
import sorcery.core.SystemNode;
import sorcery.core.interfaces.INodeIterator;
import sorcery.core.interfaces.ISystemNode;
import haxecontracts.Contract;
import haxecontracts.HaxeContracts;

/**
 * ...
 * @author Dmitriy Kolyesnik
 */

@:allow(sorcery.core.misc.NodeList)

@:generic
class NodeIterator<T:ISystemNode> implements INodeIterator implements HaxeContracts
{
	var current:T;
	var list:NodeList;
	var _skipIteration:Bool;
	var _onAddCallback:T->Void;
	var _onRemoveCallback:T->Void;
	
	public function new()
	{

	}

	public function setList(p_list:NodeList):Void
	{
		Contract.requires(p_list != null);

		list = p_list;
		list.onAdd.connect(onAdded);
		list.onRemove.connect(onRemoved);
		if (_onAddCallback != null)
		{
			_start();
			while (_hasNext())
			{
				var node = _next();
				_onAddCallback(node);
			}
		}
		
	}

	public function unsetList():Void
	{
		if (_onRemoveCallback != null)
		{
			_start();
			while(_hasNext())
			{
				var node = _next();
				_onRemoveCallback(node);
			}
		}
		list.onRemove.disconnect(onRemoved);
		current = null;
		list = null;
	}

	public function start():Void
	{
		current = cast list.head;
		_skipIteration = true;
	}
	
	function _start():Void
	{
		current = cast list.head;
		_skipIteration = true;
	}

	public function getFirstNode():T
	{
		return cast list.head;
	}

	public function destroy():Void
	{
		if (current != null)
			current.unprepare();
		current = null;
		if (list != null)
			list.onRemove.disconnect(onRemoved);
		list = null;
	}

	public function next():T
	{
		return cast current;
	}
	
	function _next():T
	{
		return cast current;
	}

	public function hasNext():Bool
	{
		if (!_skipIteration)
		{
			current = cast current.next;
		}
		else
		{
			_skipIteration = false;
		}
		return current != null;
	}
	
	function _hasNext():Bool
	{
		if (!_skipIteration)
		{
			current = cast current.next;
		}
		else
		{
			_skipIteration = false;
		}
		return current != null;
	}

	public function finish():Void
	{
		current = null;
	}

	public function addOnAddedCallback(callback:T->Void):Void
	{
		_onAddCallback = callback;
	}
	
	public function addOnRemovedCallback(callback:T->Void):Void
	{
		_onRemoveCallback = callback;
	}
	
	public function removeOnAddedCallback() 
	{
		_onAddCallback = null;
	}
	
	public function removeOnRemovedCallback()
	{
		_onRemoveCallback = null;
	}

	function onRemoved(node:ISystemNode):Void
	{
		Contract.requires(node != null);

		if (node == current)
		{
			current = cast current.next;
			_skipIteration = true;
		}
		if (_onRemoveCallback != null)
			_onRemoveCallback(cast node);
	}
	
	function onAdded(node:ISystemNode):Void
	{
		Contract.requires(node != null);
		
		if (_onAddCallback != null)
			_onAddCallback(cast node);
		
	}
}

