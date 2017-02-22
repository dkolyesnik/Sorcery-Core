/**
 * Created by Dmitriy Kolesnik on 01.09.2016.
 */
package sorcery.core;
import sorcery.core.Behavior;
import sorcery.core.abstracts.EventType;
import sorcery.core.interfaces.IEntity;

import sorcery.core.abstracts.Path;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.IBundle;
import sorcery.core.interfaces.IEntityChildLink;
import sorcery.core.misc.Pair;

typedef WaitForInit = Pair<Array<String>, Void->Void>;

@:autoBuild(sorcery.core.macros.BundleBuildMacro.build())
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
		addHandler(new TypedHandlerData(BundleEvent.CHECK_REQUIREMENTS, createLink("@"), onCheckRequirements));
		setupBundleName();
		setupRequirements();
		setupDelayedInitialization();
	}
	
	function onCheckRequirements(e:Event) 
	{
		checkRequirements();
	}
	
	function onInitialize():Void
	{
		//override to add entities and so on
	}
	
	function onUninitialize():Void
	{
		//override to remove entities and so on
	}
	
	function setupBundleName():Void
	{
		//override to setip Bundle name, or do not override and it will be created by macros
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
	
	override function onRemovedFromParent():Void 
	{
		onUninitialize();
		super.onRemovedFromParent();
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
	
	function requiresBundles(bundles:Array<String>):Void
	{
		for (bundleName in bundles)
			_requirements.push(bundleName);
	}

	@:noCompletion
	function _onRequiredBundleInitialized(e:BundleEvent)
	{
		var i = _waitingForInitialization.length;
		while (i --> 0)
		{
			var waitData = _waitingForInitialization[i];
			if (waitData.a.remove(e.subType)
					&& waitData.a.length == 0)
			{
				_waitingForInitialization.splice(i, 1);
				waitData.b();
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



