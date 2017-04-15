package sorcery.core.tests.buddy;

import buddy.SingleSuite;
import sorcery.core.Behavior;
import sorcery.core.Command;
import sorcery.core.CommandManager;
import sorcery.core.Component;
import sorcery.core.Core;
import sorcery.core.Event;
import sorcery.core.abstracts.EventType;
import sorcery.core.interfaces.ICommand;
import sorcery.core.interfaces.ICommandManager;
import sorcery.core.interfaces.IComponent;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.IEntity;
using buddy.Should;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
@:access(sorcery.core.CommandManager)
@:access(sorcery.core.Command)
class CommandsTests extends SingleSuite
{
	var core:ICore;
	var commandManager:ICommandManager;
	var command:ICommand;
	var commandWithInjects:TestCommandWithInjectedFields;
	public var isCalled = false;
	
	//TODO create core and everything else for each test
	/*
	 * Notice - objects created in beforAll will be null in other describes even if they are fiels of this test
	*/
	public function new() 
	{
		super();
		describe("Commands and CommandManager workflow", {
			core = new Core();
			commandManager = new CommandManager(core);
			command = new TestCommand(TestEvent.TEST, this);
			core.root.addChild(cast commandManager);
			var gameEnt = core.allocateEntity("game");
			gameEnt.addChild(new Component(core)).setName("comp");
			core.root.addChild(gameEnt);
			var gr = core.wrapInGroup(core.allocateEntity("gr"));
			var ent = core.allocateEntity("ent");
			gr.addChild(ent);
			core.root.addChild(gr);
			//beforeAll({
				//
			//});
			
			beforeEach({
				this.isCalled = false;
			});
			
			it("Should allow CommandManager to add Commands", {
				var cm:CommandManager = cast commandManager;
				var prefNum = cm._handlers.length;
				this.commandManager.addCommand(command);
				cm._handlers.length.should.be(prefNum + 1);
			});
			
			it("CommandManager must pass itself and a command must get link from it for subscribing to event into the command", {
				var c:Command<TestEvent> = cast command;
				c._manager.should.be(commandManager);
				c._link.should.not.be(null);
			});
			
			it("Commands must be activated when event to commandManager parent is triggered", {
				core.root.sendEvent(new TestEvent(TestEvent.TEST));
				isCalled.should.be(true);
			});
			
			describe("Commands should inject fields before execution and be executed only if all required fields are injected", {
				var game2:IEntity;
				var compFromGame = new Component(core);
				var compFromGame2 = new Component(core);
				var behaviorFromGame2 = new Behavior(core);
				var compWithInterface  = new ComponentWithSomeInterface(core);
				gameEnt.addChild(compFromGame.setName("comp"));
				game2 = core.allocateEntity("game2");
				game2.addChild(compFromGame2.setName("comp"));
				game2.addChild(behaviorFromGame2.setName("beh"));
				core.root.addChild(compWithInterface.setName("compI"));
				core.root.addChild(game2);
				this.commandWithInjects = new TestCommandWithInjectedFields(TestEvent.TEST2, this);
				this.commandManager.addCommand(commandWithInjects);
				//beforeAll({
					//
				//});
				beforeEach({ 
					this.isCalled = false; 
				});
				it("Should inject components and entities from links and cast it to field type", {
					core.root.sendEvent(new TestEvent(TestEvent.TEST2, function (c:Any, e:Any){
						var testedCommand:TestCommandWithInjectedFields = cast c;
						testedCommand.compFromGame2.should.be(compFromGame2);
						testedCommand.compFromGame.should.be(compFromGame);
						testedCommand.behaviorFromGame2.should.be(behaviorFromGame2);
						testedCommand.someInterfaceFromRoot.should.be(compWithInterface);
						testedCommand.someEntity.should.be(ent);
					}));
					isCalled.should.be(true);
				});
				
				it("Should clear injected fields after execution", {
					this.commandWithInjects.compFromGame.should.be(null);
					this.commandWithInjects.compFromGame2.should.be(null);
					this.commandWithInjects.behaviorFromGame2.should.be(null);
					this.commandWithInjects.someInterfaceFromRoot.should.be(null);
				});
				
				it("Command should be executed if field that is not requred is not injected", {
					game2.removeChild(compFromGame2);
					core.root.sendEvent(new TestEvent(TestEvent.TEST2, function (c:Any, e:Any){
						var event = e;
						(event != null).should.be(true);
							
						var testedCommand:TestCommandWithInjectedFields = cast c;
						testedCommand.compFromGame2.should.be(null);
						testedCommand.compFromGame.should.be(compFromGame);
						testedCommand.behaviorFromGame2.should.be(behaviorFromGame2);
						testedCommand.someInterfaceFromRoot.should.be(compWithInterface);
					}));
					isCalled.should.be(true);
					game2.addChild(compFromGame2);
					game2.removeChild(behaviorFromGame2);
					core.root.sendEvent(new TestEvent(TestEvent.TEST2, function (c:Any, e:Any){
						var testedCommand:TestCommandWithInjectedFields = cast c;
						testedCommand.compFromGame2.should.be(compFromGame2);
						testedCommand.compFromGame.should.be(compFromGame);
						testedCommand.behaviorFromGame2.should.be(null);
						testedCommand.someInterfaceFromRoot.should.be(compWithInterface);
					}));
					isCalled.should.be(true);
					game2.removeChild(compFromGame2);
					core.root.sendEvent(new TestEvent(TestEvent.TEST2, function (c:Any, e:Any){
						var testedCommand:TestCommandWithInjectedFields = cast c;
						testedCommand.compFromGame2.should.be(null);
						testedCommand.compFromGame.should.be(compFromGame);
						testedCommand.behaviorFromGame2.should.be(null);
						testedCommand.someInterfaceFromRoot.should.be(compWithInterface);
					}));
					isCalled.should.be(true);
				});
				
				it("Command should not be executed if one of the requred fields is not injected", {
					core.root.removeChild(compWithInterface);
					core.root.sendEvent(new TestEvent(TestEvent.TEST2));
					isCalled.should.be(false);
					game2.addChild(compFromGame2);
					game2.addChild(behaviorFromGame2);
					core.root.sendEvent(new TestEvent(TestEvent.TEST2));
					isCalled.should.be(false);
				});
				
				
			});
			
		});
	}
	
}

