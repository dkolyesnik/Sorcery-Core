package sorcery.core;

import sorcery.core.abstracts.FullName;
import sorcery.core.abstracts.Path;
import sorcery.core.interfaces.IComponent;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.IEntity;
import sorcery.core.interfaces.IEntityChild;
import sorcery.core.interfaces.IEntityChildLink;
import sorcery.core.interfaces.ILinkInternal;
import haxecontracts.Contract;
import haxecontracts.HaxeContracts;
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
	var _owner:IComponent;
	public function new(owner:IComponent, path:Path)
	{
		Contract.requires(owner != null && Path.validate(path));
		
		_path = path;
		_owner = owner;
	}
	
	public function get_fullName():String
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

		fullName = _path.toFullName(_owner.parent);
	}

	function reset():Void
	{
		fullName = null;
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