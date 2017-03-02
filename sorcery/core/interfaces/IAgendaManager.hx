/**
 * Created by Dmitriy Kolesnik on 26.08.2016.
 */
package sorcery.core.interfaces;

import sorcery.core.interfaces.IAgendaChild;

interface IAgendaManager
{
	function getCurrentAgenda():String;
	function getActiveAgendas():Array<String>;
	
	/**
	 * deactivates all active agendas and activates passed agenda
	 * @param agenda
	 */
	function swap(p_agenda : String) : Void;

	/**
	 * activates agenda
	 * @param agenda
	 */
	function show(p_agenda : String) : Void;
	/**
	 * deactivates agenda
	 * @param agenda name, if null deactivates currentAgenda
	 */
	function hide(?p_agenda : String) : Void;
	
	/**
	 * hides all agendas, ALWAYS is still active
	 */
	function hideAll():Void;


	/**
	 * remove child from agenda manager (and parent if it is added)
	 * @param child
	 * @param agenda, if null - then remove all
	 */

}

