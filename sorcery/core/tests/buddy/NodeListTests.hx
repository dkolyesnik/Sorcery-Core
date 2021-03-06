package sorcery.core.tests.buddy;

import buddy.SingleSuite;
import sorcery.core.Core;
import sorcery.core.SystemNode;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.ISystemNode;
import sorcery.core.misc.NodeList;
using buddy.Should;
using Lambda;
/**
 * ...
 * @author Dmitriy Kolesnik
 */
#if TESTS
@:access(sorcery.core.BaseSystem)
@:access(sorcery.core.SystemNode)
@:access(sorcery.core.misc.NodeList)
class NodeListTests extends SingleSuite
{
	var nodeList:NodeList;
	public function new()
	{
		super();

		describe("NodeList",
		{
			beforeEach({
				nodeList = new NodeList();
			});

			it("Should emit signal when node added", {
				var core = new Core();
				var testNode = new TestNode(core);
				nodeList.onAdd.connect(function(n:ISystemNode)
				{
					n.should.be(testNode);
				});
				nodeList.add(testNode);
			});

			it("Should emit signal when node removed", {
				var core = new Core();
				var testNode = new TestNode(core);
				nodeList.onRemove.connect(function(n:ISystemNode)
				{
					n.should.be(testNode);
				});
				nodeList.add(testNode);
				nodeList.remove(testNode);
			});

			it("Should add nodes and all nodes must be avaliable for iteration", {
				var core = new Core();
				for (i in 0...10)
					nodeList.add(new TestNode(core, i));

				nodeList.length.should.be(10);
				var testNode:TestNode;
				testNode = cast nodeList.head;
				var i = 0;
				while (testNode != null)
				{
					testNode.num.should.be(i);
					testNode = testNode.next != null ? cast testNode.next : null;
					i++;
				}
				i.should.be(10);
			});

			it("Should work correstly after removing the node", {
				var core = new Core();
				var nodeToRemove = new TestNode(core, 5);
				for (i in 0...10)
					if (i == nodeToRemove.num)
						nodeList.add(nodeToRemove);
					else
						nodeList.add(new TestNode(core, i));

				nodeList.length.should.be(10);

				nodeList.remove(nodeToRemove);
				nodeList.length.should.be(9);

				var testNode:TestNode;
				testNode = cast nodeList.head;
				var i = 0;
				while (testNode != null)
				{
					testNode.num.should.be(i);
					testNode = testNode.next != null ? cast testNode.next : null;
					i++;
					if (i == 5) i++;
				}
				i.should.be(10);
			});

			it("Should work correctly after removing first node", {
				var core = new Core();
				var nodeToRemove = new TestNode(core, 0);
				nodeList.add(nodeToRemove);
				for (i in 1...10)
					nodeList.add(new TestNode(core, i));

				nodeList.length.should.be(10);

				nodeList.remove(nodeToRemove);
				nodeList.length.should.be(9);

				var testNode:TestNode;
				testNode = cast nodeList.head;
				var i = 1;
				testNode.num.should.be(1);
				while (testNode != null)
				{
					testNode.num.should.be(i);
					testNode = testNode.next != null ? cast testNode.next : null;
					i++;
				}
				i.should.be(10);
			});
			it("Should work correctly after removing the last node", {
				var core = new Core();
				var nodeToRemove = new TestNode(core, 9);
				for (i in 0...9)
					nodeList.add(new TestNode(core, i));
				nodeList.add(nodeToRemove);

				nodeList.length.should.be(10);

				nodeList.remove(nodeToRemove);
				nodeList.length.should.be(9);

				var testNode:TestNode;
				testNode = cast nodeList.head;
				var i = 0;
				while (testNode != null)
				{
					testNode.num.should.be(i);
					testNode = testNode.next != null ? cast testNode.next : null;
					i++;
				}
				i.should.be(9);
			});
			it("Should work correctly after removing all nodes and filling list again", {
				var core = new Core();
				var addedNodes = [];
				for (i in 0...10)
				{
					var n1 = new TestNode(core, i);
					addedNodes.push(n1);
					nodeList.add(n1);
				}
				nodeList.length.should.be(10);

				//remove all added nodes
				addedNodes = Random.shuffle(addedNodes);
				for (n in addedNodes)
				{
					nodeList.remove(n);
				}

				//fill again
				for (i in 20...30)
				{
					nodeList.add(new TestNode(core, i));
				}

				var testNode:TestNode;
				testNode = cast nodeList.head;
				var i = 20;
				while (testNode != null)
				{
					testNode.num.should.be(i);
					testNode = testNode.next != null ? cast testNode.next : null;
					i++;
				}
				i.should.be(30);
			});
		});
	}

}

class TestNode extends SystemNode
{
	public var num:Int;
	public function new(p_core:ICore, num:Int = 0)
	{
		super(p_core);
		this.num = num;
	}
}
#end