/**
 * Created by Dmitriy Kolesnik on 27.08.2016.
 */
package sorcery.core;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.ICoreFactory;
import sorcery.core.interfaces.IEntity;
import sorcery.core.interfaces.IBehavior;
import sorcery.core.interfaces.IEntityRoot;
import sorcery.core.interfaces.IFramework;
import sorcery.core.interfaces.ILinkResolver;
import sorcery.core.interfaces.INotificator;
import sorcery.core.interfaces.ITime;
import sorcery.core.abstracts.Path;
import haxecontracts.Contract;
import haxecontracts.HaxeContracts;



class Core implements ICore implements HaxeContracts
{
    public var root(get, null) : IEntityRoot;
	public var framework(get, null):IFramework;
    public var time(get, null) : ITime;
	
    var notificator(get, null) : INotificator;
	var factory(get, null) : ICoreFactory;

	var _bundlesEntity:IEntity;

	var _pathToLinkResolver:Map<Path, ILinkResolver>;
	
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
		_pathToLinkResolver = new Map();

        factory.initialize(this);

        _createAll();
		
		_bundlesEntity = allocateEntity("bundles");
		root.addChild(_bundlesEntity);
		
        return this;
    }

	function createLink(owner:IBehavior, path:Path):EntityChildLink {
		Contract.requires(owner != null && Path.validate(path));

		var resolver = _pathToLinkResolver[path];
		if(resolver == null)
		{
			resolver = path.toResolver();
			_pathToLinkResolver[path] = resolver;
		}
		return new EntityChildLink(owner, path, resolver);
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
	
	public function error(msg:String):Void
	{
		throw(msg);
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

