package jabber.file;

/**
	Abstract base for incoming file transfer request listeners.
*/
class TransferListener {
	
	public dynamic function onRequest( i : Input ) : Void;
	
	public var stream(default,null) : jabber.Stream;
	public var acceptMode : AcceptMode;
	public var id(default,null) : String;
	
	function new( id : String, stream : jabber.Stream, ?acceptMode : AcceptMode ) {
		this.id = id;
		this.stream = stream;
		this.acceptMode = ( acceptMode != null ) ? acceptMode : AcceptMode.manual;
	}
	
	public function denyTransfer( iq : xmpp.IQ ) {
		var r = new xmpp.IQ( xmpp.IQType.error, iq.id, iq.from );
		r.errors.push(new xmpp.Error( xmpp.ErrorType.cancel, -1, xmpp.ErrorCondition.NOT_ACCEPTABLE ) );
		stream.sendPacket( r );
	}
	
}
