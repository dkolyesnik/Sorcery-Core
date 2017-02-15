/**
 * Created by Dmitriy Kolesnik on 02.08.2016.
 */
package sorcery.core.interfaces;
import sorcery.core.HandlerData;


interface INotificator
{
	@:allow(sorcery.core.interfaces.IEntity) 
    private function sendEvent(event : IEvent, fullTargetName : String) : Void;
	
	@:allow(sorcery.core.interfaces.IBehavior)
    function addHandler(data : HandlerData) : Void;
}

