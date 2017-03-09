/**
 * Created by Dmitriy Kolesnik on 29.07.2016.
 */
package sorcery.core.interfaces;
import sorcery.core.abstracts.Agenda;

@:allow(sorcery.core.interfaces.IAgendaManager)
interface IAgendaChild
{
	private function getUseByAgendaCount():Int;
	private function resetUseByAgendaCount():Void;
	private function activateByAgenda(p_agenda:Agenda):Bool;
	private function deactivateByAgends(p_agenda:Agenda):Bool;
}

