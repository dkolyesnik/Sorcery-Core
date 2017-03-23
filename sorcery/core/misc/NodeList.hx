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
	public var onAdd:Signal<ISystemNode>;
	public var onRemove:Signal<ISystemNode>;
	
	public function new()
	{
		onAdd = new Signal<ISystemNode>();
		onRemove = new Signal<ISystemNode>();
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
		onAdd.emit(node);
	}

	public function remove(node:ISystemNode):Void
	{
		onRemove.emit(node);
		if (node.prev != null)
			node.prev.next = node.next;
		if (node.next != null)
			node.next.prev = node.prev;

		node.next = null;
		node.prev = null;
		node.list = null;
	}
}