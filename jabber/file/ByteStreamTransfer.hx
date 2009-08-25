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

import jabber.file.io.ByteStreamOutput;

/**
	Outgoing out-of-band file transfer initiator.
	//TODO proxy
*/
class ByteStreamTransfer extends FileTransfer {
	
	//public var udp(default,null) : Bool;
	public var streamhosts : Array<xmpp.file.ByteStreamHost>;
	
	var output : ByteStreamOutput;
	
	public function new( stream : jabber.Stream, reciever : String, /*?udp = false,*/ ?streamhosts : Array<xmpp.file.ByteStreamHost> ) {
		super( stream, xmpp.file.ByteStream.XMLNS, reciever );
		//this.udp = udp;
		this.streamhosts = ( streamhosts != null ) ? streamhosts : new Array();
	}
	
	public override function init( input : haxe.io.Input ) {
		
		this.input = input;
		if( sid == null ) sid = util.StringUtil.random64( 16 );

		// activate stream host
		//trace(streamhosts);
		//for( h in streamhosts ) {
			//trace("STREAMHOST: "+h.port );
		//	trace("#");
		//	var output = new ByteStreamOutput( h.host, h.port );
		//	output.wait();
		//}
		
		output = new ByteStreamOutput( streamhosts[0].host, streamhosts[0].port/*, udp*/ );
		output.connect();
		output.wait();
		
		// send init request
		var iq = new xmpp.IQ( xmpp.IQType.set, null, reciever, stream.jidstr );
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
			trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
			onInit( this );
//			var bs = xmpp.file.ByteStream.parse( iq.x.toXml() );
			try {
				output.write( input );
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
