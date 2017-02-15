/**
 * Created by Dmitriy Kolesnik on 02.08.2016.
 */
package sorcery.core;

import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.ISettings;

class Settings implements ISettings
{
    public var appName(get, never) : String;
    public var version(get, never) : String;

    private var _appName : String;
    private var _version : String;
    
    public function new()
    {
    }
    
    public function initialize(p_core : ICore) : Void
    {
    }
    
    private function get_appName() : String
    {
        return _appName;
    }
    
    private function get_version() : String
    {
        return _version;
    }
    
    public function getData(id : String) : Dynamic
    {
        return null;
    }
}

