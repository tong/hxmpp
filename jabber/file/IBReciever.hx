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

import haxe.io.Bytes;
import jabber.file.io.IBInput;
import xmpp.IQ;

/**
	<a href="http://xmpp.org/extensions/xep-0047.html">XEP-0047: In-Band Bytestreams</a><br/>
	Incoming inband file transfer handler.
*/
class IBReciever extends FileReciever {
	
	var input : IBInput;
	
	public function new( stream : jabber.Stream, ?maxBlockSize : Int ) {
		super( stream, xmpp.file.IB.XMLNS );
	}
	
	public override function accept( yes : Bool ) {
		if( yes ) sendAccept( xmlns, "open" ) else sendDeny();
	}
	
	override function handleRequest( iq : IQ ) {
		input = new IBInput( stream, iq.from, sid, file.size );
		//input.__onData = handleData;
		//TODO.. error..
		input.__onComplete = handleTransferComplete;
		stream.sendPacket( IQ.createResult( iq ) );
	}
	
}
