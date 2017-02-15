/**
 * Created by Dmitriy Kolesnik on 26.08.2016.
 */
package sorcery.core.misc;

import sorcery.core.interfaces.IPool;
import sorcery.core.interfaces.IPoolable;
import haxecontracts.Contract;
import haxecontracts.HaxeContracts;

class Pool implements IPool implements HaxeContracts
{
    
    private var _baseObject : IPoolable;
    private var _objects : Array<IPoolable>;
    private var _lastReturendIndex : Int;
    
    public function new(baseObject : IPoolable, size : Int = 0)
    {
		Contract.requires(baseObject != null);
		
        _baseObject = baseObject;
        _objects = [];
        for (i in 0...size)
        {
            _objects[i] = _newObject();
        }
        _lastReturendIndex = size > 0 ? size : 0;
    }
    
    public function getObject() : IPoolable
    {
		Contract.ensures(Contract.result != null);
		
        if (_lastReturendIndex == 0)
        {
            return _newObject();
        }
        
        _lastReturendIndex--;
        var obj : IPoolable = _objects[_lastReturendIndex];
        _objects[_lastReturendIndex] = null;
        obj.setup(this);
        return obj;
    }
    
    public function putBackObject(object : IPoolable) : Void
    {
		Contract.requires(object != null);
		
        object.clean();
        _objects[_lastReturendIndex] = object;
        _lastReturendIndex++;
    }
    
    private function _newObject() : IPoolable
    {
        var obj : IPoolable = cast _baseObject.clone(); 
        obj.setup(this);
        return obj;
    }
}

