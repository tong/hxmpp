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
package jabber;

/**
	Send personal updates or "events" to other users, who are typically contacts in the user's roster.
	
	XEP-0163: Personal Eventing Protocol: http://xmpp.org/extensions/xep-0163.html
*/
class PersonalEvent {
	
	public dynamic function onPublish( e : xmpp.PersonalEvent ) {}
	public dynamic function onDisable( e : xmpp.PersonalEvent ) {}
	public dynamic function onError( e : XMPPError ) {}
	
	public var stream(default,null) : Stream;
	//var service : String;
	
	public function new( stream : jabber.Stream ) {
		this.stream = stream;
	}
	
	/**
		Publish a personal event.
	*/
	public function publish( e : xmpp.PersonalEvent ) {
		sendIQ( e, e.toXml(), onPublish );
	}
	
	// hmm public function disable( c : Class<xmpp.pep.Event> )
	
	/**
	 * Disable publishing.
	*/
	public function disable( e : xmpp.PersonalEvent ) {
		sendIQ( e, e.empty(), onDisable );
	}
	
	function sendIQ( e : xmpp.PersonalEvent, x : Xml, h : xmpp.PersonalEvent->Void ) {
		var p = new xmpp.pubsub.Publish( e.getNode(), [new xmpp.pubsub.Item( null, x )] );
		var x = new xmpp.PubSub();
		x.publish = p;
		var iq = new xmpp.IQ( xmpp.IQType.set, null );
		iq.x = x;
		var me = this;
		stream.sendIQ( iq, function(r:xmpp.IQ) {
			switch( r.type ) {
			case result :
				h( e );
			case error :
				me.onError( new jabber.XMPPError( r ) );
			default : //#
			}
		} );
	}
	
}
