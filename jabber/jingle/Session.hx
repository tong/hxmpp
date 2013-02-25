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
	Abstract base for incoming or outgoing jingle sessions
*/
class Session<T:Transport> {
	
	/***/
	public dynamic function onInit() {}
	
	/***/
	public dynamic function onInfo( info : Xml ) {}
	
	/***/
	public dynamic function onEnd( reason : xmpp.jingle.Reason ) {}
	
	/***/
	public dynamic function onFail( e : String ) {}
	
	/***/
	public dynamic function onError( e : jabber.XMPPError ) {}
	
	public var stream(default,null) : jabber.Stream;
	
	/** Counterpart entity */
	public var entity(default,null) : String;
	
	/** Used transport */
	public var transport(default,null) : T;
	
	var xmlns : String;
	var sid : String;
	var initiator : String;
	var contentName : String;
	var collector : PacketCollector;
	var candidates : Array<T>;
	var request : IQ;
	var transportCandidateIndex : Int;
	
	function new( stream : jabber.Stream, xmlns : String ) {
		this.stream = stream;
		this.xmlns = xmlns;
		transportCandidateIndex = 0;
	}
	
	/**
		Terminate the jingle session
	*/
	public function terminate( ?reason : xmpp.jingle.Reason, ?content : Xml ) {
		if( reason == null ) reason = xmpp.jingle.Reason.success;
		var iq = new xmpp.IQ( xmpp.IQType.set, null, entity );
		var j = new xmpp.Jingle( xmpp.jingle.Action.session_terminate, initiator, sid );
		j.reason = { type : reason, content : content };
		iq.x = j;
		var me = this;
		stream.sendIQ( iq, function(r:IQ) {
			switch( r.type ) {
			case error :
				me.onError( new jabber.XMPPError( r ) );
			case result :
				me.onEnd( reason );
			default :
			}
		});
		cleanup();
	}
	
	/**
		Send a informational message.
	*/
	public function sendInfo( ?payload : Xml ) {
		var iq = new IQ( xmpp.IQType.set, null, entity );
		var j = new xmpp.Jingle( xmpp.jingle.Action.session_info, initiator, sid );
		if( payload != null ) j.other.push( payload );
		iq.x = j;
		var me = this;
		stream.sendIQ( iq, function(r:IQ) {
			//TODO
			switch( r.type ) {
			case result :
			case error :
				// uiuiui we need to pass the complete packet here to the onError callback
				// .. otherwise the application would never know whats this all about
				//me.onError( new jabber.XMPPError(iq) );
			default :
			}
		} );
	}
	
	function handleSessionPacket( iq : IQ ) {
		var j = xmpp.Jingle.parse( iq.x.toXml() );
		switch( j.action ) {
		case session_terminate :
			onEnd( j.reason.type );
			stream.sendPacket( IQ.createResult( iq ) );
			cleanup();
		case session_info :
			handleSessionInfo( j.other );
		default :
			processSessionPacket( iq, j );
		}
	}
	
	function processSessionPacket( iq : IQ, j : xmpp.Jingle ) { // override me
		#if jabber_debug
		trace( "jingle session packet not processed (not implemented)", "warn" );
		#end
	}
	
	function handleSessionInfo( x : Array<Xml> ) {
		for( e in x ) {
			onInfo( e );
		}
	}
		
	function addSessionCollector() {
		var filters : Array<xmpp.PacketFilter> = [
			new xmpp.filter.PacketFromFilter( entity ),
			new xmpp.filter.JingleFilter( xmlns, sid )
		];
		collector = stream.collect( filters, handleSessionPacket, true );
	}
	
	function connectTransport() {
		trace( "connecting jingle transport ..." );
		if( transport == null )
			transport = candidates[transportCandidateIndex];
		if( transport != null ) {
			transport.__onConnect = handleTransportConnect;
			transport.__onFail = handleTransportFail;
			transport.connect();
		} else {
			//TODO
			trace("TODO no jingle transport!");
		}
	}
	
	function handleTransportConnect() {
	}
	
	/*
	function handleTransportDisconnect() {
	}
	*/
	
	function handleTransportFail( e : String ) {
		if( ++transportCandidateIndex == candidates.length ) {
			onFail( e );
			cleanup();
		} else connectTransport(); // try next
	}
	
	function cleanup() {
		if( transport != null ) transport.close();
		stream.removeCollector( collector );
		collector = null;
	}
	
}
