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
package jabber;

/**
	<a http://xmpp.org/extensions/xep-0191.html">XEP 191 - Simple Communications Blocking</a><br>
*/
class BlockList {
	
	public dynamic function onLoad( i : Array<String> ) : Void;
	public dynamic function onBlock( i : Array<String> ) : Void;
	public dynamic function onUnblock( i : Array<String> ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : jabber.Stream;
	
	public function new( stream : jabber.Stream ) {
		this.stream = stream;
	}
	
	/**
		Load list of blocked entities.
	*/
	public function load() {
		var iq = new xmpp.IQ();
		iq.x = new xmpp.BlockList();
		stream.sendIQ( iq, handleLoad );
	}
	
	/**
		Block recieving stanzas from entity.
	*/
	public function block( jids : Array<String> ) {
		var iq = new xmpp.IQ( xmpp.IQType.set );
		iq.x = new xmpp.BlockList( jids );
		stream.sendIQ( iq, handleBlock );
	}
	
	/**
		Unblock recieving stanzas from entity.
	*/
	public function unblock( ?jids : Array<String> ) {
		var iq = new xmpp.IQ( xmpp.IQType.set );
		iq.x = new xmpp.BlockList( jids, true );
		stream.sendIQ( iq, handleUnblock );
	}
	
	function handleLoad( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result : onLoad( xmpp.BlockList.parse( iq.x.toXml() ).items );
		case error : onError( new jabber.XMPPError( this, iq ) );
		default : //#
		}
	}
	
	function handleBlock( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result : onBlock( xmpp.BlockList.parse( iq.x.toXml() ).items );
		case error : onError( new jabber.XMPPError( this, iq ) );
		default : //#
		}
	}
		
	function handleUnblock( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result : onUnblock( xmpp.BlockList.parse( iq.x.toXml() ).items );
		case error : onError( new jabber.XMPPError( this, iq ) );
		default : //#
		}
	}
	
}
