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
package jabber.jingle;

import jabber.jingle.io.Transport;
import xmpp.IQ;

class SessionResponder<T:Transport> extends Session<T> {
	
	public function new( stream : jabber.Stream, xmlns : String ) {
		super( stream, xmlns );
	}
	
	public function handleRequest( iq : IQ ) : Bool {
		var j = xmpp.Jingle.parse( iq.x.toXml() );
		if( j.action != xmpp.jingle.Action.session_initiate )
			return false;
		var content = j.content[0];
		candidates = new Array();
		for( e in content.other ) {
			switch( e.nodeName ) {
			case "description" :
				parseDescription( e );
			case "transport" :
				//TODO check/process arguments
				for( e in e.elements() ) {
					if( e.nodeName == "candidate") {
						addTransportCandidate( e );
					}
				}
			}
		}
		if( candidates.length == 0 ) {
			onFail( "no transport candidates found" );
			cleanup();
			return false;
		}
		request = iq;
		entity = iq.from;
		initiator = j.initiator;
		sid = j.sid;
		contentName = content.name;
		
		addSessionCollector(); // collect session packets
		
		return true;
	}
	
	public function accept( yes : Bool = true ) {
		stream.sendPacket( IQ.createResult( request ) );
		if( yes ) {
			connectTransport();
		} else {
			terminate( xmpp.jingle.Reason.decline );
		}
	}
	
	function parseDescription( x : Xml ) {
		//#if JABBER_DEBUG trace("not implemented","warn"); #end
	}
	
	// override me
	function addTransportCandidate( x : Xml ) {
		throw new jabber.error.AbstractError();
	}
	
	//TODO remove (handle by specific impl )
	override function handleTransportConnect() {
		//transport.__onDisconnect = handleTransportDisconnect;
		sendSessionAccept();
	}
	
	function sendSessionAccept( ?description : Xml ) {
		var iq = new xmpp.IQ( xmpp.IQType.set, null, initiator );
		var j = new xmpp.Jingle( xmpp.jingle.Action.session_accept, initiator, sid );
		//j.responder = stream.jid.toString();
		var content = new xmpp.jingle.Content( xmpp.jingle.Creator.initiator, contentName );
		content.other.push( transport.toXml() );
		if( description != null ) content.other.push( description );
		j.content.push( content );
		iq.x = j;
		stream.sendIQ( iq, handleSessionAccept );
	}
	
	function handleSessionAccept( iq : IQ ) {
		switch( iq.type ) {
		case result :
			//trace("IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII "+transport);
			onInit();
			transport.init();
		case error :
			//TODO
		default :
		}
	}
	
}
