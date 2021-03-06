/**
 * Created by Dmitriy Kolesnik on 02.08.2016.
 */
package sorcery.core;

import sorcery.core.abstracts.Path;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.ICoreFactory;
import sorcery.core.interfaces.IFramework;
import sorcery.core.interfaces.ILinkResolver;
import sorcery.core.interfaces.IPool;
import sorcery.core.interfaces.IEntity;
import sorcery.core.interfaces.IEntityRoot;
import sorcery.core.interfaces.INotificator;
import sorcery.core.interfaces.ITime;
import sorcery.core.misc.Pool;

class CoreFactory implements ICoreFactory
{
	var _core : ICore;
	var _entityPool : IPool;
	var _pathToResolver:Map<Path, ILinkResolver>;

	public function new()
	{
		_pathToResolver = new Map();
	}

	public function initialize(p_core : ICore) : Void
	{
		if (_core != null)
		{
			_core.log("Error: factory is already initialized");
			return;
		}
		_core = p_core;
		_entityPool = _createEntityPool();
	}
	
	public function createFramework():IFramework
	{
		return new Framework(_core);
	}

	public function createNotificator() : INotificator
	{
		return new Notificator();
	}

	public function createTime() : ITime
	{
		return new Time(_core);
	}

	public function createRoot() : IEntityRoot
	{
		return new EntityRoot(_core);
	}
	
	private var _nameCount : Int = 0;
	public function generateName() : String
	{
		_nameCount++;
		return Std.string(_nameCount);
	}

	public function allocateEntity() : IEntity
	{
		if (_entityPool != null)
		{
			return cast _entityPool.getObject();
		}

		return new Entity(_core);
	}

	public function wrapInGroup(entity:IEntity) : IEntity
	{
		return new EntityGroup(entity);
	}
	
	public function getResolver(path:Path):ILinkResolver
	{
		var resolver = _pathToResolver[path];
		if (resolver == null)
		{
			resolver = path;
			_pathToResolver[path] = resolver;
		}
		return resolver;
	}

	function _createEntityPool() : IPool
	{
		return new Pool(cast allocateEntity());
	}

}

