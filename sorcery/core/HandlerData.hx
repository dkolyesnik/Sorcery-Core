/**
 * Created by Dmitriy Kolesnik on 28.08.2016.
 */
package sorcery.core;

import sorcery.core.abstracts.EventType;
import sorcery.core.abstracts.Priority;
import sorcery.core.interfaces.IEntityChildLink;
import haxe.Constraints.Function;
import sorcery.core.interfaces.IEvent;
import haxecontracts.Contract;
import haxecontracts.HaxeContracts;

class HandlerData
{
	@:property
	public var target(get, never) : String;
	@:property
	public var priority(get, null) : Priority;
	@:property
	public var type(get, null) : String;

	var next:HandlerData;
	var prev:HandlerData;
	
	var _link:IEntityChildLink;

	private function new(p_type : String, p_targetLink : IEntityChildLink, p_priority : Priority = 0)
	{
		type = p_type;
		_link = p_targetLink;
		priority = p_priority;
	}

	public function activate(event : IEvent) : Void
	{
	}
	
	public function unregister():Void
	{
		if (prev != null)
			prev.next = next;
		if ( next != null)
			next.prev = prev;
	}

	function get_target() : String
	{
		return _link.fullName;
	}
	
	function get_priority():Int 
	{
		return priority;
	}
	
	function get_type():String 
	{
		return type;
	}
}

