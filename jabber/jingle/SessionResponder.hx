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
import xmpp.IQ;

/**
	Abstract base for jingle session responders.
*/
class SessionResponder<T:Transport> extends Session<T> {
	
	/*
	function new( stream : jabber.Stream, xmlns : String ) {
		super( stream, xmlns );
	}
	*/
	
	/**
		Handle initial jingle request packet
	*/
	public function handleRequest( iq : IQ ) : Bool {
		
		//trace('handleRequest');
		
		var j = xmpp.Jingle.parse( iq.x.toXml() );
		if( j.action != xmpp.jingle.Action.session_initiate ) {
			#if jabber_debug
			trace( "invalid jingle request ("+iq.from+")(expecting session initiate)", "warn" );
			#end
			return false;
		}
		
		candidates = new Array();
		
		var content = j.content[0]; //TODO iterate all
		//trace('>>>>>>>>>>>>>>');
		for( e in content.other ) {
			switch( e.nodeName ) {
			case "description" :
				parseDescription( e );
			case "transport" :
				//TODO check/process arguments
				for( e in e.elements() ) {
					trace(e);
					if( e.nodeName == "candidate") {
						addTransportCandidate( e );
					}
				}
			}
		}
		
		//TODO webrtc-sdp has no candidates
		
		if( candidates.length == 0 ) {
			#if jabber_debug
			trace( "no transport candidates", "warn" );
			#end
		/*
			onFail( "no transport candidates found" );
			cleanup();
			return false;
		*/
		}
		request = iq;
		entity = iq.from;
		initiator = j.initiator;
		sid = j.sid;
		contentName = content.name;
		
		addSessionCollector(); // collect session packets
		
		return true;
	}
	
	/**
		Accept/Deny incoming jingle session request
	*/
	public function accept( yes : Bool = true ) {
		stream.sendPacket( IQ.createResult( request ) );
		if( yes ) {
			connectTransport();
		} else {
			terminate( xmpp.jingle.Reason.decline );
		}
	}
	
	function parseDescription( x : Xml ) {
		//#if jabber_debug trace("not implemented","warn"); #end
	}
	
	// override me
	function addTransportCandidate( x : Xml ) {
		throw 'abstract method';
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
		stream.sendIQ( iq, handleSessionAcceptResponse );
	}
	
	function handleSessionAcceptResponse( iq : IQ ) {
		switch( iq.type ) {
		case result :
			handleSessionAccept();
		case error :
			//TODO
		default :
		}
	}
	
	function handleSessionAccept() {
		onInit();
		transport.init();//? TODO move into subclass
	}
	
}
