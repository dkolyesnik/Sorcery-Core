package;
import sorcery.core.HandlerData;
import sorcery.core.interfaces.ICommand;
import sorcery.core.interfaces.ICommandManager;
import sorcery.core.interfaces.IEvent;

/**
 * ...
 * @author Dmitriy Kolesnik
 */

 /* the main idea behind this is to be able to somehow work with command and results of command
  * i.e. count how many times it is executed or limit it's execution by some sort of rule
  * or remove command under some conditions
  * i.e.:
  * Call N times and then remove command
  * Call every 5 events
  * Call only if some property of the event is matche some rules, i.e event.size > 5
  * 
  * This way we could have a set of commands and this rules that impact their execution
  * 
  * another name CommandRule 
  * rule can be done the other way. Make SimpleCommand (Command) 
  * and CommandWithRules witch would have rules that will be called befor to verify if
  * we can call command 
  * and after to do some-thing
  * Rules can be used even as some sort of adapter to adapt event to other type of
  * event
  * */
class CommandWrapper extends HandlerData implements ICommand
{
	var _command:ICommand;
	public function new(command:ICommand) 
	{
		super();
		_command = command;
	}
	
	function setManager(manager:ICommandManager):Void 
	{
		_command.setManager(manager);
	}
	
	function getHandler():HandlerData 
	{
		return this;
	}
	
	override public function activate(event:IEvent):Void 
	{
		//override to do some-thing here
		_command.getHandler().activate(event:IEvent)
		//or here
	}
	
	function clearManager():Void {
		
	}
	
}