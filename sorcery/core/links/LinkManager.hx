package sorcery.core.links;
import sorcery.core.interfaces.ICore;
import sorcery.core.abstracts.Path;
import sorcery.core.interfaces.IEntityChildLink;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
class LinkManager
{
	private var _core:ICore;
	private var _pathToLink:Map<Path, IEntityChildLink>;
	
	public function new(p_core:ICore) {
		_core = p_core;
		_pathToLink = new Map();
	}
	


}