/**
 * Created by Dmitriy Kolesnik on 27.08.2016.
 */
package sorcery.core.interfaces;

import sorcery.core.interfaces.IAgendaManager;

@:allow(sorcery.core.interfaces.ITime)
interface ICore
{
    var root(get, null) : IEntityRoot;    
    var framework(get, null):IFramework;
    var time(get, null) : ITime;    
	
	function addBundles(pack:BundlePack):Void;
	function removeBundles(pack:BundlePack):Void;
	
    
	@:allow(sorcery.core.interfaces.IEntity)
	@:allow(sorcery.core.interfaces.IBehavior)
    private var notificator(get, null) : INotificator;    
    
	@:allow(sorcery.core.interfaces.IEntity)
    private var factory(get, null) : ICoreFactory;    

    function allocateEntity(?name:String) : IEntity;
    
    function wrapInGroup(entity:IEntity) : IEntity;
    
	function log(msg:String):Void;
}

