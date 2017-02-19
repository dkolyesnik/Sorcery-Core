package sorcery.core.interfaces;
import sorcery.core.abstracts.FrameworkObjName;
import sorcery.core.interfaces.IEntityChild;

/**
 * @author Dmitriy Kolesnik
 */
interface IFramework 
{
	function setObj<T>(name:FrameworkObjName<T>, obj:T):Void;
	function getObj<T>(name:FrameworkObjName<T>):T;
}