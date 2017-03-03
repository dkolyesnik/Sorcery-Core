/**
 * Created by Dmitriy Kolesnik on 27.08.2016.
 */
package sorcery.core.interfaces;

import sorcery.core.Bundle;
import sorcery.core.interfaces.IAgendaManager;

@:allow(sorcery.core.interfaces.ITime)
interface ICore
{
	@:property
    var root(get, null) : IEntityRoot;    
	@:property
    var framework(get, null):IFramework;
	@:property
    var time(get, null) : ITime;    
	
	function addBundles(pack:Array<Bundle>):Void;
	function removeBundles(pack:Array<Bundle>):Void;
	
    
	@:allow(sorcery.core.interfaces.IEntity)
	@:allow(sorcery.core.interfaces.IBehavior)
    private var notificator(get, null) : INotificator;    
    
	@:property
	@:allow(sorcery.core.interfaces.IEntity)
    private var factory(get, null) : ICoreFactory;    

    function allocateEntity(?name:String) : IEntity;
    
    function wrapInGroup(entity:IEntity) : IEntity;
    
	function log(msg:String):Void;
}