private class TestEvent extends Event
{
	public static var TEST = new EventType<TestEvent>("test"); 
	public static var TEST2 = new EventType<TestEvent>("test2"); 
	public var testFunc:Any->Any->Void;
	public function new(p_type:EventType<TestEvent>, testFunc:Any->Any->Void = null){
		super(p_type);
		this.testFunc = testFunc;
	}
}

private class TestCommand extends Command<TestEvent>
{
	var _comTests:CommandsTests;
	public function new(p_type:EventType<TestEvent>, commandsTest:CommandsTests)
	{
		super(p_type);
		_comTests = commandsTest;
	}
	
	override function execute(e:TestEvent):Void 
	{
		_comTests.isCalled = true;
		if (e.testFunc != null)
			e.testFunc(this, e);
	}
}

private class TestCommandWithInjectedFields extends TestCommand
{
	@:sorcery_inject("@.game2:comp", false)
	public var compFromGame2:IComponent;
	
	@:sorcery_inject("#.game:comp", true)
	public var compFromGame:Component;
	
	@:sorcery_inject("#.game2:beh")
	public var behaviorFromGame2:Behavior;
	
	@:sorcery_inject("#:compI", true)
	public var someInterfaceFromRoot:ISomeInterface;
	
	@:sorcery_inject("#.gr.ent", false)
	public var someEntity:IEntity;
	
	override function execute(e:TestEvent):Void 
	{
		_comTests.isCalled = true;
		if (e.testFunc != null)
			e.testFunc(this,e);
	}
}

private class ComponentWithSomeInterface extends Component implements ISomeInterface
{
	public function doSome():Void{
		
	}
}

private interface ISomeInterface
{
	function doSome():Void;
}