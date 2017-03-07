/**
 * Created by Dmitriy Kolesnik on 29.07.2016.
 */
package sorcery.core.interfaces;
import sorcery.core.abstracts.Agenda;

@:allow(sorcery.core.interfaces.IAgendaManager)
interface IAgendaChild extends IEntityChild
{
	function getUseByAgendaCount():Int;
	function activateByAgenda(p_agenda:Agenda):Bool;
	function deactivateByAgends(p_agenda:Agenda):Bool;
}

