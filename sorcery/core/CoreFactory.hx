/**
 * Created by Dmitriy Kolesnik on 02.08.2016.
 */
package sorcery.core;

import sorcery.core.interfaces.IAgendaManager;
import sorcery.core.interfaces.ICore;
import sorcery.core.interfaces.ICoreFactory;
import sorcery.core.interfaces.IPool;
import sorcery.core.interfaces.IPoolable;
import sorcery.core.interfaces.IEntity;
import sorcery.core.interfaces.IEntityGroup;
import sorcery.core.interfaces.IEntityRoot;
import sorcery.core.interfaces.INotificator;
import sorcery.core.interfaces.ITime;
import sorcery.core.misc.Pool;

class CoreFactory implements ICoreFactory
{
	var _core : ICore;
	var _entityPool : IPool;

	public function new()
	{
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

	function _createEntityPool() : IPool
	{
		return new Pool(cast allocateEntity());
	}

}

