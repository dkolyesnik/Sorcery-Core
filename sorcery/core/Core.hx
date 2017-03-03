/**
 * Created by Dmitriy Kolesnik on 27.08.2016.
 */
package sorcery.core;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.ICoreFactory;
import sorcery.core.interfaces.IBundle;
import sorcery.core.interfaces.IEntity;
import sorcery.core.interfaces.IEntityGroup;
import sorcery.core.interfaces.IEntityRoot;
import sorcery.core.interfaces.IFramework;
import sorcery.core.interfaces.INotificator;
import sorcery.core.interfaces.ITime;
import haxecontracts.Contract;
import haxecontracts.HaxeContracts;



class Core implements ICore implements HaxeContracts
{
	@:property
    public var root(get, null) : IEntityRoot;
	@:property
	public var framework(get, null):IFramework;
	@:property
    public var time(get, null) : ITime;
	
	@:property
    var notificator(get, null) : INotificator;
	@:property
	var factory(get, null) : ICoreFactory;

	var _bundlesEntity:IEntity;
	
    public function new(?p_factory:ICoreFactory)
    {
		if (p_factory == null)
			factory = new CoreFactory();
		else
			factory = p_factory;
		
		_initialize();
    }
    
    function _initialize() : ICore
    {
        factory.initialize(this);

        _createAll();
		
		_bundlesEntity = allocateEntity("bundles");
		root.addChild(_bundlesEntity);
		
        return this;
    }
	
	public function addBundles(pack:Array<Bundle>):Void
	{
		//adding as a child, so bundle will have core access
		for (bundle in pack)
			_bundlesEntity.addChild(bundle);

		//checking requirements and adding handlers for delayed initialiation
		for (bundle in pack)
			bundle.preInitialize();
			
		// initialization
		for (bundle in pack)
			bundle.initialize();
		
		//sending events of complete initialization
		for (bundle in pack)
			bundle.completeInitialization();
	}
	
	public function removeBundles(pack:Array<Bundle>):Void
	{
		
		for (bundle in pack)
			_bundlesEntity.removeChild(bundle);
		_bundlesEntity.sendEvent(BundleEvent.getCheckRequirmentsEvent());
	}
    
    private function _createAll() : Void
    {
        notificator = factory.createNotificator();
        time = factory.createTime();
        root = factory.createRoot();
		framework = factory.createFramework();
    }
    
    public function allocateEntity(?name:String) : IEntity
    {
        var ent = factory.allocateEntity();
		if(name != null)
			ent.setName(name);
		return ent;
    }
    
    public function wrapInGroup(entity:IEntity) : IEntity
    {
        return factory.wrapInGroup(entity);
    }
    
    public function log(msg : String) : Void
    {
        trace(msg);
    }
	
	public function get_root():IEntityRoot
	{
		return root;
	}
	public function get_time():ITime
	{
		return time;
	}
	public function get_notificator():INotificator
	{
		return notificator;
	}
	public function get_factory():ICoreFactory
	{
		return factory;
	}
	
	function get_framework():IFramework 
	{
		return framework;
	}
}

interface I
{
	@:property
    var some(get,set):Bool;
}

interface J
{
	@:property
	var some(get, set):Bool;
	function doSome():Void;
}

class A implements I implements J
{
    @:property
	public var some(get,set):Bool;
    var _some:Bool;
    function get_some():Bool
    {
        return _some;
    }
    function set_some(v:Bool):Bool
    {
        return _some = v;
    }
	
	public function doSome():Void
	{
		
	}
	
	public function new()
	{
		
	}
}

class B extends A 
{
    override function get_some():Bool
    {
        return true;
    }
}