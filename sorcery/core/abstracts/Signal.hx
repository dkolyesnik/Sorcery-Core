package sorcery.core.abstracts;

/**
 * ...
 * @author Dmitriy Kolesnik
 */
abstract Signal<T>(Array<T->Void>)
{
	inline public function new(){
		this = [];
	}
	
	inline public function connect(handler:T->Void)
	{
		this.push(handler);
	}
	
	inline public function disconnect(handler:T->Void)
	{
		this.remove(handler);
	}
	
	inline public function emit(e:T)
	{
		for (h in this)
			h(e);
	}
	

}