package sorcery.core;

import sorcery.core.Event;
import sorcery.core.abstracts.EventType;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
class BundleEvent extends Event
{
	/**
	 * sent when bundle is initialized
	 */
	inline static public var BUNDLE = new EventType<BundleEvent>("bundle");
	inline static public var CHECK_REQUIREMENTS = new EventType<Event>("checkRequirements");
	

	public var subType(default, null):String;

	public function new(p_subType:String)
	{
		super(BUNDLE);
		subType = p_subType;
	}

	static var _checkEvent:Event;
	public static function getCheckRequirmentsEvent():Event
	{
		if (_checkEvent == null)
			_checkEvent = new Event(CHECK_REQUIREMENTS);
		return _checkEvent;
	}
	
}