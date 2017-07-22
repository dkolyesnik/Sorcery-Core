/**
 * Created by Dmitriy Kolesnik on 03.08.2016.
 */
package sorcery.core.interfaces;

import sorcery.core.interfaces.IAgendaManager;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.IEntityChild;

interface ICoreFactory
{
    function initialize(p_core : ICore) : Void;
    
    function createNotificator() : INotificator;
    
    function createTime() : ITime;
    
    function createRoot() : IEntityRoot;
    
	function createFramework():IFramework;

    function generateName() : String;
    
    function allocateEntity() : IEntity;
    
    function wrapInGroup(entity:IEntity) : IEntity;
	
}

