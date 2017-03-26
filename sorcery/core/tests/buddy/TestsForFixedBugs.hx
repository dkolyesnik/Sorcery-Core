package sorcery.core.tests.buddy;

import buddy.SingleSuite;
import sorcery.core.Component;
import sorcery.core.Core;
import sorcery.core.abstracts.Path;
import sorcery.core.abstracts.Path.*;
using buddy.Should;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
class TestsForFixedBugs extends SingleSuite
{

	public function new() 
	{
		super();
		
		describe("Bug - removed child did not remove itself from the map of children by fullName", {
			var core = new Core();
			var entity = core.allocateEntity("entity");
			var child = new Component(core).setName("comp");
			var childEntity = core.allocateEntity("child");
			var subChild = new Component(core).setName("subComp");
			var compFullName = ROOT + TO_GROUP + "entity" + TO_COMPONENT + "comp";
			var childFullName = ROOT + TO_GROUP + "child";
			var subChildFullName = ROOT + TO_GROUP + "child" + TO_COMPONENT +"subComp";
			entity.addChild(child);
			entity.addChild(childEntity);
			childEntity.addChild(subChild);
			core.root.addChild(entity);
			
			it("Should find component by full name", {
				var foundChild = core.root.findChildByFullName(compFullName);
				foundChild.should.be(child);
			});
			it("Should find child entity by full name", {
				var foundChild = core.root.findChildByFullName(childFullName);
				foundChild.should.be(childEntity);
			});
			it("Should find child of the entity by full name", {
				var foundChild = core.root.findChildByFullName(subChildFullName);
				foundChild.should.be(subChild);
			});
			it("Should not find component by full name if component is removed", {
				entity.removeChild(child);
				var foundChild = core.root.findChildByFullName(compFullName);
				foundChild.should.be(null);
			});
			it("Should not find entity and it's children if entity is removed", {
				entity.removeChild(childEntity);
				var foundChild = core.root.findChildByFullName(childFullName);
				foundChild.should.be(null);
				foundChild = core.root.findChildByFullName(subChildFullName);
				foundChild.should.be(null);
			});
			
		});
	}
	
}