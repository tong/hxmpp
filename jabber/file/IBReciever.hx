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
	
	public static var defaultMaxBlockSize = 8192;
	
	public var maxBlockSize(default,null) : Int; 
	public var sid(default,null) : String;
	
	var input : IBInput;
	
	public function new( stream : jabber.Stream, ?maxBlockSize : Int ) {
		super( stream, xmpp.file.IB.XMLNS );
		this.maxBlockSize = ( maxBlockSize != null ) ? maxBlockSize : defaultMaxBlockSize;
	}
	
	override function getData() : haxe.io.Bytes {
		return input.data; //haxe.io.Bytes.ofString( input.data );
	}
	
	public override function handleRequest( iq : xmpp.IQ ) : Bool {
		var ib = xmpp.file.IB.parse( iq.x.toXml() );
		if( ib.blockSize > maxBlockSize ) {
			deny( new xmpp.Error( xmpp.ErrorType.modify, null, xmpp.ErrorCondition.RESOURCE_CONSTRAINT ) );
			return false;
		}
		sid = ib.sid;
		return super.handleRequest( iq );
	}
	
	public override function accept( yes : Bool = true ) {
		if( yes ) {
			input = new IBInput( stream, initiator, sid );
			input.__onComplete = handleInputComplete;
			input.__onFail = handleInputFail;
			//input.__onProgress = handleIBProgress;
			stream.sendPacket( xmpp.IQ.createResult( request ) );
		} else {
			deny( new xmpp.Error( xmpp.ErrorType.cancel, null, xmpp.ErrorCondition.NOT_ACCEPTABLE ) );
		}
	}
	
	function deny( e : xmpp.Error ) {
		var r = xmpp.IQ.createErrorResult( request );
		r.errors.push( e );
		stream.sendPacket( r );
	}
	
	/*
	function handleInputProgress() {
	}
	*/
	
	function handleInputComplete() {
		if( onComplete == null ) {
			#if JABBER_DEBUG
			trace( "No file transfer complete handler specified", "warn" );
			#end
			return;
		}
		onComplete( this );
	}
	
	function handleInputFail() {
		if( onFail == null ) {
			#if JABBER_DEBUG
			trace( "No file transfer failed handler specified", "warn" );
			#end
			return;
		} 
		onFail( this, null );
	}
	
}
