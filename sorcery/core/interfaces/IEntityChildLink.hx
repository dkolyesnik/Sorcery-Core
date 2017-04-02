package sorcery.core.interfaces;
/**
 * @author Dmitriy Kolyesnik
 */
interface IEntityChildLink 
{
	var fullName(get, null):String;
	function find():IEntityChild;
	function findAs<T>(cl:Class<T>):T;
}