package sorcery.core.misc;
import sorcery.core.SystemNode;
import sorcery.core.interfaces.ISystemNode;

/**
 * ...
 * @author Dmitriy Kolyesnik
 */

@:generic
class NodeListLink<T:ISystemNode>
{
	public var length(get, never):Int;
	var _iterator:NodeIterator<T>;
	public function new(p_iterator:NodeIterator<T>) 
	{
		_iterator = p_iterator;
	}
	
	public function setNodeList(list:NodeList):Void
	{
		_iterator.setList(list);
	}
	
	public function releaseNodeList():Void
	{
		_iterator.unsetList();
	}
	
	public function getFirstNode():T
	{
		return _iterator.getFirstNode();
	}
	
	public function iterator():NodeIterator<T>
	{
		_iterator.start();
		return _iterator;
	}
	
	public function addOnAddedCallback(callback:T->Void):Void
	{
		_iterator.addOnAddedCallback(callback);
	}
	
	public function addOnRemovedCallback(callback:T->Void):Void
	{
		_iterator.addOnRemovedCallback(callback);
	}
	
	public function removeOnAddedCallback():Void{
		_iterator.removeOnAddedCallback();
	}
	
	public function removeOnRemoveCallback():Void{
		_iterator.removeOnRemovedCallback();
	}
	
	function get_length():Int 
	{
		return _iterator.length;
	}
}