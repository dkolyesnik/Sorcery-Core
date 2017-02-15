/**
 * Created by Dmitriy Kolesnik on 01.09.2016.
 */
package sorcery.core.interfaces;


interface ICorePluginManager extends IBundle
{
    function addPlugin(plugin : IBundle) : Void;
}

