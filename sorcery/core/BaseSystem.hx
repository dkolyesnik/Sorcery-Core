package sorcery.core;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.IEntity;
import sorcery.core.interfaces.ISystem;
import sorcery.core.macros.BaseSystemBuildMacro;
import haxecontracts.Contract;
import haxecontracts.HaxeContracts;

/**
 * ...
 * @author Dmitriy Kolyesnik
 */

@:autoBuild(sorcery.core.macros.BaseSystemBuildMacro.build())
class BaseSystem extends Behavior implements ISystem implements HaxeContracts
{
	
	public function new(p_core:ICore, priority:Int = 0) 
	{
		super(p_core);
		addHandler(new TypedHandlerData(CoreEvent.CORE_UPDATE, createLink("#"), update, priority));
		_createNodeListLinks();
	}
	
	override function addToParent(p_parent:IEntity):Void 
	{
		Contract.requires(p_parent.name == CoreNames.ROOT);
		
		super.addToParent(p_parent);
	}
	
	override function _doAddToRoot():Void 
	{
		super._doAddToRoot();
		_getNodeLists();
	}
	
	override function _doRemoveFromRoot():Void 
	{
		_releaseNodeLists();
		super._doRemoveFromRoot();
	}
	
	function update(e:CoreEvent):Void
	{
		
	}
	
	function _createNodeListLinks():Void
	{
		
	}
	
	function _getNodeLists():Void
	{
		
	}
	
	function _releaseNodeLists():Void
	{
		
	}
}