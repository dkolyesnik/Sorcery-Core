package sorcery.core;

import sorcery.core.HandlerData;
import sorcery.core.abstracts.EventType;
import sorcery.core.abstracts.Priority;
import sorcery.core.interfaces.ICommand;
import sorcery.core.interfaces.ICommandManager;
import sorcery.core.interfaces.IEntityChildLink;
import sorcery.core.interfaces.IEvent;
import sorcery.core.macros.CommandBuildMacro;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
@:autoBuild(sorcery.core.macros.CommandBuildMacro.build())
class Command<T:IEvent> extends HandlerData implements ICommand
{
	var _manager:ICommandManager;
	public function new(p_type:EventType<T>, p_priority:Priority=0) 
	{
		super(p_type, null, p_priority);
	}
	
	function setManager(manager:ICommandManager):Void 
	{
		_manager = manager;
		_link = _manager.getLink("@");
		_createLinks();
	}
	
	function clearManager():Void
	{
		_returnLinks();
		_manager.returnLink(_link);
		_manager = null;
	}
	
	override public function activate(event:IEvent):Void 
	{
		execute(cast event);
	}
	
	function getHandler():HandlerData 
	{
		return this;
	}
	
	function execute(e:T):Void
	{
		//override
	}
	
	function _createLinks():Void
	{
		
	}
	
	function _returnLinks():Void
	{
		
	}
	
}