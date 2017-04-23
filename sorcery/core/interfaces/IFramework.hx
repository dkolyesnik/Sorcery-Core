package sorcery.core.interfaces;
import sorcery.core.abstracts.FrameworkObjName;
import sorcery.core.interfaces.IEntityChild;

/**
 * @author Dmitriy Kolesnik
 */
interface IFramework 
{
	function setObj<T:IEntityChild>(name:FrameworkObjName<T>, obj:T):Void;
	function getObj<T:IEntityChild>(name:FrameworkObjName<T>):T;
}