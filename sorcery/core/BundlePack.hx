package sorcery.core;
import sorcery.core.interfaces.ICoreFactory;
import sorcery.core.interfaces.IBundle;
import haxecontracts.Contract;
import haxecontracts.HaxeContracts;
import sorcery.core.interfaces.ICore;

/**
 * ...
 * @author Dmitriy Kolyesnik
 */
@:allow(sorcery.core.interfaces.ICore)
class BundlePack implements HaxeContracts
{
	var _bundles:Array<IBundle> = [];

	public function new()
	{

	}
	
	public function addBundle(bundle:IBundle):Void
	{
		if (_bundles.indexOf(bundle) >= 0)
			trace(LogType.WARNING, "duplicated plugin, name=" + bundle.name);
		else
			_bundles.push(bundle);
	}

}