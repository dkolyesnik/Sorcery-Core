package sorcery.core.interfaces;
import sorcery.core.abstracts.Path;

/**
 * @author Dmitriy Kolesnik
 */
interface ICommandManager 
{
	var core(get, null):ICore;
	
	function addCommand(command:ICommand):ICommand;
	@:allow(sorcery.core.interfaces.ICommand)
	private function getLink(path:Path):IEntityChildLink;
	@:allow(sorcery.core.interfaces.ICommand)
	private function returnLink(link:IEntityChildLink):Void;
}