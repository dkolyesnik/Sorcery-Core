/**
 * Created by Dmitriy Kolesnik on 03.08.2016.
 */
package sorcery.core.interfaces;
import sorcery.core.interfaces.ICore;


interface ISettings
{
	@:property
    var appName(get, never) : String;    
	@:property
    var version(get, never) : String;

    function initialize(p_core : ICore) : Void;
    
    function getData(id : String) : Dynamic;
}

