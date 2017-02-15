/**
 * Created by Dmitriy Kolesnik on 26.08.2016.
 */
package sorcery.core.interfaces;


interface IPool
{
    function getObject() : IPoolable;
    function putBackObject(object : IPoolable) : Void;
}

