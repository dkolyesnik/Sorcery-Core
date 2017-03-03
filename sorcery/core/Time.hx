/**
 * Created by Dmitriy Kolesnik on 07.08.2016.
 */
package sorcery.core;

import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.IEntity;
import sorcery.core.interfaces.ITime;

class Time implements ITime
{
	public var MAX_DELTA_TIME : Float = 0.05;

	@:property
	public var fps(get, null) : Int = 0;
	@:property
	public var dt(get, null) : Float = 0.0;
	@:property
	public var isStarted(get, null) : Bool = true;
	@:property
	public var timeScale(get, set) : Float;
	var _timeScale = 1.0;
	@:property
	public var lifeTime(get, null) : Float = 0.0;

	var _core : ICore;

	var _lastTime = 0;
	var _prevFrameTime = 0;
	var _framesCount = 0;

	public function new(p_core : ICore)
	{
		_core = p_core;
	}

	public function start() : Void
	{
		if (isStarted)
		{
			return;
		}

		_prevFrameTime = _lastTime = Math.round(haxe.Timer.stamp() * 1000);
		isStarted = true;
	}

	public function stop() : Void
	{
		if (!isStarted)
		{
			return;
		}

		isStarted = false;

	}

	public function update() : Void
	{
		if (!isStarted)
			return;

		var curTime : Int = Math.round(haxe.Timer.stamp() * 1000);
		dt = (curTime - _prevFrameTime) / 1000.0;

		lifeTime += dt;

		if (dt > MAX_DELTA_TIME)
		{
			dt = MAX_DELTA_TIME;
		}

		_prevFrameTime = curTime;

		dt *= _timeScale;

		var ent:IEntity = cast _core.root;
		ent.sendEvent(CoreEvent.coreUpdateEvent);

		_framesCount++;
		if (curTime - _lastTime > 1000)
		{
			fps = _framesCount;
			_framesCount = 0;
			_lastTime = curTime;
		}
	}

	private function set_timeScale(value : Float) : Float
	{
		if ((value != 0 && !Math.isNaN(value)) && value >= 0.1 && value <= 5)
		{
			_timeScale = value;
		}
		return _timeScale;
	}
	
	function get_fps():Int 
	{
		return fps;
	}
	
	function get_dt():Float 
	{
		return dt;
	}
	
	function get_isStarted():Bool 
	{
		return isStarted;
	}
	
	function get_timeScale():Float 
	{
		return _timeScale;
	}
	
	function get_lifeTime():Float 
	{
		return lifeTime;
	}

}

