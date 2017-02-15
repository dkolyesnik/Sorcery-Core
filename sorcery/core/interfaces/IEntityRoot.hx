/**
 * Created by Dmitriy Kolesnik on 03.08.2016.
 */
package sorcery.core.interfaces;
import sorcery.core.interfaces.IComponent;
import sorcery.core.misc.NodeList;


interface IEntityRoot extends IEventSender
{
	function addNode(node:ISystemNode):Void;
	function removeNode(node:ISystemNode):Void;
	function getNodes(nodeName:String):NodeList;

    function addChild(child : IEntityChild) : IEntityChild;
    function removeChild(child : IEntityChild) : IEntityChild;
	
	function findChildByFullName(p_name:String):IEntityChild;
	
	function clearCachedChild(p_name:String):Void;
    
    function findEntity(p_name : String) : IEntity;
}

