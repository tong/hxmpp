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

import jabber.jingle.io.RTMPOutput;
import xmpp.IQ;

/**
	Outgoing RTMP session.
*/
class RTMPCall extends OutgoingSession<RTMPOutput> {
	
	public function new( stream : jabber.Stream, entity : String, contentName : String = "av" ) {
		super( stream, entity, contentName, xmpp.Jingle.XMLNS_RTMP );
	}
	
	override function processSessionPacket( iq : IQ, j : xmpp.Jingle ) {
		switch( j.action ) {
		case session_accept :
			var content = j.content[0];
			candidates = new Array();
			for( t in transports ) {
				for( e in content.other ) {
					if( e.get( "name" ) == t.name ) {
						candidates.push( t );
						continue;
					}
				}
			}
			if( candidates.length == 0 ) {
				onFail( 'no valid transport candidate selected' );
				return;
			}
			request = iq;
			connectTransport();
		default :
			#if jabber_debug
			trace( "Jingle session packet ("+j.action+") not handled", "warn" );
			#end
		}
	}
	
	override function handleTransportConnect() {
		transport.__onPublish = handleTransportPublish;
		//onConnect();
		transport.publish();
	}
	
	function handleTransportPublish() {
		onInit();
		stream.sendPacket( IQ.createResult( request ) );
	}
	
}
