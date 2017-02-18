package sorcery.core;
import sorcery.core.abstracts.FrameworkObjName;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.IEntity;
import sorcery.core.interfaces.IEntityChild;
import sorcery.core.interfaces.IFramework;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
class Framework implements IFramework
{
	var core:ICore;
	var rootEntity:IEntity;
	public function new(p_core:ICore) 
	{
		core = p_core;
		rootEntity = cast core.root;
	}
	
	/* INTERFACE IFramework */
	public function setObj<T:IEntityChild>(name:FrameworkObjName<T>, obj:T):Void 
	{
		rootEntity.addChild(obj);
	}
	
	public function getObj<T:IEntityChild>(name:FrameworkObjName<T>):T 
	{
		return cast rootEntity.findChild(name);
	}
	
}