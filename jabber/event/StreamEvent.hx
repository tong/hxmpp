package jabber.event;


/**
*/
class StreamEvent<T:jabber.Stream> {
	
	public var stream(default,null) : T;
	
	public function new( s : T ) {
		this.stream = s;
	}
	
}
