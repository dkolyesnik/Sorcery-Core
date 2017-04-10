/**
 * Created by Dmitriy Kolesnik on 04.08.2016.
 */
package sorcery.core;

import sorcery.core.interfaces.IEvent;

//@:autoBuild(sorcery.core.macros.EventBuildMacro.build())
class Event implements IEvent
{
    public var type(get, never) : String;

    var _type : String;
    
    public function new(p_type : String)
    {
        _type = p_type;
    }
	
	public function reset():Void
	{
		
	}
    
    function get_type() : String
    {
        return _type;
    }
}

