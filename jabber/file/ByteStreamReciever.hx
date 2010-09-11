package jabber.file;

import haxe.io.Bytes;
import jabber.file.io.ByteStreamInput;
import jabber.util.SHA1;
import xmpp.IQ;

/**
	<a href="http://xmpp.org/extensions/xep-0065.html">XEP-0065: SOCKS5 Bytestreams.</a><br/>
	Incoming bytestream file transfer.
*/
class ByteStreamReciever extends FileReciever {
	
	var bytestream : xmpp.file.ByteStream;
	var bytestreamIndex : Int;
	var host : xmpp.file.ByteStreamHost;
	var digest : String;
	var iq : IQ;
	var input : ByteStreamInput;
	
	public function new( stream : jabber.Stream ) {
		super( stream, xmpp.file.ByteStream.XMLNS );
	}
	
	public override function accept( yes : Bool ) {
		if( yes ) sendAccept( xmlns, "query" ) else sendDeny();
	}
	
	override function handleRequest( iq : IQ ) {
		this.iq = iq;
		bytestream = xmpp.file.ByteStream.parse( iq.x.toXml() );
		bytestreamIndex = 0;
		digest = SHA1.encode( sid+iq.from+stream.jid.toString() );
		connect();
	}
	
	function connect() {
		host = bytestream.streamhosts[bytestreamIndex];
		input = new ByteStreamInput( host.host, host.port );
		input.__onConnect = handleByteStreamConnect;
		input.__onFail = handleByteStreamConnectFail;
		input.__onComplete = handleByteStreamComplete;
		input.connect( digest, file.size );
	}
	
	function handleByteStreamConnect() {
		#if JABBER_DEBUG
		trace( "Bytestream connected ["+host.host+":"+host.port+"]" );
		#end
		var r = IQ.createResult( iq );
		var bs = new xmpp.file.ByteStream();
		bs.streamhost_used = host.jid;
		r.x = bs;
		stream.sendPacket( r );
	}
	
	function handleByteStreamConnectFail( info : String ) {
		//trace( "Bytestream error: "+info );
		bytestreamIndex++;
		if( bytestreamIndex < bytestream.streamhosts.length ) {
			connect();
		} else {
			stream.sendPacket( IQ.createError( iq, [new xmpp.Error( xmpp.ErrorType.cancel,
																    xmpp.ErrorCondition.ITEM_NOT_FOUND)] ) );
		}
	}
	
	function handleByteStreamComplete( bytes : Bytes ) {
		this.data = bytes;
		onComplete( this );
	}
	
}
