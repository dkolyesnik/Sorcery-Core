/**
 * Created by Dmitriy Kolesnik on 07.08.2016.
 */
package sorcery.core.interfaces;

import sorcery.core.abstracts.Path;
import sorcery.core.HandlerData;

interface IBehavior extends IComponent
{

	var enabled(get, set) : Bool;
	
	function addHandler(handler:HandlerData):HandlerData;
	function removeHandler(handler:HandlerData):Void;

	private function createLink(path:Path):IEntityChildLink; 
	private function destroyLink(link:IEntityChildLink):Void;
}

