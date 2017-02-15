package sorcery.core;
import sorcery.core.abstracts.EventType;

/**
 * ...
 * @author Dmitriy Kolyesnik
 */
class CoreEvent extends Event
{
	public static inline var CORE_UPDATE = new EventType<CoreEvent>("coreUpdate");
	
	public static var coreUpdateEvent = new CoreEvent(CORE_UPDATE);
	
	private function new(p_type:String) 
	{
		super(p_type);
		
	}
	
}