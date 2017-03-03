/**
 * Created by Dmitriy Kolesnik on 02.08.2016.
 */
package sorcery.core.interfaces;


interface IEntityGroup
{
	@:property
	var name(get, null) : String;
	@:property
	var fullName(get, never) : String;
	@:property
	var parentGroup(get, null) : IEntityGroup;
	
    function findEntity(p_name : String) : IEntity;
	
	@:allow(sorcery.core.interfaces.IEntity)
    private function registerEntity(p_entity : IEntity) : Void;
	@:allow(sorcery.core.interfaces.IEntity)
    private function unregisterEntity(p_entity : IEntity) : Void;
}

