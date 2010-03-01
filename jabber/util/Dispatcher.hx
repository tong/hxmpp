package jabber.util;

private enum EventException {
	StopPropagation;
}

class Dispatcher<T> {

	public var listeners : Array<TListener<T>>;

	public function new() {
		listeners = new Array();
	}
	
	/**
	*/
	public function addListener( l ) {
		listeners.push( l );
		return l;
	}
	
	/**
	*/
	public function removeListener( l ) {
		listeners.remove( l );
		return l;
	}
	
	/**
		Wraps given handler function into event.Listener object. f : T->Dynamic
	*/
	public function addHandler( f ) {
		return addListener( { handleEvent : f } );
	}
	
	/**
		Dispatches value to all registered listeners and handlers.
	*/
	public function dispatchEvent( e : T ) : Bool {
		try {
			for( l in listeners )
				l.handleEvent( e );
			return true;
		} catch( e : EventException ) {
			return false;
		}
	}
	
	public function clear() {
		listeners = new Array();
	}
	
	public static function stop() {
		throw StopPropagation;
	}
	
}
