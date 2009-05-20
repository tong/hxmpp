package jabber;

/**
	<a http://xmpp.org/extensions/xep-0191.html">XEP 191 - Simple Communications Blocking</a><br>
*/
class BlockList {
	
	public dynamic function onLoad( i : Array<String> ) : Void;
	public dynamic function onBlock( i : Array<String> ) : Void;
	public dynamic function onUnblock( i : Array<String> ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : jabber.Stream;
	
	public function new( stream : jabber.Stream ) {
		this.stream = stream;
	}
	
	/**
		Load list of blocked entities.
	*/
	public function load() {
		var iq = new xmpp.IQ();
		iq.ext = new xmpp.BlockList();
		stream.sendIQ( iq, handleLoad );
	}
	
	/**
		Block recieving stanzas from entity.
	*/
	public function block( jids : Array<String> ) {
		var iq = new xmpp.IQ( xmpp.IQType.set );
		iq.ext = new xmpp.BlockList( jids );
		stream.sendIQ( iq, handleBlock );
	}
	
	/**
		Unblock recieving stanzas from entity.
	*/
	public function unblock( ?jids : Array<String> ) {
		var iq = new xmpp.IQ( xmpp.IQType.set );
		iq.ext = new xmpp.BlockList( jids, true );
		stream.sendIQ( iq, handleUnblock );
	}
	
	function handleLoad( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result : onLoad( xmpp.BlockList.parse( iq.ext.toXml() ).items );
		case error : onError( new jabber.XMPPError( this, iq ) );
		default : //#
		}
	}
	
	function handleBlock( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result : onBlock( xmpp.BlockList.parse( iq.ext.toXml() ).items );
		case error : onError( new jabber.XMPPError( this, iq ) );
		default : //#
		}
	}
		
	function handleUnblock( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result : onUnblock( xmpp.BlockList.parse( iq.ext.toXml() ).items );
		case error : onError( new jabber.XMPPError( this, iq ) );
		default : //#
		}
	}
	
}
