package sorcery.core.tests.hunit.roughTests;

import sorcery.core.abstracts.FullName;
import sorcery.core.abstracts.Path;
import hunit.TestCase;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
class TestNamesValidation extends TestCase
{

	public function new() 
	{
		super();
		
	}

	@test
	public function testNamesValidation()
	{
		var ereg = FullName.EREG;
		
		assert.isTrue(FullName.validate("#.game.player.gun:comp"));
		assert.isTrue(FullName.validate("#.game.player"));
		assert.isFalse(FullName.validate("#.game."));
		return;
		
	}
	
	@test
	public function testPathValidation()
	{
		assert.isTrue(Path.validate("#"));
		assert.isTrue(Path.validate("#.ad"));
		assert.isTrue(Path.validate("#:ad"));
		assert.isTrue(Path.validate("#.game.player.gun:comp"));
		assert.isTrue(Path.validate("#.game.player.gun"));
		
		assert.isFalse(Path.validate("#.game.player.gun."));
		assert.isFalse(Path.validate("#.game.$player:gun"));
		
		
		assert.isTrue(Path.validate("adf"));
		assert.isTrue(Path.validate("@@adf"));
		assert.isTrue(Path.validate(":adf"));
		assert.isTrue(Path.validate("@:adf"));
		assert.isTrue(Path.validate("@"));
		assert.isTrue(Path.validate("@@"));
		
		assert.isFalse(Path.validate("@@asd.ad"));
		assert.isFalse(Path.validate("@a@"));
		assert.isFalse(Path.validate("a12.ad")); //must be ".a12.ad"
		
		
		assert.isTrue(Path.validate("...asd"));
		assert.isTrue(Path.validate("...:asd"));
		assert.isTrue(Path.validate("...asda:asd"));
		
		assert.isFalse(Path.validate("...#.:asd"));
		assert.isFalse(Path.validate(".:asd.ads"));
	}
}