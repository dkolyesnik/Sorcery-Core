/**
 * Created by Dmitriy Kolesnik on 01.09.2016.
 */
package sorcery.core;
import sorcery.core.Behavior;
import sorcery.core.abstracts.EventType;
import sorcery.core.interfaces.IEntity;
import de.polygonal.ds.Map;

import sorcery.core.abstracts.Path;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.IBundle;
import sorcery.core.interfaces.IEntityChildLink;

class Bundle extends Behavior implements IBundle
{
	@:noCompletion
	var _requirements:Array<String> = [];

	@:noCompletion
	var _waitingForInitialization:Array<WaitForInit> = [];
	@:noCompletion
	var _onInitHandler:HandlerData;
	public function new()
	{
		super(null);
		setupName();
		setupRequirements();
		setupDelayedInitialization();
	}
	
	function setupName():Void
	{
		//need to be overriden
	}
	
	function setupRequirements():Void
	{
		//need to be overriden
	}
	
	function setupDelayedInitialization():Void
	{
		//need to be overridden
	}

	override function onAddedToParent(p_parent:IEntity):Void
	{
		core = p_parent.core;
		super.onAddedToParent(p_parent);
	}

	public function initialize():Void
	{
		checkRequirements();
		onInitialize();
		if (_waitingForInitialization.length > 0)
			_onInitHandler = addHandler(new TypedHandlerData<BundleEvent>(BundleEvent.BUNDLE, createLink(""), _onRequiredBundleInitialized));
		else
			_initializationComplete();
	}

	function onInitialize():Void
	{
		//override to add entities and so on
	}

	function checkRequirements():Void
	{
		for (bundleName in _requirements)
		{
			if (parent.findChild(bundleName) == null)
				Console.error('Required bundle is not added, bundle name = $name, required bundle name = $bundleName');
		}
	}

	function waitsFor(requiredBundles:Array<String>, action:Void->Void):Void
	{
		_waitingForInitialization.push(new WaitForInit(requiredBundles, action));
	}
	
	function requiresBundle(bundleName:String):Void
	{
		_requirements.push(bundleName);
	}

	@:noCompletion
	function _onRequiredBundleInitialized(e:BundleEvent)
	{
		var i = _waitingForInitialization.length;
		while (i --> 0)
		{
			var waitData = _waitingForInitialization[i];
			if (waitData.requiredBundles.remove(e.subType)
					&& waitData.requiredBundles.length == 0)
			{
				_waitingForInitialization.splice(i, 1);
				waitData.action();
			}
		}

		if (_waitingForInitialization.length == 0)
			_initializationComplete();
	}

	function _initializationComplete():Void
	{
		if (_onInitHandler != null)
			removeHandler(_onInitHandler);

		trace(LogType.LOG, '$name bundle is initialized');

		parent.sendEvent(new BundleEvent(name));
	}
}

private class WaitForInit
{
	public var requiredBundles:Array<String>;
	public var action:Void->Void;
	public function new(p_requiredBundles:Array<String>, p_action:Void->Void)
	{
		requiredBundles = p_requiredBundles;
		action = p_action;
	}
}

class BundleEvent extends Event
{
	/**
	 * sent when bundle is initialized
	 */
	inline static public var BUNDLE = new EventType<BundleEvent>("bundle");

	public var subType(default, null):String;

	public function new(p_subType:String)
	{
		super(BUNDLE);
		subType = p_subType;
	}

}

