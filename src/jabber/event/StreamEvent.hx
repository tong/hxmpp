package jabber.event;

import jabber.core.StreamBase;


class StreamEvent {
	
	public var stream(default,null) : StreamBase;
	
	
	public function new( stream : StreamBase ) {
		this.stream = stream;
	}
	
}
