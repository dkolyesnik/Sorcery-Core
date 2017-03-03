/**
 * Created by Dmitriy Kolesnik on 02.08.2016.
 */
package sorcery.core.interfaces;

interface ITime
{
	@:property
	var dt(get, null) : Float;
	@:property
	var fps(get, null) : Int;
	@:property
	var isStarted(get, null) : Bool;
	@:property
	var timeScale(get, set) : Float;
	@:property
	var lifeTime(get, null) : Float;
	
	function start():Void;
	function stop():Void;
	function update():Void;
}

