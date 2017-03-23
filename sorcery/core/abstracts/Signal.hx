package sorcery.core.abstracts;

abstract Signal<T>(Array<T->Void>)
{
	inline public function connect(handler:T->Void)
	{
		this.push(handler);
	}
	
	inline public function disconnect(handler:T->Void)
	{
		this.remove(handler);
	}
}
abstract SignalEmitter<T>(Array<T->Void>) {
    public inline function new() {
        this = [];
    }

	inline public function emit(e:T)
	{
		for (h in this)
			h(e);
	}
	
	inline public function getSignal():Signal<T> {
        return cast this;
    }
}
