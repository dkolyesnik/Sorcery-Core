package sorcery.core.interfaces;

/**
 * @author Dmitriy Kolyesnik
 */
interface IEntityChildLink 
{
	@:property
	var fullName(get, null):String;
	function findChild():IEntityChild;
}