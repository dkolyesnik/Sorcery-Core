/**
 * Created by Dmitriy Kolesnik on 02.08.2016.
 */
package sorcery.core.interfaces;


interface IEntityGroup
{
	var name(get, null) : String;
	var fullName(get, never) : String;
	var parentGroup(get, null) : IEntityGroup;
	
    function findEntity(p_name : String) : IEntity;
	
	@:allow(sorcery.core.interfaces.IEntity)
    private function registerEntity(p_entity : IEntity) : Void;
	@:allow(sorcery.core.interfaces.IEntity)
    private function unregisterEntity(p_entity : IEntity) : Void;
}

