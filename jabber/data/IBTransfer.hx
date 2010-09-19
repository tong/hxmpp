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
import jabber.util.Base64;
import jabber.data.io.IBOutput;
import xmpp.IQ;

/**
	<a href="http://xmpp.org/extensions/xep-0047.html">XEP-0047: In-Band Bytestreams</a><br/>
	Outgoing in-band file transfer negotiator.<br/>
	Data is broken down into smaller chunks and transported in-band over XMPP.<br/>
	Use only as a last resort. SOCKS5 Bytestreams will almost always be preferable.
*/
class IBTransfer extends DataTransfer {
	
	public static var defaultBufSize = 1<<12; //1<<14; //16384
	
	var transport : IBOutput;
	
	public function new( stream : jabber.Stream, reciever : String,
						 ?bufsize : Int ) {
		if( bufsize == null ) bufsize = defaultBufSize;
		super( stream, xmpp.file.IB.XMLNS, reciever, bufsize );
	}
	
	public override function init( input : haxe.io.Input, sid : String, file : xmpp.file.File ) {
		super.init( input, sid, file );
		var iq = new IQ( xmpp.IQType.set, null, reciever, stream.jidstr );
		iq.x = new xmpp.file.IB( xmpp.file.IBType.open, sid, bufsize );
		stream.sendIQ( iq, handleRequestResponse );
	}
	
	function sendRequest() {
		var iq = new IQ( xmpp.IQType.set, null, reciever, stream.jidstr );
		iq.x = new xmpp.file.IB( xmpp.file.IBType.open, sid, bufsize );
		stream.sendIQ( iq, handleRequestResponse );
	}
	
	function handleRequestResponse( iq : IQ ) {
		switch( iq.type ) {
		case result :
			transport = new IBOutput( stream, reciever, sid );
			transport.__onProgress = onProgress;
			transport.__onComplete = onComplete;
			transport.__onFail = handleTransportFail;
			//onInit( this );
			transport.send( input, file.size, bufsize );
		case error :
			onFail( iq.errors[0].condition );
		default : //
		}
	}
	
}
