package sorcery.core.interfaces;
import sorcery.core.abstracts.FullName;
import sorcery.core.interfaces.IEntity;
/**
 * @author Dmitriy Kolesnik
 */
interface ILinkResolver {
	function resolve(entity:IEntity):FullName;
}