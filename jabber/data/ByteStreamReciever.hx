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
package jabber.data;

import haxe.io.Bytes;
import jabber.data.io.ByteStreamInput;
import jabber.util.SHA1;
import xmpp.IQ;

/**
	<a href="http://xmpp.org/extensions/xep-0065.html">XEP-0065: SOCKS5 Bytestreams.</a><br/>
	Incoming bytestream file transfer.
*/
class ByteStreamReciever extends DataReciever {
	
	var bytestream : xmpp.file.ByteStream;
	var bytestreamIndex : Int;
	var host : xmpp.file.ByteStreamHost;
	var digest : String;
	var iq : IQ;
	var input : ByteStreamInput;
	
	public function new( stream : jabber.Stream ) {
		super( stream, xmpp.file.ByteStream.XMLNS );
	}
	
	public override function accept( yes : Bool, ?range : xmpp.file.Range ) {
		super._accept( yes, "query", range );
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
		input.__onConnect = handleTransferConnect;
		input.__onProgress = onProgress;
		input.__onComplete = onComplete;
		input.__onFail = handleTransferFail;
		//input.__onConnectFail = handleTransferConnectFail; //TODO?
		var size = file.size;
		if( range != null ) {
			if( range.length != null ) size = range.length;
			else if( range.offset != null ) size -= range.offset;
		}
		input.connect( digest, size );
	}
	
	function handleTransferConnect() {
		#if JABBER_DEBUG
		trace( "Bytestream connected ["+host.host+":"+host.port+"]" );
		#end
		var r = IQ.createResult( iq );
		var bs = new xmpp.file.ByteStream( sid );
		bs.streamhost_used = host.jid;
		r.x = bs;
		stream.sendPacket( r );
	}
	
	function handleTransferFail( info : String ) {
		// HMMMM
		bytestreamIndex++;
		if( bytestreamIndex < bytestream.streamhosts.length ) {
			connect();
		} else {
			stream.sendPacket( IQ.createError( iq, [new xmpp.Error( xmpp.ErrorType.cancel,
																    xmpp.ErrorCondition.ITEM_NOT_FOUND)] ) );
		}
	}
	
}
