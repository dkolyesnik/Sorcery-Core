package sorcery.core.interfaces;

import sorcery.core.abstracts.FullName;
/**
 * @author Dmitriy Kolyesnik
 */
interface IEntityChildLink 
{
	var fullName(get, null):FullName;
	function find():IEntityChild;
	function findAs<T>(cl:Class<T>):T;
}