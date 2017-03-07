/**
 * Created by Dmitriy Kolesnik on 03.08.2016.
 */
package sorcery.core.interfaces;
import sorcery.core.abstracts.Path;
import sorcery.core.interfaces.IAgendaChild;


interface IComponent extends IAgendaChild
{
	private function onActivate() : Void;
    private function onDeactivate() : Void;
	
	//private function onAddedToParent() : Void;
	//private function onRemovedFromParent() : Void;
	
	private function onAddedToRoot() : Void;
	private function onRemovedFromRoot() : Void;
	
	private function onFocus() : Void;  // called when we switch back to some agenda like onFocus in Screen and ScreenManager
	private function onLostFocus() : Void;  // called when we activate different agenda and this child is not a part of it
}

