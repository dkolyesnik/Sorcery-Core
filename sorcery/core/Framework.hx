package sorcery.core;
import haxecontracts.Contract;
import haxecontracts.HaxeContracts;
import sorcery.core.abstracts.FrameworkObjName;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.IEntity;
import sorcery.core.interfaces.IEntityChild;
import sorcery.core.interfaces.IFramework;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
class Framework implements IFramework implements HaxeContracts
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
		Contract.requires(FrameworkObjName.validate(name));
		Contract.requires(obj != null);
		Contract.requires(Std.is(obj, IEntityChild));
		obj.setName(name);
		rootEntity.addChild(cast obj);
	}
	
	public function getObj<T:IEntityChild>(name:FrameworkObjName<T>):T 
	{
		Contract.requires(FrameworkObjName.validate(name));
		
		return cast rootEntity.findChild(name);
	}
	
}