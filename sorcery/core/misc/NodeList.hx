package sorcery.core.misc;
import sorcery.core.SystemNode;
import sorcery.core.interfaces.INodeIterator;
import sorcery.core.interfaces.ISystemNode;
import sorcery.core.abstracts.Signal;	

/**
 * ...
 * @author Dmitriy Kolyesnik
 */

@:allow(sorcery.core.interfaces.INodeIterator)
class NodeList
{
	var head(default,null):ISystemNode;
	var end(default, null):ISystemNode;
	var onAddEmitter:SignalEmitter<ISystemNode>;
	public var onAdd(get, never):Signal<ISystemNode>;
	inline public function get_onAdd():Signal<ISystemNode>
	{
		return onAddEmitter.getSignal();
	}
	
	var onRemoveEmitter:SignalEmitter<ISystemNode>;
	public var onRemove(get, never):Signal<ISystemNode>;
	inline public function get_onRemove():Signal<ISystemNode>
	{
		return onRemoveEmitter.getSignal();
	}
	
	public function new()
	{
		onAddEmitter = new SignalEmitter<ISystemNode>();
		onRemoveEmitter = new SignalEmitter<ISystemNode>();
	}

	public function add(node:ISystemNode):Void
	{
		if (head == null)
		{
			head = node;
			end = head;
		}
		else
		{
			node.prev = end;
			end.next = node;
			end = node;
		}
		node.list = this;
		onAddEmitter.emit(node);
	}

	public function remove(node:ISystemNode):Void
	{
		onRemoveEmitter.emit(node);
		if (node.prev != null)
			node.prev.next = node.next;
		if (node.next != null)
			node.next.prev = node.prev;

		node.next = null;
		node.prev = null;
		node.list = null;
	}
}