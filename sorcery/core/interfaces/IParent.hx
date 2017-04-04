package sorcery.core.interfaces;
import sorcery.core.interfaces.IEntityChild;

/**
 * @author Dmitriy Kolesnik
 */
interface IParent 
{
	function addChild(child : IEntityChild) : IEntityChild;
	function removeChild(child : IEntityChild) : IEntityChild;
	function findChild(p_name : String) : IEntityChild;
	function removeAllChildren():Void;
}