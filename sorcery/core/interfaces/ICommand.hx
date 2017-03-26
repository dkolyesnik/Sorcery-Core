package sorcery.core.interfaces;
import sorcery.core.HandlerData;

/**
 * @author Dmitriy Kolesnik
 */
@:allow(sorcery.core.interfaces.ICommandManager)
interface ICommand
{
	private function setManager(manager:ICommandManager):Void;
	private function clearManager():Void;
	private function getHandler():HandlerData;
}