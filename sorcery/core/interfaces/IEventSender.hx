package sorcery.core.interfaces;

/**
 * @author Dmitriy Kolyesnik
 */
interface IEventSender 
{
	function sendEvent(event:IEvent):Void;
}