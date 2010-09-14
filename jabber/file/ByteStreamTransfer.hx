/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
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
	
	var transport : ByteStreamOutput;
	
	public function new( stream : jabber.Stream, reciever : String,
						 ?hosts : Array<ByteStreamHost>,
						 ?bufsize : Int ) {
		if( bufsize == null ) bufsize = defaultBufSize;
		super( stream, xmpp.file.ByteStream.XMLNS, reciever, bufsize );
		this.hosts = ( hosts != null ) ? hosts : new Array();
	}
	
	public override function init( input : haxe.io.Input, sid : String, filesize : Int ) {
		if( hosts.length == 0 )
			throw "No streamhosts specified";
		this.input = input;
		this.sid = sid;
		this.filesize = filesize;
		for( h in hosts ) {
			var t = new ByteStreamOutput( h.host, h.port );
			t.__onConnect = handleTransportConnect;
			t.__onProgress = onProgress;
			t.__onComplete = onComplete;
			t.__onFail = handleTransportFail;
			t.init( SHA1.encode( sid+stream.jid.toString()+reciever ) );
		}
		var iq = new IQ( IQType.set );
		iq.to = reciever;
		iq.x = new xmpp.file.ByteStream( sid, null, hosts );
		stream.sendIQ( iq, handleRequestResponse );
	}
	
	function handleRequestResponse( iq : IQ ) {
		switch( iq.type ) {
		case result :
			transport.send( input, filesize, bufsize );
		case error :
			//TODO cleanup
			onFail( xmpp.Error.parse( iq.errors[0].toXml() ).condition );
		default :
		}
	}
	
	
	function handleTransportConnect( transport : ByteStreamOutput ) {
		this.transport = transport;
	}
	
	/*
	function handleTransportProgress( bytes : Int ) {
		onProgress( bytes );
	}
	
	function handleTransportComplete() {
		onComplete();
	}
	*/
	
	function handleTransportFail( info : String ) {
		onFail( info );
	}
	
}
