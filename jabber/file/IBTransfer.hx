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

import jabber.file.io.IBOutput;

/**
	Outgoing in-band file transfer negotiator.<br/>
	Data is broken down into smaller chunks and transported in-band over XMPP.
*/
class IBTransfer extends FileTransfer {
	
	public static var defaultBlockSize = 1 << 12; // 4096
	
	public var blockSize(default,null) : Int;
	
	var output : IBOutput;
	
	public function new( stream : jabber.Stream, reciever : String, ?blockSize : Int ) {
		super( stream, xmpp.file.IB.XMLNS, reciever );
		this.blockSize = ( blockSize != null ) ? blockSize : defaultBlockSize;
	}
	
	/**
		Starts outgoing file transfer.
	*/
	public override function init( input : haxe.io.Input ) {
		this.input = input;
		sid = jabber.util.Base64.random( 8 );
		// send initial request
		var iq = new xmpp.IQ( xmpp.IQType.set, null, reciever, stream.jidstr );
		iq.x = new xmpp.file.IB( xmpp.file.IBType.open, sid, blockSize );
		stream.sendIQ( iq, handleRequestResponse );
	}
	
	function handleRequestResponse( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result :
			output = new jabber.file.io.IBOutput( stream, reciever, blockSize, sid );
			output.__onComplete = handleTransferComplete;
			output.__onFail = handleTransferFail;
			onInit( this );
			output.send( input.readAll() );
		case error :
			onFail( this, new jabber.XMPPError( this, iq ) );
		default : //
		}
	}
	
	function handleTransferComplete() {
		onComplete( this );
	}
	
	function handleTransferFail() {
		onFail( this, null );
	}
	
}
