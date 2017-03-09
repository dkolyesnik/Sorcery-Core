package sorcery.core.tests.hunit.roughTests;

import sorcery.core.Component;
import sorcery.core.interfaces.ICore;
import hunit.TestCase;

/**
 * ...
 * @author Dmitriy Kolyesnik
 */
@:access(sorcery.core.Entity)
class AgendaTests extends TestCase
{

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
	public function testAgendaManager()
	{
		var game = core.allocateEntity("game");
		var gameComp1:TestFocusComponent = cast new TestFocusComponent(core).setName("gc1").addAgenda("ga1");
		game.addChild(gameComp1);
		var gameComp2:TestFocusComponent = cast new TestFocusComponent(core).setName("gc2").addAgenda("ga2");
		game.addChild(gameComp2);
		
		var player = core.allocateEntity("player");
		var playerComp1:TestFocusComponent = cast new TestFocusComponent(core).setName("pc").addAgenda("pa1");
		player.addChild(playerComp1);
		var playerComp2:TestFocusComponent = cast new TestFocusComponent(core).setName("pc").addAgenda("pa2");
		player.addChild(playerComp2);
		var playerAlwaysComp:TestFocusComponent = cast new TestFocusComponent(core).setName("pca");
		player.addChild(playerAlwaysComp);
		
		game.addChild(player);
		
		core.root.addChild(game);
		
		//testing switching agenda 
		/*
		 * current state:
		 * game should be active and components not
		 * */
		assert.isTrue(game.isActivated(), "game is not active");
		assert.isFalse(gameComp1.isActivated(), "gameComponent1 is active");
		assert.isTrue(gameComp1.useCountForTest() == 0, "gameComponent1 use count is changed"); 
		assert.isFalse(gameComp2.isActivated(), "gameComponent2 is active");
		assert.isTrue(gameComp2.useCountForTest() == 0, "gameComponent2 use count is changed");
		
		//player should be active because he has no agenda and it works as agenda ALWAYS
		// but players components are not active except playerAlwaysComp;
		assert.isTrue(player.isActivated(), "player should be active");
		assert.isFalse(playerComp1.isActivated(), "playerComp1 shoul not be active");
		assert.isFalse(playerComp2.isActivated(), "playerComp2 shoul not be active");
		assert.isTrue(playerAlwaysComp.isActivated(), "playerAlwaysComp should be active");
		assert.isTrue(playerAlwaysComp.isFocused, "playerAlwaysComp should be focused");
		assert.isTrue(playerAlwaysComp.focusAgenda == BaseAgenda.ALWAYS, "playerAlwaysComp focus agenda should be BaseAgenda.ALWAYS");
		
		
		game.agenda.swap("ga1");
		//switched game agenda to ga1
		notice("switching game agenda to ga1");
		notice("gameComp1 should be active and focused with focused agenda ga1 and use count is 1");
		assert.isTrue(gameComp1.isActivated(), "gameComp1 is not active after agenda swithc");
		assert.isTrue(gameComp1.isFocused, "gameComp1 is not focused");
		assert.isTrue(gameComp1.focusAgenda == "ga1", "gameComp1 has wrong focus agenda");
		assert.isTrue(gameComp1.useCountForTest() == 1, "wrong use count");
		//gameComp2 should be not active
		assert.isFalse(gameComp2.isActivated(), "gameComp2 is active");
		//plyaer should still be active
		assert.isTrue(player.isActivated(), "player is not active after agenda switch");
		//player's components should still at the same state
		assert.isFalse(playerComp1.isActivated() && playerComp2.isActivated() && !playerAlwaysComp.isActivated(), "player components are activated after agenda switch");
		
		game.agenda.swap("ga2");
		//switched game agenda to ga2
		notice("switching game agenda to ga2");
		//gameComp1 should be active
		assert.isTrue(gameComp2.isActivated(), "gameComp2 is not active after agenda swithc");
		assert.isTrue(gameComp2.useCountForTest() == 1, "wrong use count");
		assert.isTrue(gameComp2.isFocused);
		//gameComp2 should be not active
		assert.isFalse(gameComp1.isActivated(), "gameComp1 is active");
		assert.isFalse(gameComp1.isFocused);
		assert.isTrue(gameComp1.useCountForTest() == 0);
		
		game.agenda.show("ga1");
		notice("show game agenda ga1");
		notice("gameComp1 should be active and focused");
		assert.isTrue(gameComp1.isActivated(), "gameComp1 is not active after agenda show");
		assert.isTrue(gameComp1.useCountForTest() == 1);
		assert.isTrue(gameComp1.isFocused, "gameComp1 is not focused");
		notice("gameComp1 should be focused");
		
		notice("gameComp2 should be still active");
		assert.isTrue(gameComp2.isActivated(), "gameComp2 is not active");
		assert.isTrue(gameComp2.useCountForTest() == 1);
		
		game.agenda.hideAll();
		notice("hide all game agenda");
		notice("gameComp1 should not be active");
		assert.isFalse(gameComp2.isActivated(), "gameComp2 is active after agenda hideAll");
		assert.isTrue(gameComp2.useCountForTest() == 0);
		notice("gameComp2 should be not active");
		assert.isFalse(gameComp1.isActivated(), "gameComp1 is active after agenda hideAll");
		assert.isTrue(gameComp1.useCountForTest() == 0);
		
		notice("show all game agenda again and hide all except ga1");
		game.agenda.show("ga1").show("ga2").hideAll("ga1");
		notice("gameComp1 should be active");
		assert.isTrue(gameComp1.isActivated(),  "gameComp1 is not active");
		notice("gameComp2 should not be active");
		assert.isFalse(gameComp2.isActivated(),  "gameComp2 is active");
		
		notice("show all game agenda again and hide by ga1");
		game.agenda.show("ga1").show("ga2");
		game.agenda.hide("ga1");
		notice("gameComp2 should be active");
		assert.isTrue(gameComp2.isActivated(),  "gameComp2 is not active");
		notice("gameComp1 should not be active");
		assert.isFalse(gameComp1.isActivated(),  "gameComp1 is active");
		
		
		notice("show all game agenda again and hide current = ga1");
		game.agenda.hideAll().show("ga2").show("ga1").hide();
		notice("gameComp2 should be active");
		assert.isTrue(gameComp2.isActivated(),  "gameComp2 is not active");
		notice("gameComp1 should not be active");
		assert.isFalse(gameComp1.isActivated(),  "gameComp1 is active");
		
		notice("searching for component named 'pca', playerAlwaysComp should be found");
		assert.isTrue(player.findChild("pca") == playerAlwaysComp);
		assert.isTrue(core.root.findChildByFullName("#.player:pca") == playerAlwaysComp);
		notice("switching player agenda to pa1");
		player.agenda.swap("pa1");
		notice("playerComp1 should be found");
		assert.isTrue(player.findChild("pc") == playerComp1);
		assert.isTrue(core.root.findChildByFullName("#.player:pc") == playerComp1);
		assert.isTrue(playerComp1.isActivated(), "playerComp1 should be active");
		assert.isTrue(playerAlwaysComp.isActivated(), "playerAlwaysComp should be active");
		
		//notice("activaiting pa2 agenda, should replace pa1");
		//expectException(Entity.DUPLICATED_CHILD_NAME_EXCEPTIOM);
		//player.agenda.show("pa2");
		
		//assert.isTrue(!playerComp1.isActivated() && playerComp2.isActivated(), "fail");
		
		//notice("hide all, should activate always again");
		//player.agenda.hideAll();
		//assert.isTrue(playerAlwaysComp.isActivated() && !playerComp1.isActivated() && !playerComp2.isActivated(), "fail");
		
	
		
		
		
	}

	override public function tearDownTestCase():Void
	{
		core = null;
	}
}

class TestFocusComponent extends Component
{
	public var isFocused = false;
	public var focusAgenda:String = "";
	public var lostFocusAgenda = "";
	override function onFocus():Void 
	{
		isFocused = true;
		focusAgenda = parent.agenda.getCurrentAgenda();
	}
	
	override function onLostFocus():Void 
	{
		isFocused = false;
		lostFocusAgenda = parent.agenda.getCurrentAgenda();
	}
	
	public function useCountForTest():Int
	{
		return getUseByAgendaCount();
	}
}