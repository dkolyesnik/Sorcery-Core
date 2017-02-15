package sorcery.core.interfaces;

/**
 * @author Dmitriy Kolyesnik
 */
interface IChildLink extends IEntityChildLink
{
	function findComponent():IEntityChild;
}