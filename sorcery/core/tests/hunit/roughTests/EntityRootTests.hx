package sorcery.core.tests.hunit.roughTests;
import sorcery.core.Behavior;
import sorcery.core.Component;
import sorcery.core.Core;
import sorcery.core.Event;
import sorcery.core.TypedHandlerData;
import sorcery.core.abstracts.EventType;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.IEntityChild;
import sorcery.core.tools.EntityTools;
import hunit.TestCase;

/**
 * ...
 * @author Dmitriy Kolyesnik
 */
class EntityRootTests extends TestCase
{
	public static var CLICK = new EventType<SomeEvent>("click");

	public function new()
	{
		super();
	}

	var core:ICore;

	override public function setupTestCase():Void
	{
		core = Test.createCore();
	}

	@:access(sorcery.core.Component)
	@test
	public function simpleIntegrationTest()
	{
		var gameGroup = core.wrapInGroup(core.allocateEntity("game"));
		core.root.addChild(gameGroup);
		
		var child1 = core.allocateEntity("child1");
		gameGroup.addChild(child1);
		
		var playerGroup = core.wrapInGroup(core.allocateEntity("player"));
		child1.addChild(playerGroup);
		
		var gunEntity = core.allocateEntity("gun");
		playerGroup.addChild(gunEntity);
		
		var cmp = new Behavior(core);
		cmp.setName("comp");
		gunEntity.addChild(cmp);
		
		var link = cmp.createLink("#.game.player.gun:comp");
		var parentLink = cmp.createLink('@');
		
		var finded:IEntityChild = null; 
		
		
		assert.isTrue(cmp.isAddedToRoot(), "comp should be added to root");
		
		assert.equal(link.fullName, "#.game.player.gun:comp", "link's full name is not valid");
		assert.equal(parentLink.fullName, "#.game.player.gun", "parentLink full name is wrong");
		

		finded = core.root.findChildByFullName("#.game.child1");
 		assert.equal(finded, child1, "child1 is not found");

		
		finded = core.root.findChildByFullName("#.game.player.gun");
		assert.equal(finded, gunEntity, "gun is not found");
		

		finded =  link.find();
		assert.equal(finded, cmp, "comp should be found by link");

		var gunFullName = gunEntity.fullName;
		assert.equal(gunFullName, "#.game.player.gun", "gun has a wrong full name, full name = " + gunFullName);
		
		var behavior = new MyBehavior(core, new TypedHandlerData<SomeEvent>(CLICK, cmp.createLink("#"), function(e:SomeEvent) { assert.equal(e.some , "some", "event some is not recieved" ); }));
		gunEntity.addChild(behavior);
		core.root.sendEvent(new SomeEvent(CLICK));
		
	}
	
	@test
	public function testEntityToolsValidation()
	{
		var parent = core.allocateEntity("parent");
		var child = core.allocateEntity("child");
		parent.addChild(child);
		assert.isFalse(EntityTools.checkWhetherChildCanBeAdded(child, parent));
	}

	override public function tearDownTestCase():Void
	{

		core = null;
	}

	
}

class MyBehavior extends Behavior
	{
		public function new(p_core:ICore, handler)
		{
			super(p_core);
			addHandler(handler);
		}

		//override public function onAddedToRoot():Void
		//{
			//trace("added");
			//super.onAddedToRoot();
		//}
	}
class SomeEvent extends Event
{
	public var some = "some";

	public function new(p_type:String) 
	{
		super(p_type);
		
	}
	
}