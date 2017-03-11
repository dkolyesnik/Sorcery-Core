package sorcery.core;
/**
 * Created by Dmitriy Kolesnik on 24.08.2016.
 */
import Std;
import Std;
import sorcery.core.HandlerData;
import sorcery.core.abstracts.EventType;
import sorcery.core.abstracts.FullName;
import sorcery.core.interfaces.IEvent;
import sorcery.core.interfaces.INotificator;
import haxecontracts.Contract;
import haxecontracts.HaxeContracts;

class Notificator implements INotificator implements HaxeContracts
{
	/**
	 * Map with handlers by type) by target
	 */
	private var _targetToTypeToHandlers  = new Map<String, Map<String, HandlersList>>();
	
	public function new()
	{
	}

	public function sendEvent(event : IEvent, fullTargetName : String) : Void
	{
		Contract.requires(EventType.validate(event.type) && FullName.validate(fullTargetName));

		var list : HandlersList = _getHandersList(fullTargetName, event.type);
		if (list != null)
		{
			list.sendEvent(event);
		}
	}

	public function addHandler(data : HandlerData) : Void
	{
		Contract.requires(data != null);

		_getHandersList(data.target, data.type, true).add(data);
	}

	/**
	 * find or create a List with handlers
	 * @param target - name of the target
	 * @param type - event type
	 * @param needToCreate - do it needs to create new storage
	 * @return HandlersList
	 */
	private function _getHandersList(target : String, type : String, needToCreate : Bool = false) : HandlersList
	{
		var typeToHandlers = _getTypeToHandlers(target, needToCreate);

		if (typeToHandlers == null)
		{
			return null;
		}

		return _getHandlersByType(typeToHandlers, type, needToCreate);
	}

	/**
	 * find or create a Map with the lists of handlers by event type
	 * @param target
	 * @param needToCreate
	 * @return Map with HandlersList by event type
	 */
	function _getTypeToHandlers(target : String, needToCreate : Bool = false) : Map<String, HandlersList>
	{
		if (!_targetToTypeToHandlers.exists(target) && needToCreate)
		{
			var list = new Map<String, HandlersList>();
			_targetToTypeToHandlers[target] = list;
			return list;
		}
		else
		{
			return _targetToTypeToHandlers[target];
		}
	}

	static function _getHandlersByType(typeToHandler : Map<String, HandlersList>, type : String, needToCreate : Bool = false) : HandlersList
	{
		if (!typeToHandler.exists(type) && needToCreate)
		{
			var list = new HandlersList();
			list.eventName = type;
			typeToHandler[type] = list;
			return list;
		}
		else
		{
			return typeToHandler[type];
		}
	}
}

@:access(sorcery.core.HandlerData)
class ListIterator
{
	var _head:HandlerData;
	var _end:HandlerData;
	var _current:HandlerData;
	public function new(list:HandlersList)
	{
		_head = list.head;
		_end = list.end;
	}

	public function activate():Void
	{
		_current = _head.next;
	}

	public function hasNext():Bool
	{
		return _current != _end;
	}

	public function next():HandlerData
	{
		var res = _current;
		_current = _current.next;
		return res;
	}
}
@:access(sorcery.core.HandlerData)
class HandlersList
{
	public var eventName:String;
	public var head(default, null):HandlerData; 
	public var end(default, null):HandlerData;
	var _addLaterHead : HandlerData;
	var _addLaterEnd :HandlerData;
	var _iterators : Array<ListIterator>;
	var _activeIteratorsCount:Int;

	public function new(numberOfIterators:Int = 1)
	{
		head = new HandlerData(null, null);
		end = new HandlerData(null, null);
		head.next = end;
		end.prev = head;
		_iterators = [];
		while (numberOfIterators > 0)
		{
			_iterators[_iterators.length] = new ListIterator(this);
			numberOfIterators--;
		}
		_activeIteratorsCount = 0;
	}

	public function sendEvent(event : IEvent) : Void
	{
		var _iterator = getIterator();
		for (handlerData in _iterator)
		{
			handlerData.activate(event);
		}
		putBackIterator(_iterator);
	}

	public function add(item : HandlerData) : Void
	{
		if (_activeIteratorsCount > 0)
		{
			//if we have busy iterators
			if (_addLaterHead == null)
			{
				_addLaterEnd = _addLaterHead = item;
			}
			else
			{
				_addLaterEnd.next = item;
				item.prev = _addLaterEnd;
				_addLaterEnd = item;
			}
		}
		else
		{
			_addItem(item);
		}
	}

	public function remove(item : HandlerData) : Void
	{
		if ( item.prev != null)
			item.prev.next = item.next;
		if (item.next != null)
			item.next.prev = item.prev;
	}

	function getIterator() : ListIterator
	{
		var iterator;
		if (_iterators.length > 0)
			iterator = _iterators.pop();
		else
			iterator = new ListIterator(this);
			
		_activeIteratorsCount++;
		iterator.activate();
		return iterator;
	}

	function putBackIterator(iterator : ListIterator) : Void
	{
		_iterators.push(iterator);
		_activeIteratorsCount--;

		if (_activeIteratorsCount == 0)
		{
			_addDelayedItems();
		}
	}
	
	function _addDelayedItems() : Void
	{
		//TODO optimize
		while (_addLaterHead != null)
		{
			var next = _addLaterHead.next;
			_addItem(_addLaterHead);
			_addLaterHead = next;
		}
		_addLaterEnd = null;
	}

	function _addItem(item : HandlerData) : Void
	{
		if (head.next == end)
		{
			head.next = item;
			item.prev = head;
			end.prev = item;
			item.next = end;
		}
		else if (end.prev.priority <= item.priority)
		{
			end.prev.next = item;
			item.prev = end.prev;
			end.prev = item;
			item.next = end;
		}
		else
		{
			var iterator = getIterator();
			for ( handlerData in iterator)
			{
				$type(handlerData);
				trace(handlerData._link.fullName);
				trace(handlerData.priority);
				if (handlerData.priority > item.priority)
				{
					item.next = handlerData;
					item.prev = handlerData.prev;
					handlerData.prev.next = item;
					handlerData.prev = item;
					break;
				}
			}
			putBackIterator(iterator);
		}
		
			
	}
}
