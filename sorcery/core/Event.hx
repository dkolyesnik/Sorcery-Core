/**
 * Created by Dmitriy Kolesnik on 04.08.2016.
 */
package sorcery.core;

import sorcery.core.interfaces.IEvent;

class Event implements IEvent
{
    public var type(get, never) : String;

    private var _type : String;
    
    public function new(p_type : String)
    {
        _type = p_type;
    }
    
    private function get_type() : String
    {
        return _type;
    }
}

