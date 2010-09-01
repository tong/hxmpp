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
package jabber.file.io;

import jabber.util.Base64;

//TODO encode chunks itself

/**
	Generic in-band file transfer output.
*/
class IBOutput extends IO {
	
	var stream : jabber.Stream;
	var reciever : String;
	var blockSize : Int;
	var sid : String;
	var seq : Int;
	var blocks : Array<String>;
	var iq : xmpp.IQ;
	
	public function new( stream : jabber.Stream, reciever : String, blockSize : Int, sid : String ) {
		super();
		this.stream = stream;
		this.reciever = reciever;
		this.blockSize = blockSize;
		this.sid = sid;
	}
	
	//TODO! public function send( input : haxe.io.Input ) {
	public function send( bytes : haxe.io.Bytes ) {
		seq = 0;
		blocks = new Array();
		// create chunk blocks
		var t = new haxe.BaseCode( haxe.io.Bytes.ofString( Base64.CHARS ) ).encodeBytes( bytes ).toString();
		var pos = 0;
		while( true ) {
			var len = if( pos > t.length-blockSize ) t.length-pos else blockSize;
			var next = t.substr( pos, len );
			blocks.push( next );
			pos += len;
			if( pos == t.length )
				break;
		}
		//TODO encode chunks on send
		/*
		var pos = 0;
		while( true ) {
			var len = if( pos > bytes.length-blockSize ) bytes.length-pos else blockSize;
			var next = bytes.sub( pos, len );//t.substr( pos, len );
			blocks.push( next.toString() );
			pos += len;
			if( pos == bytes.length )
				break;
		}
		*/
		iq = new xmpp.IQ( xmpp.IQType.set, null, reciever );
		sendNextPacket();
	}
	
	function sendNextPacket() {
		iq.id = stream.nextID()+"_ib"+seq;
		iq.properties = [xmpp.file.IB.createDataElement( sid, seq, blocks[seq] )];
		//TODO encode chunks on send
		//iq.properties = [xmpp.file.IB.createDataElement( sid, seq, util.Base64.encode( blocks[seq] ) )];
		stream.sendIQ( iq, handleChunkResponse );
	}
	
	function handleChunkResponse( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result :
			if( seq < blocks.length-1 ) {
				seq++;
				sendNextPacket();
			} else { // complete, .. close bytestream
				var iq = new xmpp.IQ( xmpp.IQType.set, null, reciever );
				iq.x = new xmpp.file.IB( xmpp.file.IBType.close, sid );
				var me = this;
				stream.sendIQ( iq, function(r:xmpp.IQ) {
					switch( r.type ) {
					case result : me.__onComplete();
					case error : me.__onFail();
					default : //#
					}
				} );
			}
		case error : __onFail();
		default : //
		}
	}
	
}
