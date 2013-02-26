/*
 * Copyright (c) 2012, disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package jabber.data;

import jabber.util.Base64;
import jabber.util.SHA1;
import jabber.data.io.ByteStreamOutput;
//import jabber.io.ByteStreamOutput;
import xmpp.IQ;
import xmpp.IQType;
import xmpp.file.ByteStreamHost;

/**
	Outgoing bytestream file transfer.
	
	<a href="http://xmpp.org/extensions/xep-0065.html">XEP-0065: SOCKS5 Bytestreams</a>
*/
class ByteStreamTransfer extends DataTransfer {
	
	/** */
	public static var defaultBufSize = 1<<12; // 4096
	
	/** */
	public var hosts(default,null) : Array<ByteStreamHost>;
	
	var transports : Array<ByteStreamOutput>;
	var transport : ByteStreamOutput;
	
	public function new( stream : jabber.Stream, reciever : String,
						 ?hosts : Array<ByteStreamHost>,
						 ?bufsize : Int ) {
		if( bufsize == null ) bufsize = defaultBufSize;
		super( stream, xmpp.file.ByteStream.XMLNS, reciever, bufsize );
		this.hosts = ( hosts != null ) ? hosts : new Array();
	}
	
	public override function init( input : haxe.io.Input, sid : String, file : xmpp.file.File ) {
		if( hosts.length == 0 )
			throw "no streamhosts specified";
		super.init( input, sid, file );
		var digest = SHA1.encode( sid+stream.jid.toString()+reciever );
		transports = new Array();
		for( h in hosts ) {
			var t = new ByteStreamOutput( h.host, h.port );
			t.__onConnect = handleTransportConnect;
			t.__onProgress = onProgress;
			t.__onComplete = onComplete;
			t.__onFail = handleTransportFail;
			t.init( digest );
			transports.push( t );
		}
		var iq = new IQ( IQType.set );
		iq.to = reciever;
		iq.x = new xmpp.file.ByteStream( sid, hosts );
		stream.sendIQ( iq, handleRequestResponse );
	}
	
	/*
	//TODO
	public override function abort() {
	}
	*/
	
	function handleRequestResponse( iq : IQ ) {
		switch( iq.type ) {
		case result :
			//onInit();
			trace("SEND");
			transport.send( input, file.size, bufsize );
			//transport.send( input, bufsize );
		case error :
			var e = iq.errors[0];
			onFail( e.condition );
			//TODO
			//transport.close();
			//for( t in transports ) { if( t != transport ) t.close(); }
		default :
		}
	}
	
	function handleTransportConnect( transport : ByteStreamOutput ) {
		this.transport = transport;
		for( t in transports ) { if( t != transport ) t.close(); }
	}
	
	/*
	function handleTransportFail( info : String ) {
		onFail( info );
	}
	*/
	
}
