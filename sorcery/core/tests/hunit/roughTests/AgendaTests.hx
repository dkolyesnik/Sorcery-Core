package sorcery.core.tests.hunit.roughTests;

import sorcery.core.Component;
import sorcery.core.interfaces.ICore;
import hunit.TestCase;

/**
 * ...
 * @author Dmitriy Kolyesnik
 */
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
		var gameComp1 = new Component(core);
		gameComp1.setName("gc1");
		gameComp1.addAgenda("ga1");
		game.addChild(gameComp1);
		var gameComp2 = new Component(core);
		gameComp2.setName("gc2");
		gameComp2.addAgenda("ga2");
		game.addChild(gameComp2);
		
		var player = core.allocateEntity("player");
		var playerComp1 = new Component(core);
		playerComp1.setName("pc");
		playerComp1.addAgenda("pa1");
		player.addChild(playerComp1);
		var playerComp2 = new Component(core);
		playerComp2.setName("pc");
		playerComp2.addAgenda("pa2");
		player.addChild(playerComp2);
		var playerAlwaysComp = new Component(core);
		playerAlwaysComp.setName("pc");
		player.addChild(playerAlwaysComp);
		
		game.addChild(player);
		
		core.root.addChild(game);
		
		//testing switching agenda 
		/*
		 * current state:
		 * game should be active and components not
		 * */
		assert.isTrue(game.isActive(), "game is not active");
		assert.isFalse(gameComp1.isActive(), "gameComponent1 is active");
		assert.isFalse(gameComp2.isActive(), "gameComponent2 is active");
		
		//player should be active because he has no agenda info it works as agenda ALWAYS
		// but players components are not active
		assert.isTrue(player.isActive(), "player is not active");
		assert.isFalse(playerComp1.isActive(), "playerComp1 is active");
		assert.isFalse(playerComp2.isActive(), "playerComp2 is active");
		assert.isTrue(playerAlwaysComp.isActive(), "playerAlwaysComp is not active");
		
		
		game.agenda.swap("ga1");
		//switched game agenda to ga1
		notice("switching game agenda to ga1");
		//gameComp1 should be active
		assert.isTrue(gameComp1.isActive(), "gameComp1 is not active after agenda swithc");
		//gameComp2 should be not active
		assert.isFalse(gameComp2.isActive(), "gameComp2 is active");
		//plyaer should still be active
		assert.isTrue(player.isActive(), "player is not active after agenda switch");
		//player's components should still at the same state
		assert.isFalse(playerComp1.isActive() && playerComp2.isActive() && !playerAlwaysComp.isActive(), "player components are activated after agenda switch");
		
		notice("switching player agenda to pa1");
		player.agenda.swap("pa1");
		notice("playerComp1 should replace playerAlwaysComp");
		assert.isTrue(playerComp1.isActive() && !playerAlwaysComp.isActive(), "playerAlwaysComp is not replaced");
		
		notice("activaating pa2 agenda, should replace pa1");
		player.agenda.show("pa2");
		assert.isTrue(!playerComp1.isActive() && playerComp2.isActive(), "fail");
		
		notice("hide all, should activate always again");
		player.agenda.hideAll();
		assert.isTrue(playerAlwaysComp.isActive() && !playerComp1.isActive() && !playerComp2.isActive(), "fail");
		
	
		
		
		
	}

	override public function tearDownTestCase():Void
	{
		core = null;
	}
}