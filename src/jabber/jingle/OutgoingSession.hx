/*
 * Copyright (c) 2012, disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package jabber.jingle;

//TODO
//import jabber.jingle.io.Transport;
import jabber.io.Transport;

import jabber.util.Base64;
import xmpp.IQ;
import xmpp.IQType;

/**
	Abstract base for outgoing jingle sessions
*/
class OutgoingSession<T:Transport> extends Session<T> {
	
	/** Transports we offer */
	public var transports(default,null) : Array<T>;
	
	function new( stream : jabber.Stream, entity : String, contentName : String, xmlns : String ) {
		super( stream, xmlns );
		this.entity = entity;
		this.contentName = contentName;
		this.initiator = stream.jid.toString();
		transports = new Array();
	}
	
	public function init() {
		sendSessionInit();
	}
	
	function sendSessionInit( ?description : Xml ) {
		if( transports.length == 0 )
			throw "no transports registered";
		sid = Base64.random( 16 );
		var iq = new IQ( IQType.set, null, entity );
		var j = new xmpp.Jingle( xmpp.jingle.Action.session_initiate, stream.jid.toString(), sid, entity );
		var content = new xmpp.jingle.Content( xmpp.jingle.Creator.initiator, contentName );
//		content.senders = xmpp.jingle.Senders.both; //TODO
		if( description != null ) content.other.push( description );
		content.other.push( createTransportXml() );
		j.content.push( content );
		iq.x = j;
		addSessionCollector();
		iq.from = stream.jid.toString();
		stream.sendIQ( iq, handleSessionInitResponse );
	}
	
	function handleSessionInitResponse( iq : IQ ) {
		switch( iq.type ) {
		case result :
			handleSessionInitResult();
		case error :
			//onError( new jabber.XMPPError( iq ) );
			var err = iq.errors[0];
			onFail( err.condition );
			//onFail( new jabber.XMPPError( iq ) );
			cleanup();
		default :
		}
	}
	
	function handleSessionInitResult() {
		// abstract
	}
	
	function createTransportXml() : Xml {
		var x = xmpp.IQ.createQueryXml( xmlns, 'transport' );
		for( t in transports ) {
			var cx = createCandidateXml( t );
			if( cx != null ) {
				x.addChild( cx );
			}
		}
		return x;
	}
	
	function createCandidateXml( t : Transport ) : Xml {
		return t.toXml();
	}
	
}
