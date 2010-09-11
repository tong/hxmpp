package jabber.file;

import jabber.util.Base64;
import jabber.util.SHA1;
import jabber.file.io.ByteStreamOutput;
import xmpp.IQ;
import xmpp.IQType;
import xmpp.file.ByteStreamHost;

/**
	<a href="http://xmpp.org/extensions/xep-0065.html">XEP-0065: SOCKS5 Bytestreams</a><br/>
	Outgoing bytestream file transfer.
*/
class ByteStreamTransfer extends FileTransfer {
	
	public static var defaultBufSize = 1 << 12; // 4096
	
	public var hosts(default,null) : Array<ByteStreamHost>;
	
	var output : ByteStreamOutput;
	
	public function new( stream : jabber.Stream, reciever : String,
						 ?hosts : Array<ByteStreamHost>,
						 ?bufsize : Int ) {
		if( bufsize == null ) bufsize = defaultBufSize;
		super( stream, xmpp.file.ByteStream.XMLNS, reciever, bufsize );
		this.hosts = ( hosts != null ) ? hosts : new Array();
	}
	
	public override function __init( input : haxe.io.Input, sid : String, fileSize : Int ) {
		if( hosts.length == 0 )
			throw "No streamhosts specified";
	//	if( __sid == null )
	//		throw "SID not set";
		this.input = input;
		this.sid = sid;
		this.fileSize = fileSize;
		for( h in hosts ) {
			var host = new ByteStreamOutput( h.host, h.port );
			host.__onConnect = handleOutputConnect;
			host.__onFail = handleOutputFail;
			host.__onComplete = handleOutputComplete;
			host.init( SHA1.encode( sid+stream.jid.toString()+reciever ) );
		}
		var iq = new IQ( IQType.set );
		iq.to = reciever;
		iq.x = new xmpp.file.ByteStream( sid, null, hosts );
		stream.sendIQ( iq, handleRequestResponse );
	}
	
	function handleRequestResponse( iq : IQ ) {
		switch( iq.type ) {
		case result :
			output.write( input, fileSize, bufsize );
		case error :
			//TODO
			trace("ERRRRRORR");
		default :
		}
	}
	
	function handleOutputFail( info : String ) {
		onFail( info );
	}
	
	function handleOutputConnect( output : ByteStreamOutput ) {
		this.output = output;
	}
	
	function handleOutputComplete() {
		onComplete();
	}
	
}
