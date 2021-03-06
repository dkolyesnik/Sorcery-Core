package sorcery.core;

import sorcery.core.abstracts.FullName;
import sorcery.core.abstracts.Path;
import sorcery.core.interfaces.IBehavior;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.IEntity;
import sorcery.core.interfaces.IEntityChild;
import sorcery.core.interfaces.IEntityChildLink;
import sorcery.core.interfaces.ILinkInternal;
import haxecontracts.Contract;
import haxecontracts.HaxeContracts;
import sorcery.core.interfaces.ILinkResolver;
import sorcery.macros.Nullsafety.*;
using sorcery.core.tools.EntityChildTools;
/**
 * ...
 * @author Dmitriy Kolyesnik
 */
class EntityChildLink implements IEntityChildLink implements ILinkInternal implements HaxeContracts
{
	public var fullName(get, null):String;
	var _path:Path;
	var _owner:IBehavior;
	var _resolver:ILinkResolver;

	public function new(owner:IBehavior, path:Path)
	{
		Contract.requires(owner != null && Path.validate(path));
		//TODO do we need path?

		_resolver = owner.core.factory.getResolver(path);
		_path = path;
		_owner = owner;
	}
	
	public function get_fullName():FullName
	{
		return fullName;
	}

	/* INTERFACE bgcore.interfaces.ILinkInternal */
	public function destroy():Void
	{
		//TODO
		reset();
	}

	function resolve():Void
	{
		Contract.ensures(FullName.validate(fullName));

		fullName = _resolver.resolve(_owner.parent);
	}

	function reset():Void
	{
		fullName = FullName.UNDEFINED;
	}
	/* INTERFACE bgcore.interfaces.IEntityChildLink */

	public function find():IEntityChild
	{
		return _owner.core.root.findChildByFullName(fullName);
	}
	
	public function findAs<T>(cl:Class<T>):T
	{
		return safeGet((_owner.core.root.findChildByFullName(fullName)).castTo(cl));
	}

}