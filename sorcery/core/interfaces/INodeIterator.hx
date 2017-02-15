package sorcery.core.interfaces;
import sorcery.core.SystemNode;

/**
 * @author Dmitriy Kolyesnik
 */
interface INodeIterator 
{
	function hasNext() : Bool;
	function next() : ISystemNode;
}