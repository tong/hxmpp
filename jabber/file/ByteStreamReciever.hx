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

import jabber.file.io.ByteStreamInput;

/**
	Outgoing SOCKS out-of-band file transfer.
*/
class ByteStreamReciever extends FileReciever {
	
	public var streamhosts : Array<xmpp.file.ByteStreamHost>;
	
	var input : ByteStreamInput;
	var currentStreamHostIndex : Int;
	
	public function new( stream : jabber.Stream ) {
		super( stream, xmpp.file.ByteStream.XMLNS );
	}
	
	override function getData() : haxe.io.Bytes {
		return input.data;
	}
	
	public override function handleRequest( iq : xmpp.IQ ) {
		var bs = xmpp.file.ByteStream.parse( iq.x.toXml() );
		if( bs.streamhosts.length < 1 )
			return false;
		streamhosts = bs.streamhosts;
		return super.handleRequest( iq );
	}
	
	public override function accept( yes : Bool = true ) {
		if( yes ) {
			currentStreamHostIndex = 0;
			connectInput();
		} else
			denyTransfer();
	}
	
	function connectInput() {
		var h = streamhosts[currentStreamHostIndex];
		#if JABBER_DEBUG trace( "Connecting SOCKS bytestream "+h.host+":"+h.port ); #end
		input = new ByteStreamInput( h.host, h.port );
		input.__onFail = handleInputFail;
		input.__onConnect = handleInputConnect;
		input.__onComplete = handleInputComplete;
		input.connect();
	}
	
	function handleInputFail() {
		trace("handleInputFail");
		#if JABBER_DEBUG trace( "Bytestream connection failed" ); #end
		currentStreamHostIndex++;
		if( currentStreamHostIndex == streamhosts.length ) {
			trace("CONNECTION FAILEd TODO");
			
		} else {
			connectInput();
		}
	}
		
	function handleInputConnect() {
		#if JABBER_DEBUG trace( "Bytestream connected" ); #end
		// send accept result
		var r = xmpp.IQ.createResult( request );
		var bs = new xmpp.file.ByteStream();
		bs.streamhost_used = streamhosts[currentStreamHostIndex].jid;
		r.x = bs;
		stream.sendPacket( r );
	}
	
	function handleInputComplete() {
		this.onComplete( this );
	}
	
	function denyTransfer() {
		var r = new xmpp.IQ( xmpp.IQType.error, request.id, request.from );
		r.errors.push(new xmpp.Error( xmpp.ErrorType.cancel, -1, xmpp.ErrorCondition.NOT_ACCEPTABLE ) );
		stream.sendPacket( r );
	}
	
}
