package jabber.file;

import jabber.file.io.ByteStreamOutput;

/**
	Outgoing out-of-band file transfer initiator.
	//TODO proxy
*/
class ByteStreamTransfer extends FileTransfer {
	
	public var streamhosts : Array<xmpp.file.ByteStreamHost>;
	
	var output : ByteStreamOutput;
	
	public function new( stream : jabber.Stream, reciever : String, ?streamhosts : Array<xmpp.file.ByteStreamHost> ) {
		super( stream, xmpp.file.ByteStream.XMLNS, reciever );
		this.streamhosts = ( streamhosts != null ) ? streamhosts : new Array();
	}
	
	public override function init( data : haxe.io.Bytes ) {
		
		this.data = data;
		sid = util.StringUtil.random64( 16 );

		// activate stream host
		//trace(streamhosts);
		//for( h in streamhosts ) {
			//trace("STREAMHOST: "+h.port );
		//	trace("#");
		//	var output = new ByteStreamOutput( h.host, h.port );
		//	output.wait();
		//}
		
		output = new ByteStreamOutput( streamhosts[0].host, streamhosts[0].port );
		output.wait();
		
		// send init request
		var iq = new xmpp.IQ( xmpp.IQType.set, null, reciever, stream.jid.toString() );
		var bs = new xmpp.file.ByteStream( sid, null, streamhosts );
		iq.x = bs;
		stream.sendIQ( iq, handleResponse );
	}
	
	/*
	public function cancel() {
		//TODO
		//output.close();
	}
	*/
	
	function handleResponse( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result :
			
			onInit( this );
//			var bs = xmpp.file.ByteStream.parse( iq.x.toXml() );
			try {
				output.write( data );
				output.close();
			} catch( e : Dynamic ) {
				trace(e);
			}
			onComplete( this );
			
		case error :
		default : //#
		}
	}
	
}
