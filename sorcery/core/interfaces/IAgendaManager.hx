/**
 * Created by Dmitriy Kolesnik on 26.08.2016.
 */
package sorcery.core.interfaces;

import sorcery.core.interfaces.IAgendaChild;

interface IAgendaManager
{
	function getCurrentAgenda():String;
	function getActiveAgendas():Array<String>;
	
	function isAgendaActive(p_genda:String):Bool;
	
	/**
	 * deactivates all active agendas and activates passed agenda
	 * @param agenda
	 */
	function swap(p_agenda : String) : IAgendaManager;

	/**
	 * activates agenda
	 * @param agenda
	 */
	function show(p_agenda : String) : IAgendaManager;
	/**
	 * deactivates agenda
	 * @param agenda name, if null deactivates currentAgenda
	 */
	function hide(?p_agenda : String) : IAgendaManager;
	
	/**
	 * hides all agendas, ALWAYS is still active
	 * @param agenda name, if null deactivates all except p_agenda
	 */
	function hideAll(?p_agends: String):IAgendaManager;


	/**
	 * remove child from agenda manager (and parent if it is added)
	 * @param child
	 * @param agenda, if null - then remove all
	 */

}

