/**
 * Created by Dmitriy Kolesnik on 15.11.2016.
 */
package sorcery.core;

import sorcery.core.abstracts.ComponentName;
import sorcery.core.abstracts.Path;
import sorcery.core.interfaces.IComponent;
import sorcery.core.interfaces.IChildLink;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.IEntity;
import sorcery.core.interfaces.IAgendaChild;
import sorcery.core.interfaces.IEntityChild;
import sorcery.core.interfaces.IEntityChildLink;
import sorcery.core.interfaces.ILinkInternal;
import haxecontracts.Contract;
import haxecontracts.HaxeContracts;

class Component extends sorcery.core.EntityChild implements IComponent implements HaxeContracts
{

	public function new(p_core:ICore)
	{
		super(p_core);
	}
	
	override public function setName(p_name:String):IEntityChild 
	{
		Contract.requires(ComponentName.validate(p_name));
		
		return super.setName(p_name);
	}

	
	function onActivate() : Void
	{
		//override
	}
	
    function onDeactivate() : Void
	{
		//override
	}
	
	@:noCompletion
	function onAddedToRoot() : Void
	{
		//override
	}
	
	@:noCompletion
	function onRemovedFromRoot() : Void
	{
		//override
	}
	
	// ==============================================================================
	// IEntityChild
	// ==============================================================================
	override public function destroy() : Void
	{
	}

	
	//override function updateActiveState() : Void
	//{
		//var isMustBeActive : Bool = isAddedToRoot() && _isActivatedByParent && parent.isActive();
//
		//if (isMustBeActive == _isActive)
		//{
			//return;
		//}
//
		//_isActive = isMustBeActive;
//
		//if (_isActive)
		//{
			//onActivate();
		//}
		//else
		//{
			//onDeactivate();
		//}
	//}
	
	//override function onActivatedByParent():Void
	//{
		//_isActivatedByParent = true;
		//if (parent.isAddedToRoot())
			//onAddedToRoot();
	//}
	//
	//override function onDeactivatedByParent():Void
	//{
		//_isActivatedByParent = false;
		//if (isAddedToRoot())
			//onRemovedFromRoot();
	//}
	//
	
	override function activate():Void 
	{
		_isActivated = true;
		onActivate();
	}
	
	override function deactivate():Void 
	{
		onDeactivate();
		_isActivated = false;
	}
	
	override public function addToRoot() : Void
	{
		_doAddToRoot();
		onAddedToRoot();
	}
	
	@:noCompletion
	function _doAddToRoot():Void
	{
		_isAddedToRoot = true;
	}
	
	override public function removeFromRoot() : Void
	{
		onRemovedFromRoot();
		
		_doRemoveFromRoot();
	}
	
	@:noCompletion
	function _doRemoveFromRoot():Void
	{
		if(name != null)
			core.root.clearCachedChild(parent.fullName + name);
			
		_isAddedToRoot = false;
	}

}

