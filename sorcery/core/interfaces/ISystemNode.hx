package sorcery.core.interfaces;
import sorcery.core.misc.NodeIterator;
import sorcery.core.misc.NodeList;

/**
 * @author Dmitriy Kolyesnik
 */
@:allow(sorcery.core.misc.NodeList)
@:allow(sorcery.core.misc.NodeIterator)
interface ISystemNode extends IBehavior
{
	@:property
	var nodeName(get, null):String;
	@:property
	private var list(get, null):NodeList;
	@:property
	private var next(get, null):ISystemNode;
	@:property
	private var prev(get, null):ISystemNode;
	
	function prepare():Bool;
	function unprepare():Void;
}