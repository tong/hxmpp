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
import jabber.data.io.IBInput;
import xmpp.IQ;

/**
	<a href="http://xmpp.org/extensions/xep-0047.html">XEP-0047: In-Band Bytestreams</a><br/>
	Incoming inband file transfer handler.
*/
class IBReciever extends DataReciever {
	
	var input : IBInput;
	
	public function new( stream : jabber.Stream, ?maxBlockSize : Int ) {
		super( stream, xmpp.file.IB.XMLNS );
	}
	
	public override function accept( yes : Bool, ?range : xmpp.file.Range ) {
		super._accept( yes, "open", range );
	}
	
	override function handleRequest( iq : IQ ) {
		
		var size = file.size;
		if( range != null ) {
			if( range.length != null ) size = range.length;
			else if( range.offset != null ) size -= range.offset;
		}
		
		input = new IBInput( stream, iq.from, sid, size );
		//input.__onConnect = onInit;
		input.__onProgress = onProgress;
		input.__onComplete = onComplete;
		input.__onFail = onFail;
		stream.sendPacket( IQ.createResult( iq ) );
	}
	
}
