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

import jabber.file.io.IBInput;

/**
	Incoming in-band file transfer handler.
*/
class IBReciever extends FileReciever {
	
	public var blockSize(default,null) : Int;
	
	var input : IBInput;
	var sid : String;
	
	public function new( stream : jabber.Stream ) {
		super( stream, xmpp.file.IB.XMLNS );
	}
	
	override function getData() : haxe.io.Bytes {
		return input.data; //haxe.io.Bytes.ofString( input.data );
	}
	
	public override function handleRequest( iq : xmpp.IQ ) : Bool {
		//TODO
		var ib = xmpp.file.IB.parse( iq.x.toXml() );
		trace( ib.blockSize );
		sid = ib.sid;
		return super.handleRequest( iq );
	}
	
	public override function accept( yes : Bool = true ) {
		input = new IBInput( stream, initiator, sid );
		input.__onClose = handleInputClose;
		//input.__onComplete = handleIBClose;
		input.__onFail = handleInputFail;
		//input.__onProgress = handleIBProgress;
		stream.sendPacket( xmpp.IQ.createResult( request ) );
	}
	
	/*
	function handleInputProgress() {
		trace("HANDLE DATA");
	}
	*/
	
	function handleInputClose() {
		onComplete( this );
	}
	
	function handleInputFail( m : String ) {
		onFail( this, m );
	}
	
}
