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
}

