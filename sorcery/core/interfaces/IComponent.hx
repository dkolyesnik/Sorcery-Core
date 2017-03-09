/**
 * Created by Dmitriy Kolesnik on 03.08.2016.
 */
package sorcery.core.interfaces;
import sorcery.core.abstracts.Path;
import sorcery.core.interfaces.IAgendaChild;


interface IComponent extends IEntityChild
{
	private function onActivate() : Void;
    private function onDeactivate() : Void;
	
	//private function onAddedToParent() : Void;
	//private function onRemovedFromParent() : Void;
	
	private function onAddedToRoot() : Void;
	private function onRemovedFromRoot() : Void;
	
	private function onFocus():Void;
	private function onLostFocus():Void;
}

