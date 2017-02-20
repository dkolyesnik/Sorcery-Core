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

	public var subType(default, null):String;

	public function new(p_subType:String)
	{
		super(BUNDLE);
		subType = p_subType;
	}

}