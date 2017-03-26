package sorcery.core;

import sorcery.core.Behavior;
import sorcery.core.abstracts.Path;
import sorcery.core.interfaces.ICommand;
import sorcery.core.interfaces.ICommandManager;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.IEntityChildLink;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
class CommandManager extends Behavior implements ICommandManager
{
	public function new(p_core:ICore)
	{
		super(p_core);
	}

	public function addCommand(command:ICommand):ICommand
	{
		//TODO somehow do this without casting
		command.setManager(this);

		addHandler(command.getHandler());
		return command;
	}

	function getLink(path:Path):IEntityChildLink
	{
		return createLink(path);
	}
	
	function returnLink(link:IEntityChildLink):Void
	{
		destroyLink(link);
	}
}