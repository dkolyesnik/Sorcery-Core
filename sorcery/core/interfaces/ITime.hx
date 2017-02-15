/**
 * Created by Dmitriy Kolesnik on 02.08.2016.
 */
package sorcery.core.interfaces;

interface ITime
{
	var dt(get, null) : Float;
	var fps(get, null) : Int;
	var isStarted(get, null) : Bool;
	var timeScale(get, set) : Float;
	var lifeTime(get, null) : Float;
	
	function start():Void;
	function stop():Void;
	function update():Void;
}

