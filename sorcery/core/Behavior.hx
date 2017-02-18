/**
 * Created by Dmitriy Kolesnik on 24.08.2016.
 */
package sorcery.core;

import sorcery.core.abstracts.Path;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.IEntityChildLink;
import sorcery.core.interfaces.ILinkInternal;
import haxe.Constraints.Function;
import sorcery.core.interfaces.IBehavior;
import sorcery.core.interfaces.IEntity;
import sorcery.core.interfaces.IEntityChild;
import haxecontracts.Contract;
import haxecontracts.HaxeContracts;

class Behavior extends Component implements IBehavior implements HaxeContracts
{
	@:isVar
    public var enabled(get, set) : Bool = true;
	
    var _handlers : Array<HandlerData>;
	var _links:Array<ILinkInternal> = [];
    
    public function new(p_core:ICore)
    {
        super(p_core);
        _handlers = [];
    }
    
    function createLink(path:Path):IEntityChildLink
	{
		Contract.requires(Path.validate(path));
		var len = _links.length;
		Contract.ensures(len +1 == _links.length);
		
		//TODO move link creation to factory
		var link:ILinkInternal = new EntityChildLink(this, path);
		_links.push(link);
		
		if (_isAddedToRoot)
		{
			link.resolve();
		}
		return cast link;
	}
	
	function destroyLink(link:IEntityChildLink):Void
	{
		Contract.requires(link != null);

		var internalLink:ILinkInternal = cast link;
		if (_links.remove(internalLink))
			internalLink.destroy();
	}

	inline function _resolveLinks():Void
	{
		for (link in _links)
			link.resolve();
	}

	inline function _resetLinks():Void
	{
		for (link in _links)
			link.reset();
	}
	
	
	function onEnable() : Void
    {
    }
    
    function onDisable() : Void
    {
    }
    
    function registerEvents() : Void
    {
        if (_handlers == null)
        {
            return;
        }
        
        var i : Int = 0;
        var len : Int = _handlers.length;
        while (i < len)
        {
            _registerEvent(_handlers[i]);
            i++;
        }
    }
    
    function unregisterEvents() : Void
    {
        if (_handlers == null)
        {
            return;
        }
        
        var i : Int = 0;
        var len : Int = _handlers.length;
        while (i < len)
        {
			_handlers[i].unregister();
        }
    }
    
    function _registerEvent(handlerData : HandlerData) : Void
    {
        if (!_isAddedToRoot)
        {
            return;
        }
        
        core.notificator.addHandler(handlerData);
    }
    
    function set_enabled(value : Bool) : Bool
    {
        if (enabled == value)
        {
            return value;
        }
        
        enabled = value;
        (enabled) ? onEnable() : onDisable();
        
        updateActiveState();
        return value;
    }
	
	function get_enabled():Bool{
		return enabled;
	}
   
    // ==============================================================================
    // IEntityChild
    // ==============================================================================
    override public function updateActiveState() : Void
    {
        var l_mustBeActive : Bool = enabled && _isAddedToRoot && parent.isActive();
        if (_isActive == l_mustBeActive)
        {
            return;
        }
        _isActive = l_mustBeActive;
        
        if (_isActive)
        {
            onActivate();
        }
        else
        {
            onDeactivate();
        }
    }
   
    override public function onAddedToRoot() : Void
    {
        super.onAddedToRoot();
		_resolveLinks();
        registerEvents();
    }
    
    override public function onRemovedFromRoot() : Void
    {
		_resetLinks();
		unregisterEvents();
        super.onRemovedFromRoot();
    }
    
    // ==============================================================================
    // EVENTS
    // ==============================================================================
	public function addHandler(handler:HandlerData):HandlerData
	{
		Contract.requires(handler != null);
		Contract.ensures(_handlers.indexOf(handler) >= 0);
		
		_handlers[_handlers.length] = handler;
        
        if (_isAddedToRoot)
        {
            _registerEvent(handler);
        }
		
		return handler;
	}
	
	public function removeHandler(handler:HandlerData):Void
	{
		Contract.requires(handler != null);
		Contract.ensures(_handlers.indexOf(handler) == -1);
		
		handler.unregister();
		_handlers.remove(handler);
	}
}




