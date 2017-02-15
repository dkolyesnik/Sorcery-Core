/**
 * Created by Dmitriy Kolesnik on 26.08.2016.
 */
package sorcery.core.interfaces;


interface IPoolable extends ICloneable
{
    function setup(pool : IPool) : Void;
    function clean() : Void;
}

