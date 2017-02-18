package sorcery.core.interfaces;

/**
 * @author Dmitriy Kolyesnik
 */
@:allow(sorcery.core.interfaces.IBehavior)
interface ILinkInternal 
{
	function destroy():Void;
	private function resolve():Void;
	private function reset():Void;
}