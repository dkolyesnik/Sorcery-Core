package sorcery.core.interfaces;

/**
 * @author Dmitriy Kolyesnik
 */
interface IEntityChildLink 
{
	var fullName(get, null):String;
	function findChild():IEntityChild;
}