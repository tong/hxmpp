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

import jabber.jingle.io.RTMFPOutput;
import jabber.jingle.io.Transport;
import xmpp.IQ;

/**
	Outgoing (direct) RTMFP connection.
*/
class RTMFPCall extends OutgoingSession<RTMFPOutput> {
	
	public var pubid(default,null) : String;
	
	//var payloads : Array<PayloadType>;
	
	public function new( stream : jabber.Stream, entity : String,
						 contentName : String = 'av' ) {
		super( stream, entity, contentName, xmpp.Jingle.XMLNS_RTMFP );
	}
	
	public override function init() {
		candidates = transports.copy();
		connectTransport();
	}
	
	override function handleTransportConnect() {
		sendSessionInit();
	}
	
	override function processSessionPacket( iq : IQ, j : xmpp.Jingle ) {
		switch( j.action ) {
		
		case session_accept :
			// TODO this is kinda shitty, just offering one transport here #
			var rid : String = null;
			for( c in j.content[0].other ) {
				rid = c.get("id");
				break;
				/*
				var rid = c.get("id");
				for( t in transports ) {
					if( rid == t.id )
						rids.push(rid);
				}
				*/
			}
			if( rid != transport.id ) {
				terminate( xmpp.jingle.Reason.unsupported_transports );
				cleanup();
				return;
			}
			onInit();
			stream.sendPacket( IQ.createResult( iq ) );
			
		default :
			#if jabber_debug
			trace( "jingle session packet not handled", "warn" );
			#end
		}
	}
	
	override function createCandidateXml( t : Transport ) : Xml {
		var x = t.toXml();
		pubid = jabber.util.MD5.encode( Date.now().getTime()+stream.jid.toString()+entity );
		x.set( "pubid", pubid );
		return x;
	}
	
}
