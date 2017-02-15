package sorcery.core.macros;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.FieldType;
using haxe.macro.ExprTools;
/**
 * ...
 * @author Dmitriy Kolyesnik
 */
#if macro
typedef Node = {varName:String, nodeType:TypeParam, nodeName:String, needToPrepare:Bool};
class BaseSystemBuildMacro
{
	static var _metadataName = ":sorcery_node";
	static var _createNodesName = "_createNodeListLinks";
	static var _getNodesName = "_getNodeLists";
	static var _releaseNodesName = "_releaseNodeLists";
	static var nodeListLinkClass = "NodeListLink";
	static var baseSystemClass = "BaseSystem";
	static var nodeListLinkPackage = ["sorcery", "core", "misc"];
	
	static public macro function build():Array<Field>
	{
		log("processing "+ Context.getLocalClass().get().name);
		
		var fields = Context.getBuildFields();
		//TODO find fiels with NodeListLinks, add initialization, getting NodeLists and clearing NodeLists
		var nodes:Array<Node> = [];
		var createNodesFunc:Field;
		var getNodesFunc:Field;
		var releaseNodesFunc:Field;
		var typeName;
		
		var findNode = function (t:Null<ComplexType>, e:Null<Expr>, f:Field, nodeName:String, prepare:Bool)
		{
			if (t != null && nodeName != "")
			{
				switch(t) 
				{
					case ComplexType.TPath(p):
						if (p.name == nodeListLinkClass && p.params != null && p.params.length > 0)
						{
							nodes.push ( {
									varName: f.name,
									nodeType: p.params[0],
									nodeName: nodeName,
									needToPrepare: prepare
								});
							log("			node created " + nodes[nodes.length - 1]);
						}
					default:
				}
			}
		}
		
		for (f in fields)
		{
			log("		took field " + f.name);
			var nodeName = "";
			var needToPrepare = false;
			if (f.meta != null)
			{
				log("			has meta");
				for (m in f.meta)
				{
					log("				meta name = " + m.name);
					if (m.name == ":sorcery_node")
					{
						nodeName = m.params.length > 0 ? m.params[0].getValue() : "";
						log('					param = $nodeName');
						needToPrepare = m.params.length > 1 ? m.params[1].getValue():false;
						log('					param = $needToPrepare');
					}
				}
			}
			switch(f.kind)
			{
				case FieldType.FVar(t, e):
					findNode(t, e, f, nodeName, needToPrepare);
				case FieldType.FProp(_, _, t, e):
					findNode(t, e, f, nodeName, needToPrepare);
				case FieldType.FFun(func):
					if (f.name == _createNodesName)
					{
						log("=== create func found ==="+f.name);
						createNodesFunc = f;
					}
					else if (f.name == _getNodesName)
					{
						log("=== get func found ===");
						getNodesFunc = f;
					}
					else if (f.name == _releaseNodesName)
					{
						log("=== release func found ===");
							releaseNodesFunc = f;
					}
			}
		}
		if (nodes.length == 0)
		{
			//there are no fields marked for this build macros
			return fields;
		}
		
		//crate array of node creation expressions
		var exprArrayCreateNodes:Array<Expr> = [];
		var exprArrayGetNodes:Array<Expr> = [];
		var exprArrayReleaseNodes:Array<Expr> = [];
		for (n in nodes)
		{
			var vn:String = n.varName;
			var nn:String = n.nodeName;
			var typePath:TypePath = {name: nodeListLinkClass, pack: nodeListLinkPackage, params:[n.nodeType]};
			var className = n.needToPrepare ? "PrepearingNodeIterator" : "NodeIterator";
			var iteratorTypePath:TypePath = {name: className, pack:nodeListLinkPackage, params:[n.nodeType] };
			exprArrayCreateNodes.push(macro { 
										this.$vn = new $typePath(new $iteratorTypePath()); 
									} );
			if (nn.charAt(0) == "-") //it's a var name and not node name
			{
				var varName = nn.substr(1);
				exprArrayGetNodes.push(macro {
										this.$vn.setNodeList(core.root.getNodes(this.$varName));
										} );
			}
			else
			{
				exprArrayGetNodes.push(macro {
										this.$vn.setNodeList(core.root.getNodes($v{nn}));
									} );
			}
			exprArrayReleaseNodes.push(macro {
										this.$vn.releaseNodeList();
									} );
		}
		var needSuperCall = Context.getLocalClass().get().superClass.t.get().name != baseSystemClass;
		
		var generateFunction = function (fName:String, methodField:Field, exprArray:Array<Expr>){
			if (methodField == null)
			{
				if (needSuperCall)
					exprArray.insert(0, macro super.$fName());
					
				methodField = {
					name: fName,
					access: [AOverride, APrivate],
					kind: FieldType.FFun({
						args:[],
						ret: macro: Void,
						expr: macro $b{exprArray}
					}),
					pos: Context.currentPos()
				}
				
				fields.push(methodField);
				log('----------- func $fName added --------');
			}
			else
			{
				switch(methodField.kind)
				{
					case FieldType.FFun(func):
						if (func.expr == null)
						{
							func.expr = macro $b{exprArray};
						}
						else
						{
							switch(func.expr.expr)
							{
								case ExprDef.EBlock(exprBlock):
									for(expr in exprArray)
										exprBlock.push(expr);
								default:
							}
						}
					default:
				}
			}
		}
		
		generateFunction(_createNodesName, createNodesFunc, exprArrayCreateNodes);
		generateFunction(_getNodesName, getNodesFunc, exprArrayGetNodes);
		generateFunction(_releaseNodesName, releaseNodesFunc, exprArrayReleaseNodes);
		
		return fields;
	}
	

	
	static function log(msg:Dynamic)
	{
		//trace(msg);
	}
	
// ECall({ expr: EConst(CIdent("some")) }, [])
 //public static macro function test(a:ExprOf<String>, pos:Int) {
    //var name = "charAt";
    //return macro $e{a}.$name($v{pos});
  //}
}

#end