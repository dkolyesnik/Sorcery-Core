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
	
	override function onAddedToParent(p_parent:IEntity):Void 
	{
		Contract.requires(p_parent.name == CoreNames.ROOT);
		
		super.onAddedToParent(p_parent);
	}
	
	override public function onAddedToRoot():Void 
	{
		super.onAddedToRoot();
		_getNodeLists();
	}
	
	override public function onRemovedFromRoot():Void 
	{
		_releaseNodeLists();
		super.onRemovedFromRoot();
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